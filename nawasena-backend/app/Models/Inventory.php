<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Inventory extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'inventories';

    protected $fillable = [
        'foundation_id', 'item_name', 'category', 'unit',
        'target_qty', 'current_qty', 'urgent_level', 'description',
    ];

    protected $casts = [
        'target_qty'  => 'integer',
        'current_qty' => 'integer',
    ];

    public function incrementStock(int $qty): void
    {
        $this->increment('current_qty', $qty);
    }

    public function foundation()
    {
        return $this->belongsTo(Foundation::class, 'foundation_id');
    }
}
