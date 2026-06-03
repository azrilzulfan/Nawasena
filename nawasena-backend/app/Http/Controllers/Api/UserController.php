<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\{User, Donation, Workshop};
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    /**
     * GET /api/users
     * Menampilkan seluruh profil pengguna.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'role' => 'nullable|in:admin,donor,volunteer,foundation_admin',
        ]);

        $query = User::query();

        if ($request->filled('role')) {
            $query->where('role', $request->role);
        }

        $users = $query->orderBy('created_at', 'desc')->paginate(20);

        $users->getCollection()->transform(fn ($u) => $u->makeHidden(['password', 'remember_token']));

        return response()->json($users);
    }

    /**
     * GET /api/users/me
     * Menampilkan profil pengguna aktif.
     */
    public function me(Request $request): JsonResponse
    {
        return response()->json($request->user());
    }

    /**
     * PUT /api/users/me
     * Mengubah profil pengguna aktif.
     */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'full_name'                      => 'sometimes|string|max:255',
            'avatar_url'                     => 'sometimes|url',
            'volunteer_profile.skills'       => 'sometimes|array',
            'volunteer_profile.skills.*'     => 'string',
        ]);

        if ($request->has('volunteer_profile')) {
            $existing                    = $user->volunteer_profile ?? [];
            $validated['volunteer_profile'] = array_merge($existing, $request->input('volunteer_profile'));
        }

        $user->update($validated);

        return response()->json([
            'message' => 'Profile updated',
            'user'    => $user->fresh(),
        ]);
    }

    /**
     * GET /api/users/{id}
     * Menampilkan detail profil pengguna lain.
     */
    public function show(string $id): JsonResponse
    {
        $user = User::findOrFail($id);

        return response()->json([
            'id'               => $user->id,
            'full_name'        => $user->full_name,
            'avatar_url'       => $user->avatar_url,
            'role'             => $user->role,
            'volunteer_profile'=> $user->volunteer_profile,
            'created_at'       => $user->created_at,
        ]);
    }

    /**
     * GET /api/users/{id}/portfolio
     * Menampilkan capaian sosial pengguna.
     */
    public function portfolio(string $id): JsonResponse
    {
        $user = User::findOrFail($id);

        $donations = Donation::where('donor_id', $id)
            ->where('is_anonymous', false)
            ->get(['foundation_id', 'item_detail', 'status', 'created_at']);

        $foundationsHelped = $donations->pluck('foundation_id')->unique()->count();

        $totalGoodsQty = $donations->sum(fn($d) => $d->item_detail['qty'] ?? 0);

        $workshopsAttended = Workshop::where('registered_volunteers', 'elemMatch', [
            'user_id' => $id,
            'status'  => 'attended',
        ])->get(['title', 'foundation_id', 'event_date']);

        $volunteerHours = $user->volunteer_profile['total_hours'] ?? 0;

        return response()->json([
            'user' => [
                'id'               => $user->id,
                'full_name'        => $user->full_name,
                'avatar_url'       => $user->avatar_url,
                'role'             => $user->role,
                'skills'           => $user->volunteer_profile['skills'] ?? [],
            ],
            'impact' => [
                'total_donations'    => $donations->count(),
                'foundations_helped' => $foundationsHelped,
                'total_goods_qty'    => $totalGoodsQty,
                'volunteer_hours'    => $volunteerHours,
                'workshops_attended' => $workshopsAttended->count(),
            ],
            'recent_donations'   => $donations->take(5),
            'recent_workshops'   => $workshopsAttended->take(5),
        ]);
    }
}
