import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/api_client.dart';
import '../../../core/colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/multando_app_bar.dart';

/// Provider for nearby reports shown on the map.
final _nearbyReportsProvider = FutureProvider.autoDispose((ref) async {
  final client = ref.watch(apiClientProvider);
  if (!client.isInitialized || !client.isAuthenticated) return [];
  try {
    final result = await client.reports.list(pageSize: 50);
    return result.items;
  } catch (_) {
    return [];
  }
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(4.7110, -74.0721); // Bogotá default
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _locationLoaded = true;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
      }
    } catch (_) {}
  }

  Set<Marker> _buildMarkers(List reports) {
    final markers = <Marker>{};
    if (_locationLoaded) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: _currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }
    for (final report in reports) {
      markers.add(
        Marker(
          markerId: MarkerId(report.id),
          position: LatLng(
            _currentPosition.latitude + (reports.indexOf(report) * 0.001),
            _currentPosition.longitude + (reports.indexOf(report) * 0.0008),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            report.status.value == 'verified'
                ? BitmapDescriptor.hueGreen
                : report.status.value == 'rejected'
                    ? BitmapDescriptor.hueRed
                    : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: report.plateNumber,
            snippet: report.status.value.replaceAll('_', ' '),
          ),
          onTap: () => context.push('/reports/${report.id}'),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(_nearbyReportsProvider);

    return Scaffold(
      appBar: const MultandoAppBar(title: 'Multando', showLogo: true),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: reportsAsync.when(
              data: _buildMarkers,
              loading: () => {},
              error: (_, __) => {},
            ),
          ),

          // AI Chat banner at top
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => context.push('/chat'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: MultandoColors.brandRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report with Multa AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Send a photo and I\'ll handle the rest',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  ],
                ),
              ),
            ),
          ),

          // Location button
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'location',
              backgroundColor: Colors.white,
              onPressed: _loadLocation,
              child: const Icon(Icons.my_location, color: MultandoColors.brandRed),
            ),
          ),

          // Manual report button (secondary)
          Positioned(
            bottom: 90,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: 'manual',
              backgroundColor: Colors.white,
              onPressed: () => context.push('/reports/new'),
              child: const Icon(Icons.edit_note, color: MultandoColors.surface600),
            ),
          ),
        ],
      ),
      // Primary FAB — Chat with Multa AI
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat'),
        backgroundColor: MultandoColors.brandRed,
        icon: const Icon(Icons.smart_toy),
        label: const Text('Chat with Multa'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const MultandoBottomNavBar(currentIndex: 0),
    );
  }
}
