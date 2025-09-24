import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class SignalStrength extends StatefulWidget {
  const SignalStrength({super.key});

  @override
  State<SignalStrength> createState() => _SignalStrengthState();
}

class _SignalStrengthState extends State<SignalStrength> {
  String _wifiName = "Loading...";
  String _ipAddress = "Loading...";
  String _signalStrength = "Loading...";
  String _macAddress = "Loading...";
  String _channel = "Loading...";
  String _frequency = "Loading...";
  double _signalPercent = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchWifiDetails();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _fetchWifiDetails();
      }
    });
  }

  Future<void> _fetchWifiDetails() async {
    try {
      await _requestPermissions();
      await _fetchConnectedWifi();
      await _fetchWifiNetworks();
      await _fetchAdditionalWifiDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  Future<void> _fetchConnectedWifi() async {
    final wifiName = await WiFiForIoTPlugin.getSSID();
    if (mounted) {
      setState(() {
        _wifiName = wifiName ?? "Not connected";
      });
    }
  }

  Future<void> _fetchWifiNetworks() async {
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) return;

    await WiFiScan.instance.startScan();
    final results = await WiFiScan.instance.getScannedResults();

    if (results.isEmpty || !mounted) return;

    try {
      final connectedNetwork = results.firstWhere(
            (network) => network.ssid == _wifiName,
      );

      if (mounted) {
        setState(() {
          _signalStrength = "${connectedNetwork.level} dBm";
          _signalPercent = _calculateSignalPercent(connectedNetwork.level);
          _channel = connectedNetwork.channelWidth.toString();
          _frequency = "${connectedNetwork.frequency} MHz";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _signalStrength = "Not available";
          _signalPercent = 0.0;
        });
      }
    }
  }

  Future<void> _fetchAdditionalWifiDetails() async {
    final ipAddress = await WiFiForIoTPlugin.getIP();
    final bssid = await WiFiForIoTPlugin.getBSSID();

    if (mounted) {
      setState(() {
        _ipAddress = ipAddress ?? "Not available";
        _macAddress = bssid ?? "Not available";
      });
    }
  }

  double _calculateSignalPercent(int rssi) {
    return ((rssi + 100) / 70).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1622),
      appBar: AppBar(
        backgroundColor: const Color(0xff1A293E),
        title: const Text(
          "Signal Strength",
          style: TextStyle(
            color: Color(0xffF7F7F7),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xffF7F7F7)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xff1A293E),
                    radius: 14,
                    child: const Icon(
                      Icons.wifi,
                      color: Color(0xff5178AE),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    _wifiName,
                    style: const TextStyle(
                      color: Color(0xffF7F7F7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              CircularPercentIndicator(
                radius: 66,
                progressColor: const Color(0xffFFCD43),
                backgroundColor: const Color(0xff1A293E),
                lineWidth: 15,
                percent: _signalPercent,
                center: Text(
                  "${(_signalPercent * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                height: 218,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xff1A293E),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: const Color(0xff27436A)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoRow("Signal:", _signalStrength),
                      _buildInfoRow("IP:", _ipAddress),
                      _buildInfoRow("MAC:", _macAddress),
                      _buildInfoRow("Channel:", _channel),
                      _buildInfoRow("Frequency:", _frequency),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}