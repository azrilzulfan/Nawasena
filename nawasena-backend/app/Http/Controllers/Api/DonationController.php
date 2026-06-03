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
     * Menampilkan seluruh riwayat donasi.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Donation::with('foundation')->orderBy('created_at', 'desc');

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

        return response()->json($query->paginate(20));
    }

    /**
     * GET /api/donations/me
     * Menampilkan riwayat donasi pribadi.
     */
    public function mine(Request $request): JsonResponse
    {
        $donations = Donation::where('donor_id', $request->user()->id)
        ->orderBy('created_at', 'desc')
        ->paginate(15);

    return response()->json($donations);
    }

    /**
     * GET /api/foundations/{id}/donations
     * Menampilkan donasi yang diterima panti.
     */
    public function byFoundation(string $id): JsonResponse
    {
        $donations = Donation::where('foundation_id', $id)
            ->orWhere('foundation_id', new \MongoDB\BSON\ObjectId($id))
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json($donations);
    }

    /**
     * GET /api/donations/{id}
     * Melihat detail transaksi donasi.
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
     * Membuat pengajuan donasi baru.
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
                'note'      => 'Donasi yang dibuat oleh donatur',
            ]],
        ]);

        return response()->json([
            'message'  => 'Donation created. Please complete payment.',
            'donation' => $donation,
        ], 201);
    }

    /**
     * PATCH /api/donations/{id}/status
     * Mengubah status progres donasi.
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        if ($id === 'undefined' || empty($id)) {
            return response()->json([
                'message' => 'Gagal memperbarui status: ID Donasi tidak valid (undefined).'
            ], 400);
        }

        $request->validate([
            'status'      => 'required|in:pending,sent,received,verified',
            'note'        => 'nullable|string',
            'proof_image' => 'nullable|url',
        ]);

        $query = Donation::where('_id', $id);
        if (strlen($id) === 24 && ctype_xdigit($id)) {
            $query->orWhere('_id', new \MongoDB\BSON\ObjectId($id));
        }
        $donation = $query->first();

        if (!$donation) {
            return response()->json(['message' => 'Data transaksi donasi tidak ditemukan.'], 404);
        }

        $oldStatus = $donation->status;
        $newStatus = $request->status;

        if ($oldStatus === 'verified' && $newStatus === 'verified') {
            return response()->json(['message' => 'Donasi ini sudah berstatus terverifikasi.'], 409);
        }

        if ($newStatus === 'verified' && $oldStatus !== 'verified') {
            $invId = $donation->inventory_id;

            $inventoryQuery = Inventory::where('_id', $invId);
            if (strlen($invId) === 24 && ctype_xdigit($invId)) {
                $inventoryQuery->orWhere('_id', new \MongoDB\BSON\ObjectId($invId));
            }
            $inventory = $inventoryQuery->first();

            if ($inventory) {
                $qtyToAdd = (int) ($donation->item_detail['qty'] ?? 0);

                $inventory->increment('current_qty', $qtyToAdd);
            }
        }

        $donation->update(['status' => $newStatus]);

        $donation->addHistoryLog(
            $newStatus,
            $request->input('note', "Status donasi diperbarui menjadi " . $newStatus),
            $request->proof_image
        );

        event(new DonationStatusUpdated($donation->fresh()));

        return response()->json([
            'message'  => 'Status donasi berhasil diperbarui dan stok inventori telah disesuaikan.',
            'donation' => $donation->fresh(),
        ]);
    }

    /**
     * GET /api/donations/{id}/qr
     * Mendapatkan kode QR serah terima.
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
     * Verifikasi donasi via QR dan pembaruan stok inventori otomatis.
     */
    public function verifyQr(Request $request): JsonResponse
    {
        $request->validate([
            'qr_code_hash' => 'required|string',
            'proof_image'  => 'nullable|url',
        ]);

        $hash = trim($request->qr_code_hash);

        $donation = Donation::where('qr_code_hash', '=', $hash)->first();

        if (!$donation) {
            return response()->json([
                'message' => "Data donasi tidak ditemukan. Token QR tidak cocok atau sudah kedaluwarsa.",
                'debug_received_hash' => $hash
            ], 404);
        }

        if ($donation->status === 'verified') {
            return response()->json(['message' => 'This donation has already been verified'], 409);
        }

        $invId = $donation->inventory_id;
        $inventory = Inventory::where('_id', $invId)->orWhere('_id', new \MongoDB\BSON\ObjectId($invId))->first();

        if ($inventory) {
            $inventory->increment('current_qty', (int) $donation->item_detail['qty']);
        }

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
