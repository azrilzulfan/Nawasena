<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\{
    AuthController, UserController, FoundationController,
    InventoryController, DonationController, WorkshopController,
    UploadController
};

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');

// Public Routes ----------------------------------------------------------
Route::post('/auth/register',  [AuthController::class, 'register']);
Route::post('/auth/login',     [AuthController::class, 'login']);
Route::get('/foundations',    [FoundationController::class, 'index']);
Route::get('/foundations/nearby', [FoundationController::class, 'nearby']);
Route::get('/foundations/{id}', [FoundationController::class, 'show']);
Route::get('/inventories',    [InventoryController::class, 'index']);
Route::get('/workshops',      [WorkshopController::class, 'index']);

// Protected Routes ---------------------------------------------------------------------------
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Users
    Route::get('/users', [UserController::class, 'index']);
    Route::get('/users/me', [UserController::class, 'me']);
    Route::put('/users/me', [UserController::class, 'update']);
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::get('/users/{id}/portfolio', [UserController::class, 'portfolio']);

    // Uploads
    Route::post('/uploads', [UploadController::class, 'store']);

    // Foundations (write)
    Route::post('/foundations', [FoundationController::class, 'store']);
    Route::put('/foundations/{id}', [FoundationController::class, 'update']);
    Route::patch('/foundations/{id}/verify', [FoundationController::class, 'verify']);
    Route::delete('/foundations/{id}', [FoundationController::class, 'destroy']);
    Route::get('/foundations/{id}/analytics', [FoundationController::class, 'analytics']);

    // Inventories
    Route::get('/foundations/{id}/inventories', [InventoryController::class, 'byFoundation']);
    Route::get('/inventories/{id}', [InventoryController::class, 'show']);
    Route::post('/foundations/{id}/inventories', [InventoryController::class, 'store']);
    Route::put('/inventories/{id}', [InventoryController::class, 'update']);
    Route::delete('/inventories/{id}', [InventoryController::class, 'destroy']);

    // Donations
    Route::get('/donations', [DonationController::class, 'index']);
    Route::get('/donations/me', [DonationController::class, 'mine']);
    Route::get('/foundations/{id}/donations', [DonationController::class, 'byFoundation']);
    Route::get('/donations/{id}', [DonationController::class, 'show']);
    Route::post('/donations', [DonationController::class, 'store']);
    Route::patch('/donations/{id}/status', [DonationController::class, 'updateStatus']);
    Route::get('/donations/{id}/qr', [DonationController::class, 'getQr']);
    Route::post('/donations/verify-qr', [DonationController::class, 'verifyQr']);

    // Workshops
    Route::get('/foundations/{id}/workshops', [WorkshopController::class, 'byFoundation']);
    Route::get('/workshops/{id}', [WorkshopController::class, 'show']);
    Route::post('/foundations/{id}/workshops', [WorkshopController::class, 'store']);
    Route::put('/workshops/{id}', [WorkshopController::class, 'update']);
    Route::post('/workshops/{id}/register', [WorkshopController::class, 'register']);
    Route::post('/workshops/{id}/checkin', [WorkshopController::class, 'checkin']);
    Route::patch('/workshops/{id}/volunteers/{uid}/status', [WorkshopController::class, 'updateVolunteerStatus']);
    Route::delete('/workshops/{id}/register', [WorkshopController::class, 'unregister']);
    Route::patch('/workshops/{id}/status', [WorkshopController::class, 'updateStatus']);
});
