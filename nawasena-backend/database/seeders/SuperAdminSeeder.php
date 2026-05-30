<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        $existing = User::where('email', env('SUPER_ADMIN_EMAIL', 'superadmin@nawasena.id'))->first();

        if ($existing) {
            $this->command->warn('Super Admin sudah ada, seeder dilewati.');
            return;
        }

        $user = User::create([
            'full_name' => env('SUPER_ADMIN_NAME', 'Super Admin Nawasena'),
            'email'     => env('SUPER_ADMIN_EMAIL', 'superadmin@nawasena.id'),
            'password'  => Hash::make(env('SUPER_ADMIN_PASSWORD')),
            'role'      => 'admin',
        ]);

        $this->command->info("Super Admin berhasil dibuat: {$user->email}");
    }
}
