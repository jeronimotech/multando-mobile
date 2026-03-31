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
  if (!client.isInitialized) return [];
  final result = await client.reports.list(pageSize: 50);
  return result.items;
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(18.4861, -69.9312); // Santo Domingo default
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
        desiredAccuracy: LocationAccuracy.high, // accuracy: LocationAccuracy.high),
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
    } catch (_) {
      // Fallback to default position
    }
  }

  Set<Marker> _buildMarkers(List reports) {
    final markers = <Marker>{};
    // Current location marker
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

    // Report markers
    for (final report in reports) {
      // Reports from the list endpoint don't include location;
      // in production, we'd use a dedicated geo-search endpoint.
      // For now, generate nearby offsets for demo.
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
          // Location button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'location',
              backgroundColor: Colors.white,
              onPressed: _loadLocation,
              child: const Icon(Icons.my_location, color: MultandoColors.brandRed),
            ),
          ),
          // AI Chat button
          Positioned(
            bottom: 100,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: 'chat',
              backgroundColor: MultandoColors.brandRed,
              onPressed: () => context.push('/chat'),
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/new'),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Report Violation'),
      ),
      bottomNavigationBar: const MultandoBottomNavBar(currentIndex: 0),
    );
  }
}
