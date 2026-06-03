<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\{Foundation, Inventory};
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class InventoryController extends Controller
{
    /**
     * GET /api/inventories
     * Menampilkan daftar kebutuhan panti.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Inventory::with('foundation')->orderBy('created_at', 'desc');

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        if ($request->filled('urgent_level')) {
            $query->where('urgent_level', $request->urgent_level);
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
     * GET /api/foundations/{id}/inventories
     * Menampilkan stok/kebutuhan panti tertentu.
     */
    public function byFoundation(Request $request, string $id): JsonResponse
    {
        $foundation = Foundation::where('_id', $id)->first();

        if (!$foundation) {
            return response()->json(['message' => 'Foundation not found'], 404);
        }

        $items = Inventory::where('foundation_id', $id)
            ->orderBy('urgent_level', 'asc') // Hindari sort kosong tanpa parameter arah
            ->get();

        return response()->json($items);
    }

    /**
     * GET /api/inventories/{id}
     * Melihat detail item inventori.
     */
    public function show(string $id): JsonResponse
    {
        $inventory = Inventory::where('_id', $id)->first();

        if (!$inventory) {
            return response()->json(['message' => 'Inventory item not found'], 404);
        }

        return response()->json($inventory);
    }

    /**
     * POST /api/foundations/{id}/inventories
     * Menambahkan item kebutuhan baru.
     */
    public function store(Request $request, string $id): JsonResponse
    {
        $foundation = Foundation::where('_id', $id)->first();

        if (!$foundation) {
            return response()->json(['message' => 'Foundation not found'], 404);
        }

        $validated = $request->validate([
            'item_name'   => 'required|string|max:255',
            'category'    => 'required|in:Logistik,Edukasi,Medis',
            'unit'        => 'required|string',
            'target_qty'  => 'required|integer|min:1',
            'current_qty' => 'sometimes|integer|min:0',
            'urgent_level'=> 'required|in:high,medium,low',
            'description' => 'nullable|string',
        ]);

        $item = Inventory::create([
            ...$validated,
            'foundation_id' => $id,
            'current_qty'   => $validated['current_qty'] ?? 0,
        ]);

        return response()->json([
            'message' => 'Inventory item created',
            'item'    => $item,
        ], 201);
    }

    /**
     * PUT /api/inventories/{id}
     * Mengubah detail item inventori.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        // Ganti findOrFail menjadi pencarian berbasis MongoDB _id
        $item = Inventory::where('_id', $id)->first();

        if (!$item) {
            return response()->json(['message' => 'Inventory item not found'], 404);
        }

        $validated = $request->validate([
            'item_name'   => 'sometimes|string|max:255',
            'category'    => 'sometimes|in:Logistik,Edukasi,Medis',
            'unit'        => 'sometimes|string',
            'target_qty'  => 'sometimes|integer|min:1',
            'current_qty' => 'sometimes|integer|min:0',
            'urgent_level'=> 'sometimes|in:high,medium,low',
            'description' => 'nullable|string',
        ]);

        $item->update($validated);

        return response()->json([
            'message' => 'Item updated',
            'item'    => $item->fresh(),
        ]);
    }

    /**
     * DELETE /api/inventories/{id}
     * Menghapus item dari daftar inventori.
     */
    public function destroy(string $id): JsonResponse
    {
        // Ganti findOrFail menjadi pencarian berbasis MongoDB _id
        $item = Inventory::where('_id', $id)->first();

        if (!$item) {
            return response()->json(['message' => 'Inventory item not found'], 404);
        }

        $item->delete();

        return response()->json(['message' => 'Item deleted']);
    }
}
