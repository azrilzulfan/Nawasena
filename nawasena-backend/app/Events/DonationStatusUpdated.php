<?php

namespace App\Events;

use App\Models\Donation;
use Illuminate\Broadcasting\Channel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Queue\SerializesModels;

class DonationStatusUpdated
{
    use SerializesModels;

    public function __construct(public Donation $donation) {}

    public function broadcastOn(): array
    {
        return [new Channel("donation.{$this->donation->id}")];
    }

    public function broadcastWith(): array
    {
        return [
            'id'     => $this->donation->id,
            'status' => $this->donation->status,
        ];
    }
}
