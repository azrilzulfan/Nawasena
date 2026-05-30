<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;

class User extends Model
{
    use HasApiTokens, Notifiable;

    protected $connection = 'mongodb';
    protected $collection = 'users';

    protected $fillable = [
        'full_name', 'email', 'password', 'role',
        'avatar_url', 'volunteer_profile', 'managed_foundation_id',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'volunteer_profile' => 'array',
        'email_verified_at' => 'datetime',
        'password'          => 'hashed',
    ];
}
