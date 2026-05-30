<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\{Workshop, Foundation};
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class WorkshopController extends Controller
{
    /**
     * GET /api/workshops
     * List all workshops. Filterable by status and foundation_id.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Workshop::query();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('foundation_id')) {
            $query->where('foundation_id', $request->foundation_id);
        }

        return response()->json($query->orderBy('event_date')->paginate(15));
    }

    /**
     * GET /api/foundations/{id}/workshops
     * List all workshops for a specific foundation.
     */
    public function byFoundation(string $id): JsonResponse
    {
        Foundation::findOrFail($id);

        $workshops = Workshop::where('foundation_id', $id)
            ->orderBy('event_date')
            ->get();

        return response()->json($workshops);
    }

    /**
     * GET /api/workshops/{id}
     * Show a single workshop including registered volunteers.
     */
    public function show(string $id): JsonResponse
    {
        return response()->json(Workshop::findOrFail($id));
    }

    /**
     * POST /api/foundations/{id}/workshops
     * Create a new workshop agenda for a foundation.
     */
    public function store(Request $request, string $id): JsonResponse
    {
        Foundation::findOrFail($id);

        $validated = $request->validate([
            'title'                   => 'required|string|max:255',
            'description'             => 'required|string',
            'event_date'              => 'required|date|after:today',
            'mentor_needed'           => 'required|integer|min:1',
            'location'                => 'required|array',
            'location.coordinates'    => 'required|array|size:2',
            'geofence_radius_meters'  => 'sometimes|integer|min:50|max:1000',
        ]);

        $workshop = Workshop::create([
            ...$validated,
            'foundation_id'           => $id,
            'status'                  => 'open',
            'mentor_registered_count' => 0,
            'registered_volunteers'   => [],
            'location'                => [
                'type'        => 'Point',
                'coordinates' => $validated['location']['coordinates'],
            ],
            'geofence_radius_meters'  => $validated['geofence_radius_meters'] ?? 100,
        ]);

        return response()->json([
            'message'  => 'Workshop created',
            'workshop' => $workshop,
        ], 201);
    }

    /**
     * PUT /api/workshops/{id}
     * Update workshop info (title, description, date, mentor quota).
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $workshop = Workshop::findOrFail($id);

        $validated = $request->validate([
            'title'                  => 'sometimes|string|max:255',
            'description'            => 'sometimes|string',
            'event_date'             => 'sometimes|date',
            'mentor_needed'          => 'sometimes|integer|min:1',
            'geofence_radius_meters' => 'sometimes|integer|min:50|max:1000',
        ]);

        $workshop->update($validated);

        return response()->json([
            'message'  => 'Workshop updated',
            'workshop' => $workshop->fresh(),
        ]);
    }

    /**
     * POST /api/workshops/{id}/register
     * Register the authenticated user as a volunteer for this workshop.
     */
    public function register(Request $request, string $id): JsonResponse
    {
        $workshop = Workshop::findOrFail($id);
        $user     = $request->user();

        if ($workshop->status !== 'open') {
            return response()->json(['message' => 'Workshop registration is closed'], 422);
        }

        if ($workshop->isVolunteerRegistered($user->id)) {
            return response()->json(['message' => 'You are already registered'], 409);
        }

        if ($workshop->mentor_registered_count >= $workshop->mentor_needed) {
            return response()->json(['message' => 'Volunteer quota is full'], 422);
        }

        $volunteers   = $workshop->registered_volunteers ?? [];
        $volunteers[] = [
            'user_id'   => $user->id,
            'user_name' => $user->full_name,
            'status'    => 'confirmed',
            'joined_at' => now()->toISOString(),
        ];

        $workshop->update([
            'registered_volunteers'   => $volunteers,
            'mentor_registered_count' => $workshop->mentor_registered_count + 1,
        ]);

        return response()->json(['message' => 'Registered as volunteer successfully'], 201);
    }

    /**
     * POST /api/workshops/{id}/checkin
     * GPS-based attendance check-in using the Haversine geofence formula.
     * Returns 422 if the volunteer is outside the defined radius.
     */
    public function checkin(Request $request, string $id): JsonResponse
    {
        $request->validate([
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
        ]);

        $workshop = Workshop::findOrFail($id);
        $user     = $request->user();

        if (!$workshop->isVolunteerRegistered($user->id)) {
            return response()->json(['message' => 'You are not registered for this workshop'], 403);
        }

        $wLng = $workshop->location['coordinates'][0];
        $wLat = $workshop->location['coordinates'][1];

        $distanceMeters = $this->haversineMeters(
            (float) $request->lat,
            (float) $request->lng,
            (float) $wLat,
            (float) $wLng
        );

        $allowedRadius = $workshop->geofence_radius_meters ?? 100;

        if ($distanceMeters > $allowedRadius) {
            return response()->json([
                'message'            => 'You are outside the geofence area',
                'your_distance_m'    => round($distanceMeters),
                'allowed_radius_m'   => $allowedRadius,
            ], 422);
        }

        $alreadyCheckedIn = collect($workshop->registered_volunteers)
            ->where('user_id', $user->id)
            ->where('status', 'attended')
            ->isNotEmpty();

        if ($alreadyCheckedIn) {
            return response()->json(['message' => 'You have already checked in'], 409);
        }

        $volunteers = collect($workshop->registered_volunteers)
            ->map(function ($v) use ($user) {
                if ($v['user_id'] == $user->id) {
                    $v['status']       = 'attended';
                    $v['checked_in_at'] = now()->toISOString();
                }
                return $v;
            })
            ->toArray();

        $workshop->update(['registered_volunteers' => $volunteers]);

        return response()->json([
            'message'         => 'Check-in successful',
            'distance_meters' => round($distanceMeters),
        ]);
    }

    /**
     * PATCH /api/workshops/{id}/volunteers/{uid}/status
     * Foundation admin updates a specific volunteer's attendance status.
     */
    public function updateVolunteerStatus(Request $request, string $id, string $uid): JsonResponse
    {
        $request->validate([
            'status' => 'required|in:confirmed,attended',
        ]);

        $workshop = Workshop::findOrFail($id);

        $volunteers = collect($workshop->registered_volunteers)
            ->map(function ($v) use ($uid, $request) {
                if ($v['user_id'] == $uid) {
                    $v['status'] = $request->status;
                }
                return $v;
            })
            ->toArray();

        $workshop->update(['registered_volunteers' => $volunteers]);

        return response()->json(['message' => 'Volunteer status updated']);
    }

    /**
     * DELETE /api/workshops/{id}/register
     * Cancel the authenticated user's workshop registration.
     */
    public function unregister(Request $request, string $id): JsonResponse
    {
        $workshop = Workshop::findOrFail($id);
        $userId   = $request->user()->id;

        if (!$workshop->isVolunteerRegistered($userId)) {
            return response()->json(['message' => 'You are not registered for this workshop'], 404);
        }

        $volunteers = collect($workshop->registered_volunteers)
            ->reject(fn($v) => $v['user_id'] == $userId)
            ->values()
            ->toArray();

        $workshop->update([
            'registered_volunteers'   => $volunteers,
            'mentor_registered_count' => max(0, $workshop->mentor_registered_count - 1),
        ]);

        return response()->json(['message' => 'Registration cancelled']);
    }

    /**
     * PATCH /api/workshops/{id}/status
     * Close or mark a workshop as finished. Updates its lifecycle status.
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        $request->validate([
            'status' => 'required|in:open,closed,finished',
        ]);

        $workshop = Workshop::findOrFail($id);
        $workshop->update(['status' => $request->status]);

        return response()->json([
            'message'  => 'Workshop status updated to ' . $request->status,
            'workshop' => $workshop->fresh(),
        ]);
    }

    /**
     * Calculate the Haversine distance between two GPS coordinates.
     * Returns distance in meters.
     */
    private function haversineMeters(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $R  = 6371000;
        $φ1 = deg2rad($lat1);
        $φ2 = deg2rad($lat2);
        $Δφ = deg2rad($lat2 - $lat1);
        $Δλ = deg2rad($lng2 - $lng1);

        $a = sin($Δφ / 2) ** 2
           + cos($φ1) * cos($φ2) * sin($Δλ / 2) ** 2;

        return $R * 2 * atan2(sqrt($a), sqrt(1 - $a));
    }
}
