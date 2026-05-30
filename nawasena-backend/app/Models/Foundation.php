<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Foundation extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'foundations';

    protected $fillable = [
        'name', 'description', 'address', 'location',
        'contact_phone', 'verification_docs', 'is_verified',
        'bank_account', 'admin_id',
    ];

    protected $casts = [
        'bank_account'      => 'array',
        'is_verified'       => 'boolean',
    ];

    protected function verificationDocs(): \Illuminate\Database\Eloquent\Casts\Attribute
    {
        return \Illuminate\Database\Eloquent\Casts\Attribute::make(
            get: function ($value) {
                $docs = is_string($value) ? json_decode($value, true) : $value;
                return array_map(function ($doc) {
                    return str_starts_with($doc, 'http') ? $doc : asset("storage/{$doc}");
                }, $docs ?? []);
            }
        );
    }

    public function getVerificationDocsAttribute($value)
    {
        if (is_string($value)) {
            $paths = json_decode($value, true) ?? [];
        } elseif (is_array($value)) {
            $paths = $value;
        } else {
            $paths = [];
        }

        return collect($paths)
            ->map(fn ($path) => asset('storage/' . ltrim($path, '/')))
            ->values()
            ->all();
    }

    public function getVerificationDocPathsAttribute()
    {
        $value = $this->attributes['verification_docs'] ?? [];

        if (is_string($value)) {
            return json_decode($value, true) ?? [];
        }

        return $value;
    }

    public function inventories()
    {
        return $this->hasMany(Inventory::class, 'foundation_id');
    }

    public function donations()
    {
        return $this->hasMany(Donation::class, 'foundation_id');
    }

    public function workshops()
    {
        return $this->hasMany(Workshop::class, 'foundation_id');
    }
}
