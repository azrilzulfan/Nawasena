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
     * Menampilkan daftar kegiatan workshop.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Workshop::query();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('foundation_id')) {
            $fId = $request->foundation_id;
            $query->where(function($q) use ($fId) {
                $q->where('foundation_id', $fId);
                if (strlen($fId) === 24 && ctype_xdigit($fId)) {
                    $q->orWhere('foundation_id', new \MongoDB\BSON\ObjectId($fId));
                }
            });
        }

        return response()->json($query->orderBy('event_date', 'asc')->paginate(15));
    }

    /**
     * GET /api/foundations/{id}/workshops
     * Menampilkan workshop panti tertentu.
     */
    public function byFoundation(string $id): JsonResponse
    {
        $foundation = Foundation::where('_id', $id);
        if (strlen($id) === 24 && ctype_xdigit($id)) {
            $foundation->orWhere('_id', new \MongoDB\BSON\ObjectId($id));
        }
        $foundation = $foundation->first();

        if (!$foundation) {
            return response()->json(['message' => 'Foundation not found'], 404);
        }

        $realId = $foundation->id ?? $id;

        $workshops = Workshop::where('foundation_id', $realId)
            ->orWhere('foundation_id', new \MongoDB\BSON\ObjectId($realId))
            ->orderBy('event_date', 'asc')
            ->get();

        return response()->json($workshops);
    }

    /**
     * GET /api/workshops/{id}
     * Melihat detail dan peserta workshop.
     */
    public function show(string $id): JsonResponse
    {
        $query = Workshop::where('_id', $id);
        if (strlen($id) === 24 && ctype_xdigit($id)) {
            $query->orWhere('_id', new \MongoDB\BSON\ObjectId($id));
        }
        $workshop = $query->first();

        if (!$workshop) {
            return response()->json(['message' => 'Workshop not found'], 404);
        }

        return response()->json($workshop);
    }

    /**
     * POST /api/foundations/{id}/workshops
     * Membuat agenda workshop baru dengan sinkronisasi lokasi otomatis.
     */
    public function store(Request $request, string $id): JsonResponse
    {
        $foundation = Foundation::where('_id', $id);
        if (strlen($id) === 24 && ctype_xdigit($id)) {
            $foundation->orWhere('_id', new \MongoDB\BSON\ObjectId($id));
        }
        $foundation = $foundation->first();

        if (!$foundation) {
            return response()->json(['message' => 'Foundation database record missing.'], 404);
        }

        $validated = $request->validate([
            'title'                  => 'required|string|max:255',
            'description'            => 'required|string',
            'event_date'             => 'required|date|after:today',
            'mentor_needed'          => 'required|integer|min:1',
            'location'               => 'nullable|array',
            'location.coordinates'   => 'nullable|array|size:2',
            'geofence_radius_meters' => 'sometimes|integer|min:50|max:2000',
        ]);

        // PROTEKSI UTAMA: Jika koordinat kiriman React bernilai [0,0] atau kosong,
        // otomatis kloning lokasi asli milik yayasan penanggung jawab (Biar Geofence tidak nyasar ke Afrika)
        $coords = $validated['location']['coordinates'] ?? [0,0];
        if (($coords[0] == 0 && $coords[1] == 0) && isset($foundation->location['coordinates'])) {
            $coords = $foundation->location['coordinates'];
        }

        $workshop = Workshop::create([
            'title'                   => $validated['title'],
            'description'             => $validated['description'],
            'event_date'              => $validated['event_date'],
            'mentor_needed'           => (int)$validated['mentor_needed'],
            'foundation_id'           => $foundation->id ?? $id,
            'status'                  => 'open',
            'mentor_registered_count' => 0,
            'registered_volunteers'   => [], // Simpan murni sebagai Array kosong native
            'location'                => [
                'type'        => 'Point',
                'coordinates' => [(float)$coords[0], (float)$coords[1]],
            ],
            'geofence_radius_meters'  => (int)($validated['geofence_radius_meters'] ?? 500),
        ]);

        return response()->json([
            'message'  => 'Workshop created successfully',
            'workshop' => $workshop,
        ], 201);
    }

    /**
     * PUT /api/workshops/{id}
     * Mengubah informasi detail workshop.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $query = Workshop::where('_id', $id);
        if (strlen($id) === 24 && ctype_xdigit($id)) {
            $query->orWhere('_id', new \MongoDB\BSON\ObjectId($id));
        }
        $workshop = $query->first();

        if (!$workshop) {
            return response()->json(['message' => 'Workshop not found'], 404);
        }

        $validated = $request->validate([
            'title'                  => 'sometimes|string|max:255',
            'description'            => 'sometimes|string',
            'event_date'             => 'sometimes|date',
            'mentor_needed'          => 'sometimes|integer|min:1',
            'geofence_radius_meters' => 'sometimes|integer|min:50|max:2000',
        ]);

        $workshop->update($validated);

        return response()->json([
            'message'  => 'Workshop updated',
            'workshop' => $workshop->fresh(),
        ]);
    }

    /**
     * POST /api/workshops/{id}/register
     * Mendaftar sebagai relawan workshop.
     */
    public function register(Request $request, string $id): JsonResponse
    {
        $query = Workshop::where('_id', $id);
        if (strlen($id) === 24 && ctype_xdigit($id)) {
            $query->orWhere('_id', new \MongoDB\BSON\ObjectId($id));
        }
        $workshop = $query->first();

        if (!$workshop) {
            return response()->json(['message' => 'Workshop not found'], 404);
        }

        $user = $request->user();

        if ($workshop->status !== 'open') {
            return response()->json(['message' => 'Workshop registration is closed'], 422);
        }

        // Antisipasi jika data mendaftar tersimpan sebagai string teks biasa
        $volunteers = $workshop->registered_volunteers;
        if (is_string($volunteers)) {
            $volunteers = json_decode($volunteers, true) ?? [];
        }

        $isAlreadyRegistered = collect($volunteers)->where('user_id', $user->id)->isNotEmpty();
        if ($isAlreadyRegistered) {
            return response()->json(['message' => 'You are already registered'], 409);
        }

        if ($workshop->mentor_registered_count >= $workshop->mentor_needed) {
            return response()->json(['message' => 'Volunteer quota is full'], 422);
        }

        $volunteers[] = [
            'user_id'   => (string)$user->id,
            'user_name' => $user->full_name,
            'status'    => 'confirmed',
            'joined_at' => now()->toISOString(),
        ];

        $workshop->update([
            'registered_volunteers'   => $volunteers,
            'mentor_registered_count' => count($volunteers),
        ]);

        return response()->json(['message' => 'Registered as volunteer successfully'], 201);
    }

    /**
     * POST /api/workshops/{id}/checkin
     * Absensi GPS aman berorientasi Array murni MongoDB.
     */
    public function checkin(Request $request, string $id): JsonResponse
    {
        $request->validate([
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
        ]);

        $query = Workshop::where('_id', $id);
        if (strlen($id) === 24 && ctype_xdigit($id)) {
            $query->orWhere('_id', new \MongoDB\BSON\ObjectId($id));
        }
        $workshop = $query->first();

        if (!$workshop) {
            return response()->json(['message' => 'Workshop record missing'], 404);
        }

        $user = $request->user();
        $volunteers = $workshop->registered_volunteers;
        if (is_string($volunteers)) {
            $volunteers = json_decode($volunteers, true) ?? [];
        }

        $userRegistration = collect($volunteers)->where('user_id', $user->id)->first();
        if (!$userRegistration) {
            return response()->json(['message' => 'You are not registered for this workshop'], 403);
        }

        // Ekstraksi data titik koordinat array spasial Point
        $wLng = (float)$workshop->location['coordinates'][0];
        $wLat = (float)$workshop->location['coordinates'][1];

        $distanceMeters = $this->haversineMeters(
            (float) $request->lat,
            (float) $request->lng,
            (float) $wLat,
            (float) $wLng
        );

        $allowedRadius = (int)($workshop->geofence_radius_meters ?? 500);

        if ($distanceMeters > $allowedRadius) {
            return response()->json([
                'message'            => 'Gagal Absen: Anda berada di luar area Geofence workshop Nawasena.',
                'your_distance_m'    => round($distanceMeters),
                'allowed_radius_m'   => $allowedRadius,
            ], 422);
        }

        $alreadyCheckedIn = collect($volunteers)
            ->where('user_id', $user->id)
            ->where('status', 'attended')
            ->isNotEmpty();

        if ($alreadyCheckedIn) {
            return response()->json(['message' => 'You have already checked in'], 409);
        }

        $updatedVolunteers = collect($volunteers)
            ->map(function ($v) use ($user) {
                if ($v['user_id'] == $user->id) {
                    $v['status']       = 'attended';
                    $v['checked_in_at'] = now()->toISOString();
                }
                return $v;
            })
            ->toArray();

        $workshop->update(['registered_volunteers' => $updatedVolunteers]);

        return response()->json([
            'message'    => 'Check-in successful. Attendance recorded.',
            'distance_m' => round($distanceMeters),
        ]);
    }

    /**
     * PATCH /api/workshops/{id}/volunteers/{uid}/status
     */
    public function updateVolunteerStatus(Request $request, string $id, string $uid): JsonResponse
    {
        $request->validate([
            'status' => 'required|in:confirmed,attended',
        ]);

        $query = Workshop::where('_id', $id);
        if (strlen($id) === 24 && ctype_xdigit($id)) {
            $query->orWhere('_id', new \MongoDB\BSON\ObjectId($id));
        }
        $workshop = $query->first();

        if (!$workshop) {
            return response()->json(['message' => 'Workshop not found'], 404);
        }

        $volunteers = $workshop->registered_volunteers;
        if (is_string($volunteers)) {
            $volunteers = json_decode($volunteers, true) ?? [];
        }

        $updated = collect($volunteers)
            ->map(function ($v) use ($uid, $request) {
                if ($v['user_id'] == $uid) {
                    $v['status'] = $request->status;
                }
                return $v;
            })
            ->toArray();

        $workshop->update(['registered_volunteers' => $updated]);

        return response()->json(['message' => 'Volunteer status updated successfully']);
    }

    /**
     * DELETE /api/workshops/{id}/register
     */
    public function unregister(Request $request, string $id): JsonResponse
    {
        $query = Workshop::where('_id', $id);
        if (strlen($id) === 24 && ctype_xdigit($id)) {
            $query->orWhere('_id', new \MongoDB\BSON\ObjectId($id));
        }
        $workshop = $query->first();

        if (!$workshop) {
            return response()->json(['message' => 'Workshop not found'], 404);
        }

        $userId = $request->user()->id;
        $volunteers = $workshop->registered_volunteers;
        if (is_string($volunteers)) {
            $volunteers = json_decode($volunteers, true) ?? [];
        }

        $isRegistered = collect($volunteers)->where('user_id', $userId)->isNotEmpty();
        if (!$isRegistered) {
            return response()->json(['message' => 'You are not registered for this workshop'], 404);
        }

        $filtered = collect($volunteers)
            ->reject(fn($v) => $v['user_id'] == $userId)
            ->values()
            ->toArray();

        $workshop->update([
            'registered_volunteers'   => $filtered,
            'mentor_registered_count' => max(0, count($filtered)),
        ]);

        return response()->json(['message' => 'Registration cancelled']);
    }

    /**
     * PATCH /api/workshops/{id}/status
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        if ($id === 'undefined' || empty($id)) {
            return response()->json(['message' => 'ID Workshop tidak valid (undefined).'], 400);
        }

        $request->validate([
            'status' => 'required|in:open,closed,finished',
        ]);

        $query = Workshop::where('_id', $id);
        if (strlen($id) === 24 && ctype_xdigit($id)) {
            $query->orWhere('_id', new \MongoDB\BSON\ObjectId($id));
        }
        $workshop = $query->first();

        if (!$workshop) {
            return response()->json(['message' => 'Workshop not found'], 404);
        }

        $workshop->update(['status' => $request->status]);

        return response()->json([
            'message'  => 'Workshop status updated to ' . $request->status,
            'workshop' => $workshop->fresh(),
        ]);
    }

    /**
     * Hitung jarak rumus Haversine (Meters)
     */
    private function haversineMeters(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $R  = 6371000;
        $phi1 = deg2rad($lat1);
        $phi2 = deg2rad($lat2);
        $deltaPhi = deg2rad($lat2 - $lat1);
        $deltaLambda = deg2rad($lng2 - $lng1);

        $a = sin($deltaPhi / 2) ** 2
           + cos($phi1) * cos($phi2) * sin($deltaLambda / 2) ** 2;

        return $R * 2 * atan2(sqrt($a), sqrt(1 - $a));
    }
}
