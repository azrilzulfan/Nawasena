<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\{Foundation, Donation, Inventory, Workshop};
use Illuminate\Http\JsonResponse;

class FoundationController extends Controller
{
    /**
     * GET /api/foundations
     * List all verified foundations. Supports optional filtering by name/area.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Foundation::orderBy('created_at', 'desc');

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%')
                ->orWhere('address', 'like', '%' . $request->search . '%');
            });
        }


        if ($request->has('is_verified')) {
            $query->where('is_verified', $request->boolean('is_verified'));
        }

        $foundations = $query->paginate(15);

        return response()->json($foundations);
    }

    /**
     * GET /api/foundations/nearby?lat=&lng=&radius=
     * Find verified foundations within a given radius (meters) using MongoDB $near.
     */
    public function nearby(Request $request): JsonResponse
    {
        $request->validate([
            'lat'    => 'required|numeric|between:-90,90',
            'lng'    => 'required|numeric|between:-180,180',
            'radius' => 'nullable|integer|min:100|max:50000',
        ]);

        $radius = (int) $request->input('radius', 5000);

        $foundations = Foundation::where('is_verified', true)
            ->where('location', 'near', [
                'geometry' => [
                    'type'        => 'Point',
                    'coordinates' => [(float) $request->lng, (float) $request->lat],
                ],
                'maxDistance' => $radius,
            ])
            ->get();

        return response()->json([
            'radius_meters' => $radius,
            'count'         => $foundations->count(),
            'data'          => $foundations,
        ]);
    }

    /**
     * GET /api/foundations/{id}
     * Show a single foundation's details.
     */
    public function show(string $id): JsonResponse
    {
        $foundation = Foundation::findOrFail($id);
        return response()->json($foundation);
    }

    /**
     * POST /api/foundations
     * Register a new foundation (pending verification).
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'                  => 'required|string|max:255',
            'description'           => 'required|string',
            'address'               => 'required|string',
            'contact_phone'         => 'required|string',
            'location'              => 'required|array',
            'location.coordinates'  => 'required|array|size:2',
            'location.coordinates.0'=> 'required|numeric|between:-180,180',
            'location.coordinates.1'=> 'required|numeric|between:-90,90',
            'verification_docs'     => 'required|array|min:1',
            'verification_docs.*'   => 'required|string',
            'bank_account'          => 'nullable|array',
            'bank_account.bank_name'    => 'required_with:bank_account|string',
            'bank_account.account_number'=> 'required_with:bank_account|string',
            'bank_account.account_name' => 'required_with:bank_account|string',
        ]);

        $validated['location'] = [
            'type' => 'Point',
            'coordinates' => [
                (float) $request->input('location.coordinates.0'),
                (float) $request->input('location.coordinates.1'),
            ],
        ];

        $validated['verification_docs'] = array_values($validated['verification_docs'] ?? []);

        $validated['is_verified']     = false;
        $validated['admin_id']         = $request->user()->id;

        $validated['verification_docs'] = array_map(function ($url) {
            if (str_contains($url, '/storage/')) {
                return explode('/storage/', $url)[1];
            }
            return $url;
        }, $validated['verification_docs'] ?? []);

        $foundation = Foundation::create($validated);

        $request->user()->update([
            'managed_foundation_id' => (string) $foundation->id,
        ]);

        return response()->json([
            'message'    => 'Foundation registered. Pending verification.',
            'foundation' => $foundation,
            'user'       => $request->user()->fresh(),
        ], 201);
    }

    /**
     * PUT /api/foundations/{id}
     * Update foundation profile. Only the foundation admin can do this.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $foundation = Foundation::findOrFail($id);

        if ($foundation->admin_id != $request->user()->id
            && $request->user()->role !== 'foundation_admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name'            => 'sometimes|string|max:255',
            'description'     => 'sometimes|string',
            'address'         => 'sometimes|string',
            'contact_phone'   => 'sometimes|string',
            'verification_docs'=> 'sometimes|array',
            'bank_account'    => 'sometimes|array',
        ]);

        $foundation->update($validated);

        return response()->json([
            'message'    => 'Foundation updated',
            'foundation' => $foundation->fresh(),
        ]);
    }

    /**
     * PATCH /api/foundations/{id}/verify
     * Verify a foundation registration. Super-admin only.
     */
    public function verify(Request $request, string $id): JsonResponse
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Forbidden. Only system admins can verify foundations.'], 403);
        }

        if ($id === 'undefined' || empty($id)) {
            return response()->json(['message' => 'Format ID Panti tidak valid atau tidak disertakan.'], 400);
        }

        $foundation = Foundation::find($id);

        if (!$foundation) {
            return response()->json([
                'message' => "Panti asuhan dengan ID [{$id}] tidak ditemukan di sistem."
            ], 404);
        }

        $foundation->update(['is_verified' => true]);

        return response()->json([
            'message'    => 'Foundation verified successfully',
            'foundation' => $foundation,
        ]);
    }

    /**
     * DELETE /api/foundations/{id}
     * Remove a foundation from the system.
     */
    public function destroy(Request $request, string $id): JsonResponse
    {
        if ($request->user()->role !== 'foundation_admin') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        Foundation::findOrFail($id)->delete();

        return response()->json(['message' => 'Foundation deleted']);
    }

    /**
     * GET /api/foundations/{id}/analytics
     * Aggregated statistics: donations, volunteers, inventory summary.
     */
    public function analytics(string $id): JsonResponse
    {
        Foundation::findOrFail($id);

        $donationsByStatus = Donation::where('foundation_id', $id)
            ->get(['status'])
            ->groupBy('status')
            ->map(fn($g) => $g->count());

        $inventorySummary = Inventory::where('foundation_id', $id)
            ->get(['item_name', 'current_qty', 'target_qty', 'urgent_level']);

        $urgentItems = $inventorySummary->where('urgent_level', 'high')->count();

        $totalVolunteers = Workshop::where('foundation_id', $id)
            ->sum('mentor_registered_count');

        return response()->json([
            'donations' => [
                'total'    => $donationsByStatus->sum(),
                'by_status'=> $donationsByStatus,
            ],
            'inventory' => [
                'total_items'  => $inventorySummary->count(),
                'urgent_items' => $urgentItems,
                'items'        => $inventorySummary,
            ],
            'volunteers' => [
                'total_registered' => $totalVolunteers,
                'total_workshops'  => Workshop::where('foundation_id', $id)->count(),
            ],
        ]);
    }
}
