<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Workshop extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'workshops';

    protected $fillable = [
        'foundation_id', 'title', 'description', 'event_date',
        'status', 'mentor_needed', 'mentor_registered_count',
        'registered_volunteers', 'location', 'geofence_radius_meters',
    ];

    protected $casts = [
        'event_date'            => 'datetime',
        'registered_volunteers' => 'array',
        'location'              => 'array',
    ];

    public function isVolunteerRegistered(string $userId): bool
    {
        return collect($this->registered_volunteers)
            ->contains('user_id', $userId);
    }
}
