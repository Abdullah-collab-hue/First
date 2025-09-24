import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

class Wifi_Networks extends StatefulWidget {
  const Wifi_Networks({super.key});

  @override
  State<Wifi_Networks> createState() => _Wifi_NetworksState();
}

class _Wifi_NetworksState extends State<Wifi_Networks> {
  List<WiFiAccessPoint> _availableNetworks = [];
  bool _isLoading = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
  }

  Future<void> _checkPermissionsAndScan() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      _startScan();
    } else {
      setState(() => _permissionDenied = true);
    }
  }

  Future<void> _startScan() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });

    try {
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan != CanStartScan.yes) {
        throw "Cannot start scan: $canScan";
      }

      final success = await WiFiScan.instance.startScan();
      if (!success) {
        throw "Failed to start scan";
      }

      final results = await WiFiScan.instance.getScannedResults();
      if (!mounted) return;

      setState(() => _availableNetworks = results);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestPermissionAndScan() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _startScan();
    } else {
      setState(() => _permissionDenied = true);
    }
  }

  IconData _getSignalIcon(int level) {
    if (level >= -50) return Icons.signal_wifi_4_bar_sharp;
    if (level >= -70) return Icons.network_wifi_3_bar_rounded;
    return Icons.signal_wifi_0_bar;
  }

  Color _getSignalColor(int level) {
    if (level >= -50) return const Color(0xff00EE34);
    if (level >= -70) return const Color(0xffFFC838);
    return const Color(0xffFF4848);
  }

  Widget _buildNetworkList() {
    if (_permissionDenied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Location permission required",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermissionAndScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff214C88),
              ),
              child: const Text(
                "Grant Permission",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_availableNetworks.isEmpty) {
      return Center(
        child: Text(
          _isLoading ? "Scanning..." : "No networks found",
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: _availableNetworks.map((network) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 34),
              child: Container(
                width: double.infinity,
                height: 83,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1,
                    color: const Color(0xff27436A),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            network.ssid,
                            style: const TextStyle(
                              color: Color(0xffF7F7F7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            network.bssid,
                            style: const TextStyle(
                              color: Color(0xffF7F7F7),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Text(
                            "[WPA2-PSK-CCMP+TKIP][WPS][ESS]",
                            style: TextStyle(
                              color: Color(0xffF7F7F7),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        _getSignalIcon(network.level),
                        color: _getSignalColor(network.level),
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1622),
      appBar: AppBar(
        title: const Text(
          "Available Networks",
          style: TextStyle(
            color: Color(0xffF7F7F7),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff1A293E),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xffF7F7F7)),
            onPressed: _isLoading ? null : _startScan,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildNetworkList(),
    );
  }
}