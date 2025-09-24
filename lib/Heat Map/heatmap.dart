import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:camera/camera.dart';


class ARWiFiHeatmap extends StatefulWidget {
  const ARWiFiHeatmap({Key? key}) : super(key: key);

  @override
  _ARWiFiHeatmapState createState() => _ARWiFiHeatmapState();
}

class Tile {
  final Offset position;
  final int signalStrength;
  Tile(this.position, this.signalStrength);
}

class _ARWiFiHeatmapState extends State<ARWiFiHeatmap> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  LocationData? currentLocation;
  LocationData? previousLocation;
  double heading = 0;
  int signalStrength = -100;
  final List<Tile> tiles = [];
  final Set<String> visitedCells = {}; // To avoid duplicates
  Offset currentOffset = Offset.zero; // Represents the user's "world" position relative to the map origin
  final double tileSpacing = 1.0; // meters
  static const double pixelsPerMeter = 40.0;
  double minMovementThreshold = 0.5; // 0.5 meter

  // New state variables for controlling app mode and canvas navigation
  bool _isMappingActive = true; // Starts active as per original initState behavior
  bool _isCanvasNavigable = false; // Starts not navigable
  Offset _canvasPanOffset = Offset.zero; // Offset for canvas panning

  StreamSubscription<LocationData>? locationSub;
  StreamSubscription<CompassEvent>? compassSub;

  @override
  void initState() {
    super.initState();
    // Original initState behavior: start all sensors immediately
    _initWifiSignal();
    _startLocationUpdates();
    _startCompassUpdates();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _disposeSensors(); // Ensure all sensor subscriptions are cancelled
    super.dispose();
  }

  // Initializes the camera controller
  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      final backCamera = cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras!.first,
      );
      _cameraController = CameraController(backCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing camera: $e");
      // Optionally show a user-friendly message
    }
  }

  // Helper to start all sensor updates
  void _startSensors() {
    // Re-initialize if they were disposed (check for null before re-subscribing)
    _initWifiSignal();
    _startLocationUpdates();
    _startCompassUpdates();
  }

  // Helper to dispose all sensor subscriptions
  void _disposeSensors() {
    locationSub?.cancel();
    compassSub?.cancel();
    locationSub = null; // Set to null to indicate they are cancelled
    compassSub = null;
  }

  // Fetches initial WiFi signal strength
  Future<void> _initWifiSignal() async {
    final strength = await _getWifiSignalStrength();
    if (!mounted) return;
    setState(() => signalStrength = strength ?? -100);
  }

  // Gets current WiFi signal strength
  Future<int?> _getWifiSignalStrength() async {
    try {
      final isConnected = await WiFiForIoTPlugin.isConnected();
      if (isConnected) {
        return await WiFiForIoTPlugin.getCurrentSignalStrength();
      }
    } catch (e) {
      print("Error getting WiFi signal strength: $e");
    }
    return null;
  }

  // Starts listening for location updates
  void _startLocationUpdates() {
    Location location = Location();
    location.changeSettings(
      accuracy: LocationAccuracy.high, // Request highest accuracy
      interval: 1000, // Request updates every 1000 milliseconds (1 second)
      distanceFilter: 0, // Get updates even for small movements (0 meters)
    );
    // Only subscribe if not already subscribed
    if (locationSub == null) {
      locationSub = location.onLocationChanged.listen((loc) async {
        // Only process if mapping is active
        if (!_isMappingActive) return;

        if (previousLocation != null) {
          final distance = _calculateDistance(previousLocation!, loc);
          if (distance < minMovementThreshold) return; // Ignore small movements

          // --- ORIGINAL LOGIC FOR DX, DY CALCULATION ---
          final angle = (heading + 90) * pi / 180;
          final dx = cos(angle) * distance * pixelsPerMeter;
          final dy = sin(angle) * distance * pixelsPerMeter;
          // --- END ORIGINAL LOGIC ---

          setState(() {
            currentOffset -= Offset(dx, dy);
            _generateTiles();
          });
        }
        previousLocation = loc;
        currentLocation = loc;

        final strength = await _getWifiSignalStrength();
        if (strength != null) {
          setState(() => signalStrength = strength);
        }
      });
    }
  }

  // Starts listening for compass updates
  void _startCompassUpdates() {
    // Only subscribe if not already subscribed
    if (compassSub == null) {
      compassSub = FlutterCompass.events?.listen((event) {
        // Only process if mapping is active
        if (!_isMappingActive) return;
        if (event.heading != null) {
          setState(() => heading = event.heading!);
        }
      });
    }
  }

  // Calculates distance between two geographical points (Haversine formula)
  double _calculateDistance(LocationData start, LocationData end) {
    const double R = 6371000; // Earth radius in meters
    final dLat = (end.latitude! - start.latitude!) * pi / 180;
    final dLon = (end.longitude! - start.longitude!) * pi / 180;
    final lat1 = start.latitude! * pi / 180;
    final lat2 = end.latitude! * pi / 180;

    final a = sin(dLat/2) * sin(dLat/2) +
        cos(lat1) * cos(lat2) *
            sin(dLon/2) * sin(dLon/2);
    final c = 2 * atan2(sqrt(a), sqrt(1-a));
    return R * c;
  }

  // Generates a new heatmap tile at the current location
  void _generateTiles() {
    // Only generate tiles if mapping is active
    if (!_isMappingActive || currentLocation == null) return;

    // The tile position is exactly at the pointer's current offset
    final tileWorldPosition = currentOffset;

    // Use a rounded key for cell uniqueness to group nearby points
    final key = '${tileWorldPosition.dx.toStringAsFixed(1)}:${tileWorldPosition.dy.toStringAsFixed(1)}';


    if (!visitedCells.contains(key)) {
      visitedCells.add(key);
      setState(() {
        tiles.add(Tile(tileWorldPosition, signalStrength));
        // Keep the number of tiles manageable
        if (tiles.length > 1000) {
          tiles.removeRange(0, tiles.length - 1000);
        }
      });
    }
  }

  // Callback for pan gestures on the canvas
  void _onPanUpdate(DragUpdateDetails details) {
    // Only allow panning if canvas navigation is enabled
    if (_isCanvasNavigable) {
      setState(() {
        _canvasPanOffset += details.delta;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview (only visible when mapping is active)
          if (_isMappingActive && _cameraController != null && _cameraController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize!.height,
                  height: _cameraController!.value.previewSize!.width,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),
          // Static black background when not mapping
          if (!_isMappingActive)
            Container(color: Colors.black),

          // Heatmap Custom Painter, wrapped in GestureDetector for panning
          GestureDetector(
            onPanUpdate: _onPanUpdate, // Only pan, no zoom as requested
            child: CustomPaint(
              painter: HeatmapPainter(
                tiles,
                currentOffset,
                heading,
                _canvasPanOffset, // Pass pan offset to painter
                _isMappingActive, // Pass mapping active state to painter
              ),
              size: Size.infinite,
            ),
          ),

          // Compass/Direction Indicator (only visible when mapping is active)
          if (_isMappingActive)
            Center(
              child: Icon(Icons.arrow_upward, size: 32, color: Colors.blueAccent),
            ),

          // Current Signal Strength Display (always visible)
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Signal: ${signalStrength} dBm',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          // Start Button (Bottom Left)
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton.icon(
              onPressed: _isMappingActive ? null : () { // Disabled if mapping is already active
                setState(() {
                  _isMappingActive = true;
                  _isCanvasNavigable = false; // Disable canvas navigation when mapping
                  _canvasPanOffset = Offset.zero; // Reset pan offset on start
                });
                _startSensors(); // Re-start sensor subscriptions
              },
              icon: Icon(Icons.play_arrow),
              label: Text('Start Mapping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),

          // Stop Button (Bottom Right)
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: !_isMappingActive ? null : () { // Disabled if mapping is already stopped
                setState(() {
                  _isMappingActive = false;
                  _isCanvasNavigable = true; // Enable canvas navigation when stopped
                });
                _disposeSensors(); // Cancel sensor subscriptions
              },
              icon: Icon(Icons.stop),
              label: Text('Stop Mapping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeatmapPainter extends CustomPainter {
  final List<Tile> tiles;
  final Offset pointerOffset; // User's "world" position relative to map origin
  final double heading; // User's device heading
  final Offset canvasPanOffset; // User's manual pan offset for canvas navigation
  final bool isMappingActive; // To determine if heading rotation should apply

  HeatmapPainter(
      this.tiles,
      this.pointerOffset,
      this.heading,
      this.canvasPanOffset,
      this.isMappingActive,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.save(); // Save the canvas state before transformations

    // Always translate to the center of the screen first
    canvas.translate(center.dx, center.dy);

    if (isMappingActive) {
      // ORIGINAL AR Mapping Mode: Map rotates with device, user's current position is center
      canvas.rotate(-heading * pi / 180);
      canvas.translate(-pointerOffset.dx, -pointerOffset.dy);
    } else {
      // Navigation Mode: Map is fixed, user pans it
      // Apply the manual pan offset
      canvas.translate(canvasPanOffset.dx, canvasPanOffset.dy);
      // Then, apply the last known pointerOffset to position the fixed map
      // This `pointerOffset` is fixed when isMappingActive is false
      canvas.translate(-pointerOffset.dx, -pointerOffset.dy);
      // No rotation by heading in this mode
    }

    for (final tile in tiles) {
      final paint = Paint()
        ..color = dbmToColor(tile.signalStrength)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);


      final rect = Rect.fromCenter(center: tile.position, width: 20, height: 20);
      canvas.drawRect(rect, paint);

      final border = Paint()
        ..color = dbmToColor(tile.signalStrength).withAlpha((255 * 0.4).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRect(rect, border);
    }

    canvas.restore(); // Restore the canvas state
  }

  // Converts dBm signal strength to a color (green for strong, red for weak)
  static Color dbmToColor(int signal) {
    final clamped = signal.clamp(-100, -30); // Clamp values to a reasonable range
    final norm = (clamped + 100) / 70; // Normalize to 0-1
    final hue = (norm * 120).toDouble(); // Map to hue (0=red, 120=green)
    return HSLColor.fromAHSL(1, hue, 1.0, 0.5).toColor();
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) {
    // Repaint if any of the relevant properties change
    return oldDelegate.tiles != tiles ||
        oldDelegate.pointerOffset != pointerOffset ||
        oldDelegate.heading != heading ||
        oldDelegate.canvasPanOffset != canvasPanOffset ||
        oldDelegate.isMappingActive != isMappingActive;
  }
}
