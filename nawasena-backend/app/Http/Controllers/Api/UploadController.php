<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class UploadController extends Controller
{
    /**
     * POST /api/uploads
     * Mengunggah file gambar ke storage.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'file'   => 'required|file|mimes:jpg,jpeg,png,webp,pdf,docx|max:5120',
            'folder' => 'nullable|string|in:avatars,foundations,donations,docs',
        ]);

        $folder   = $request->input('folder', 'uploads');
        $filename = Str::uuid() . '.' . $request->file('file')->getClientOriginalExtension();
        $path     = "{$folder}/{$filename}";

        Storage::disk('public')->put($path, file_get_contents($request->file('file')));

        $url = asset("storage/{$path}");

        return response()->json(['url' => $url], 201);
    }
}
