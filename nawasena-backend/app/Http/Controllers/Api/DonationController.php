<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\{Donation, Inventory};
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use App\Events\DonationStatusUpdated;
use Illuminate\Http\JsonResponse;

class DonationController extends Controller
{
    /**
     * GET /api/donations
     * List all donations (admin view). Supports filtering by status and foundation.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Donation::orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('foundation_id')) {
            $query->where('foundation_id', $request->foundation_id);
        }

        return response()->json($query->paginate(20));
    }

    /**
     * GET /api/donations/me
     * List the authenticated donor's own donation history.
     */
    public function mine(Request $request): JsonResponse
    {
        $donations = Donation::where('donor_id', $request->user()->id)
            ->latest()
            ->paginate(15);

        return response()->json($donations);
    }

    /**
     * GET /api/foundations/{id}/donations
     * List all donations received by a specific foundation.
     */
    public function byFoundation(string $id): JsonResponse
    {
        $donations = Donation::where('foundation_id', $id)
            ->latest()
            ->paginate(15);

        return response()->json($donations);
    }

    /**
     * GET /api/donations/{id}
     * Show a single donation's full detail including history_logs timeline.
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $donation = Donation::findOrFail($id);

        $data = $donation->toArray();
        if ($request->user()->id != $donation->donor_id) {
            unset($data['qr_code_hash']);
        }

        return response()->json($data);
    }

    /**
     * POST /api/donations
     * Create a new donation pledge. Generates a unique QR hash for tracking.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'foundation_id'       => 'required|string',
            'inventory_id'        => 'required|string',
            'type'                => 'required|in:goods,money',
            'item_detail'         => 'required|array',
            'item_detail.name'    => 'required|string',
            'item_detail.qty'     => 'required|integer|min:1',
            'item_detail.unit'    => 'required|string',
            'is_anonymous'        => 'boolean',
        ]);

        $inventory = Inventory::where('_id', $validated['inventory_id'])
            ->where('foundation_id', $validated['foundation_id'])
            ->firstOrFail();

        $donation = Donation::create([
            ...$validated,
            'donor_id'     => $request->user()->id,
            'status'       => 'pending',
            'qr_code_hash' => Str::random(40),
            'is_anonymous' => $validated['is_anonymous'] ?? false,
            'history_logs' => [[
                'status'    => 'pending',
                'timestamp' => now()->toISOString(),
                'note'      => 'Donation pledge created by donor',
            ]],
        ]);

        return response()->json([
            'message'  => 'Donation created. Please complete payment.',
            'donation' => $donation,
        ], 201);
    }

    /**
     * PATCH /api/donations/{id}/status
     * Manually update donation status (e.g., from 'pending' to 'sent').
     * Automatically appends an entry to history_logs.
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        $request->validate([
            'status'      => 'required|in:pending,sent,received,verified',
            'note'        => 'nullable|string',
            'proof_image' => 'nullable|url',
        ]);

        $donation = Donation::findOrFail($id);
        $donation->addHistoryLog(
            $request->status,
            $request->input('note', 'Status updated'),
            $request->proof_image
        );

        event(new DonationStatusUpdated($donation));

        return response()->json([
            'message'  => 'Status updated',
            'donation' => $donation->fresh(),
        ]);
    }

    /**
     * GET /api/donations/{id}/qr
     * Return the QR code data (hash) for a donation. Only accessible by the donor.
     */
    public function getQr(Request $request, string $id): JsonResponse
    {
        $donation = Donation::findOrFail($id);

        if ($donation->donor_id != $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        return response()->json([
            'donation_id'  => $donation->id,
            'qr_code_hash' => $donation->qr_code_hash,
            'status'       => $donation->status,
            'expires_at'   => null,
        ]);
    }

    /**
     * POST /api/donations/verify-qr
     * Verify a donation via QR code scan by the foundation admin.
     * Atomically increments inventory stock and appends a verified log entry.
     */
    public function verifyQr(Request $request): JsonResponse
    {
        $request->validate([
            'qr_code_hash' => 'required|string',
            'proof_image'  => 'nullable|url',
        ]);

        $donation = Donation::where('qr_code_hash', $request->qr_code_hash)
            ->firstOrFail();

        if ($donation->status === 'verified') {
            return response()->json(['message' => 'This donation has already been verified'], 409);
        }

        Inventory::where('_id', $donation->inventory_id)
            ->increment('current_qty', $donation->item_detail['qty']);

        $donation->addHistoryLog(
            'verified',
            'Barang diterima dan terverifikasi via QR Code',
            $request->proof_image
        );

        event(new DonationStatusUpdated($donation->fresh()));

        return response()->json([
            'message'  => 'Donation verified. Inventory stock updated.',
            'donation' => $donation->fresh(),
        ]);
    }
}
