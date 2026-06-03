<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Donation extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'donations';

    protected $fillable = [
        'donor_id', 'foundation_id', 'inventory_id',
        'type', 'item_detail', 'status', 'history_logs',
        'qr_code_hash', 'is_anonymous',
    ];

    protected $casts = [
        'is_anonymous'  => 'boolean',
    ];

    public function addHistoryLog(string $status, string $note, ?string $proofImage = null): void
    {
        $log = [
            'status'    => $status,
            'timestamp' => now(),
            'note'      => $note,
        ];
        if ($proofImage) $log['proof_image'] = $proofImage;

        $logs = $this->history_logs ?? [];
        $logs[] = $log;
        $this->update([
            'status'       => $status,
            'history_logs' => $logs,
        ]);
    }

    public function foundation()
    {
        return $this->belongsTo(Foundation::class, 'foundation_id');
    }
}
