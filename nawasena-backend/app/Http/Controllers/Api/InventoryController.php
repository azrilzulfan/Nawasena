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
     * List all inventory items across all foundations.
     * Supports filtering by category, urgent_level, and foundation_id.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Inventory::query();

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        if ($request->filled('urgent_level')) {
            $query->where('urgent_level', $request->urgent_level);
        }

        if ($request->filled('foundation_id')) {
            $query->where('foundation_id', $request->foundation_id);
        }

        return response()->json($query->paginate(20));
    }

    /**
     * GET /api/foundations/{id}/inventories
     * List all inventory items belonging to a specific foundation.
     */
    public function byFoundation(Request $request, string $id): JsonResponse
    {
        Foundation::findOrFail($id);

        $items = Inventory::where('foundation_id', $id)
            ->orderBy('urgent_level')
            ->get();

        return response()->json($items);
    }

    /**
     * GET /api/inventories/{id}
     * Show a single inventory item's detail.
     */
    public function show(string $id): JsonResponse
    {
        return response()->json(Inventory::findOrFail($id));
    }

    /**
     * POST /api/foundations/{id}/inventories
     * Add a new inventory item/need to a foundation.
     */
    public function store(Request $request, string $id): JsonResponse
    {
        Foundation::findOrFail($id);

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
     * Update an existing inventory item's details.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $item = Inventory::findOrFail($id);

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
     * Remove an inventory item from the list.
     */
    public function destroy(string $id): JsonResponse
    {
        Inventory::findOrFail($id)->delete();
        return response()->json(['message' => 'Item deleted']);
    }
}
