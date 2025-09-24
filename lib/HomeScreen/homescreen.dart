import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled1/Privacy%20Policy/policy.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../Alot Dialoug/dialaug_box.dart';
import '../Bottom bar/bottombar.dart';
import '../Heat Map/heatmap.dart';
import '../Notification/notification.dart';
import '../QRcode/qrcodescanner.dart';
import '../Signal Strength/signal_strength.dart';
import '../Speed test/speed_test.dart';
import '../bottom_navigationBar/bottom_navigation.dart';
import 'package:location/location.dart' hide PermissionStatus;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _wifiName = "New Heaven";
  String _ipAddress = "192.168.1.28";
  String _speed = "65/mbps";

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
    _fetchWifiDetails();
    requestCameraPermission();

  }

  Future<bool> _checkAndRequestLocationPermission() async {
    // 1. Request location permission
    PermissionStatus permissionStatus = await Permission.location.status;
    if (!permissionStatus.isGranted) {
      permissionStatus = await Permission.location.request();
      if (!permissionStatus.isGranted) {
        // Permission denied.
        return false;
      }
    }

    // 2. Check if location services are enabled
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // User did not enable location services
        return false;
      }
    }

    return true; // Permission granted and service enabled
  }
  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  Future<void> _disconnectFromWifi() async {
    try {
      final isDisconnected = await WiFiForIoTPlugin.disconnect();
      if (!mounted) return;

      setState(() {
        _wifiName = "Not Connected";
        _ipAddress = "0.0.0.0";
        _speed = "0/mbps";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isDisconnected
            ? "Disconnected from Wi-Fi"
            : "Failed to disconnect")),
      );

      if (isDisconnected) {
        showDialog(
          context: context,
          builder: (context) => const DialaugeBox(),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _fetchWifiDetails() async {
    try {
      final wifiName = await WiFiForIoTPlugin.getSSID();
      final ipAddress = await WiFiForIoTPlugin.getIP();
      if (!mounted) return;

      setState(() {
        _wifiName = wifiName ?? "Not Connected";
        _ipAddress = ipAddress ?? "0.0.0.0";
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

@override

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xff27436A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xffE4BC48), size: 30),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xffF7F7F7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1622),
      drawer: Drawer(
        backgroundColor: const Color(0xff1A293E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xff27436A),
              ),
              child: Center(
                child: Text(
                  "Wifi Analyzer",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xffF7F7F7),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xff27436A),
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(25),
                  bottomEnd: Radius.circular(25),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.home_outlined, color: Color(0xffE4BC48)),
                title: const Text(
                  'Home',
                  style: TextStyle(
                    color: Color(0xffF7F7F7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BottomNavigationBarExample()),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.wifi, color: Color(0xffE4BC48)),
              title: const Text(
                'Speed Test',
                style: TextStyle(
                  color: Color(0xffF7F7F7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SpeedTest()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Color(0xffE4BC48)),
              title: const Text(
                'Wifi QR',
                style: TextStyle(
                  color: Color(0xffF7F7F7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRscanner()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined, color: Color(0xffE4BC48)),
              title: const Text(
                'Heat Map',
                style: TextStyle(
                  color: Color(0xffF7F7F7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ARWiFiHeatmap()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined, color: Color(0xffE4BC48)),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  color: Color(0xffF7F7F7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notificationss()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.grade_outlined, color: Color(0xffE4BC48)),
              title: const Text(
                'Rate us',
                style: TextStyle(
                  color: Color(0xffF7F7F7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return BottomBar();
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.gpp_maybe_outlined, color: Color(0xffE4BC48)),
              title: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Color(0xffF7F7F7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => privacy_policy()),
                );              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xff1A293E),
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(
            "WiFi Analyzer",
            style: TextStyle(
              color: Color(0xffF7F7F7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color(0xffF7F7F7),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notificationss()),
                );
              },
              child: const Icon(Icons.notifications, color: Color(0xffF7F7F7)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 90,
                  width: double.infinity,
                  color: const Color(0xff1A293E),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xff263851),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 14),
                              Text(
                                _wifiName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _ipAddress,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 7),
                              InkWell(
                                onTap: _disconnectFromWifi,
                                child: Container(
                                  width: 88,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff2A4F83),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Disconnect",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi, size: 60, color: Color(0xffFFCD43)),
                              const SizedBox(height: 5),
                              Text(
                                _speed,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureButton(
                          icon: Icons.wifi,
                          label: 'Speed Test',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SpeedTest()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildFeatureButton(
                          icon: Icons.qr_code_scanner,
                          label: 'Wi-Fi QR',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QRscanner()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureButton(
                          icon: Icons.signal_cellular_alt,
                          label: 'Signal Strength',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignalStrength()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildFeatureButton(
                          icon: Icons.map_outlined,
                          label: 'Heat Map',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ARWiFiHeatmap()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}