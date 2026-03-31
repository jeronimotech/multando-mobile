import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/colors.dart';
import '../../providers/reports_provider.dart';

/// Step 2: Confirm vehicle details, plate number, location.
class ConfirmStep extends ConsumerStatefulWidget {
  const ConfirmStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  ConsumerState<ConfirmStep> createState() => _ConfirmStepState();
}

class _ConfirmStepState extends ConsumerState<ConfirmStep> {
  final _plateController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedVehicleType;
  bool _locationLoaded = false;

  static const _vehicleTypes = [
    ('car', 'Car', Icons.directions_car),
    ('motorcycle', 'Motorcycle', Icons.two_wheeler),
    ('truck', 'Truck', Icons.local_shipping),
    ('bus', 'Bus', Icons.directions_bus),
    ('van', 'Van', Icons.airport_shuttle),
    ('bicycle', 'Bicycle', Icons.pedal_bike),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _plateController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // accuracy: LocationAccuracy.high),
      );
      ref.read(newReportProvider.notifier).setLocation(
            position.latitude,
            position.longitude,
            null, // Address is resolved on the backend
          );
      setState(() => _locationLoaded = true);
    } catch (_) {
      // Fallback - user can adjust manually
    }
  }

  @override
  Widget build(BuildContext context) {
    final newReport = ref.watch(newReportProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 2: Vehicle Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: MultandoColors.surface900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the vehicle plate number and select the vehicle type.',
            style: TextStyle(color: MultandoColors.surface500, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Plate number
          TextFormField(
            controller: _plateController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Plate Number',
              prefixIcon: Icon(Icons.confirmation_number),
              hintText: 'e.g. ABC-1234',
            ),
            onChanged: (v) =>
                ref.read(newReportProvider.notifier).setPlateNumber(v.trim()),
          ),
          const SizedBox(height: 24),

          // Vehicle type
          const Text(
            'Vehicle Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MultandoColors.surface700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _vehicleTypes.map((vt) {
              final isSelected = _selectedVehicleType == vt.$1;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedVehicleType = vt.$1);
                  ref.read(newReportProvider.notifier).setVehicleType(vt.$1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: (MediaQuery.of(context).size.width - 48) / 3,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MultandoColors.brandRed.withAlpha(20)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? MultandoColors.brandRed
                          : MultandoColors.surface300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        vt.$3,
                        color: isSelected
                            ? MultandoColors.brandRed
                            : MultandoColors.surface500,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vt.$2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? MultandoColors.brandRed
                              : MultandoColors.surface600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Location
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _locationLoaded
                  ? MultandoColors.success.withAlpha(15)
                  : MultandoColors.surface100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _locationLoaded
                    ? MultandoColors.success.withAlpha(60)
                    : MultandoColors.surface300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _locationLoaded ? Icons.location_on : Icons.location_searching,
                  color: _locationLoaded
                      ? MultandoColors.success
                      : MultandoColors.surface400,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _locationLoaded ? 'Location captured' : 'Getting location...',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _locationLoaded
                              ? MultandoColors.success
                              : MultandoColors.surface600,
                        ),
                      ),
                      if (_locationLoaded && newReport.latitude != null)
                        Text(
                          '${newReport.latitude!.toStringAsFixed(6)}, ${newReport.longitude!.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: MultandoColors.surface400,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!_locationLoaded)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MultandoColors.surface400,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description
          TextFormField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              prefixIcon: Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
            onChanged: (v) =>
                ref.read(newReportProvider.notifier).setDescription(v),
          ),
          const SizedBox(height: 32),

          // Navigation
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: (newReport.plateNumber.isNotEmpty && _locationLoaded)
                      ? widget.onNext
                      : null,
                  child: const Text('Review'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
