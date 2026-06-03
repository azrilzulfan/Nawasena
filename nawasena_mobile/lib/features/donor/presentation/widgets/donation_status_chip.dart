import 'package:flutter/material.dart';
import 'package:nawasena_mobile/features/donor/data/models/donation_model.dart';

class DonationStatusChip extends StatelessWidget {
  final DonationStatus status;
  const DonationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: status.color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize:   11,
              fontWeight: FontWeight.w700,
              color:      status.color,
            ),
          ),
        ],
      ),
    );
  }
}