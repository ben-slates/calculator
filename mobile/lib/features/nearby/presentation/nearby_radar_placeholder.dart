import 'package:flutter/material.dart';

class NearbyRadarPlaceholder extends StatelessWidget {
  const NearbyRadarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text('Nearby users radar: BLE discovery feed goes here.'),
      ),
    );
  }
}
