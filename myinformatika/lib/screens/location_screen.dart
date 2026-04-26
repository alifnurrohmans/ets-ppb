import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myinformatika/services/location_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _locationService = LocationService();
  bool _isLoadingLocation = false;
  Position? _currentPosition;
  String? _errorMessage;
  Stream<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final hasLocationEnabled = await _locationService.isLocationServiceEnabled();
      if (!hasLocationEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
        });
        return;
      }

      final permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        await _locationService.requestLocationPermission();
      } else if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission is denied permanently. Please enable it in settings.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking location permission: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _startLocationTracking() {
    _positionStream = _locationService.getPositionStream();
    setState(() {});
  }

  void _stopLocationTracking() {
    setState(() {
      _positionStream = null;
    });
  }

  Future<void> _openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Location'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Current Location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 16),
            _buildLocationCard(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: _isLoadingLocation
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Get Current Location'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _positionStream == null
                  ? _startLocationTracking
                  : _stopLocationTracking,
              icon: Icon(_positionStream == null
                  ? Icons.location_searching
                  : Icons.pause),
              label: Text(_positionStream == null
                  ? 'Start Location Tracking'
                  : 'Stop Location Tracking'),
            ),
            const SizedBox(height: 12),
            if (_errorMessage?.contains('disabled') ?? false)
              ElevatedButton.icon(
                onPressed: _openLocationSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Open Location Settings'),
              ),
            const SizedBox(height: 24),
            if (_positionStream != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Real-time Tracking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<Position>(
                    stream: _positionStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final position = snapshot.data!;
                      return _buildLocationCard(position: position);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard({Position? position}) {
    final pos = position ?? _currentPosition;

    if (pos == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(
                Icons.location_off,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text(
                'No location data available',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap "Get Current Location" to fetch your location',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationItem('Latitude', pos.latitude.toString()),
            const SizedBox(height: 12),
            _buildLocationItem('Longitude', pos.longitude.toString()),
            const SizedBox(height: 12),
            _buildLocationItem('Altitude', '${pos.altitude.toStringAsFixed(2)} m'),
            const SizedBox(height: 12),
            _buildLocationItem('Accuracy', '${pos.accuracy.toStringAsFixed(2)} m'),
            const SizedBox(height: 12),
            _buildLocationItem('Speed', '${pos.speed.toStringAsFixed(2)} m/s'),
            const SizedBox(height: 12),
            _buildLocationItem('Timestamp', pos.timestamp.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
