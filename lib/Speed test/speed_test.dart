import 'package:flutter/material.dart';
import 'package:flutter_speedtest/flutter_speedtest.dart';
import 'dart:io';  // Import for SocketException

class SpeedTest extends StatefulWidget {
  const SpeedTest({super.key});

  @override
  State<SpeedTest> createState() => _SpeedTestState();
}

class _SpeedTestState extends State<SpeedTest> {
  // Variables for Speed Test
  double _downloadSpeed = 0.0;
  double _uploadSpeed = 0.0;
  double _downloadProgress = 0.0;
  double _uploadProgress = 0.0;
  bool _isTesting = false;
  bool _testCompleted = false;
  String _status = "Ready";
  bool _errorOccurred = false;

  // Instance of the FlutterSpeedtest class from flutter_speedtest
  final FlutterSpeedtest _speedTest = FlutterSpeedtest(
    baseUrl: 'http://speedtest.jaosing.com:8080', // Your custom server URL
    pathDownload: '/download',
    pathUpload: '/upload',
    pathResponseTime: '/ping',
  );

  // UI for Speed Card
  Widget _buildSpeedCard({
    required String title,
    required double speed,
    required double progress,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1A293E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xffA0A0A0),
                  fontSize: 14,
                ),
              ),
              Icon(icon, color: const Color(0xffFFCD43)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${speed.toStringAsFixed(1)} Mbps',
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xff0D1622),
            color: const Color(0xffFFCD43),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            "${(progress * 100).toStringAsFixed(0)}%",
            style: const TextStyle(
              color: Color(0xffA0A0A0),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Handle the test start process
  void _startTest() async {
    try {
      setState(() {
        _isTesting = true;
        _testCompleted = false;
        _status = "Testing...";
      });

      await _speedTest.getDataspeedtest(
        downloadOnProgress: (percent, transferRate) {
          setState(() {
            _downloadProgress = percent.clamp(0.0, 1.0);
            _downloadSpeed = transferRate ;
          });
        },
        uploadOnProgress: (percent, transferRate) {
          setState(() {
            _uploadProgress = percent.clamp(0.0, 1.0);
            _uploadSpeed = transferRate /100 ;
          });
        },
        progressResponse: (responseTime, jitter) {
          setState(() {
            // Handle response time and jitter
          });
        },
        onError: (errorMessage) {
          setState(() {
            _errorOccurred = true;
            _status = 'Error!';
          });
        },
        onDone: () {
          setState(() {
            _testCompleted = true;
            _status = 'Test Completed';
          });
        },
      );
    } catch (e) {
      if (e is SocketException) {
        setState(() {
          _errorOccurred = true;
          _status = 'No internet connection';
        });
      } else {
        setState(() {
          _errorOccurred = true;
          _status = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1622),
      appBar: AppBar(
        title: const Text(
          "Speed Test",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff1A293E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSpeedCard(
                    title: "DOWNLOAD",
                    speed: _downloadSpeed,
                    progress: _downloadProgress,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSpeedCard(
                    title: "UPLOAD",
                    speed: _uploadSpeed,
                    progress: _uploadProgress,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xff1A293E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _errorOccurred
                        ? Icons.error_outline
                        : _testCompleted
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color: _errorOccurred
                        ? Colors.red
                        : _testCompleted
                        ? Colors.green
                        : const Color(0xffFFCD43),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _status,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isTesting ? null : _startTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1A293E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isTesting ? "TESTING..." : "START TEST",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
