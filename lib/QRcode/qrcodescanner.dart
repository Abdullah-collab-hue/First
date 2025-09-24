import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';

class QRscanner extends StatefulWidget {
  const QRscanner({super.key});

  @override
  State<QRscanner> createState() => _QRscannerState();
}

class _QRscannerState extends State<QRscanner> {
  String result = "Scan a QR code";
  bool isScanning = false;

  Future<void> scanQRCode() async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      result = "Scanning...";
    });

    await _requestPermissions();

    try {
      final scanResult = await BarcodeScanner.scan(
        options: const ScanOptions(
          strings: {
            'cancel': 'Cancel',
            'flash_on': 'Flash on',
            'flash_off': 'Flash off',
          },
          restrictFormat: [BarcodeFormat.qr],
          useCamera: -1,
          autoEnableFlash: false,
        ),
      );

      if (scanResult.rawContent.isNotEmpty) {
        _connectToWiFiFromQR(scanResult.rawContent);
      } else {
        setState(() {
          result = "No QR code found";
          isScanning = false;
        });
      }
    } on Exception catch (e) {
      setState(() {
        result = "Error: ${e.toString().replaceAll('BarcodeScanner.', '')}";
        isScanning = false;
      });
    }
  }

  Future<void> _connectToWiFiFromQR(String qrContent) async {
    if (qrContent.startsWith("WIFI:")) {
      final ssidMatch = RegExp(r'S:([^;]+);').firstMatch(qrContent);
      final passMatch = RegExp(r'P:([^;]*);').firstMatch(qrContent);
      final typeMatch = RegExp(r'T:([^;]+);').firstMatch(qrContent);

      final ssid = ssidMatch?.group(1) ?? '';
      final password = passMatch?.group(1) ?? '';
      final encryption = typeMatch?.group(1) ?? 'WPA';

      if (ssid.isNotEmpty) {
        await _connectToWiFi(ssid, password, encryption);
      } else {
        setState(() {
          result = "Invalid QR code (missing SSID)";
          isScanning = false;
        });
      }
    } else {
      setState(() {
        result = "Not a valid WiFi QR code";
        isScanning = false;
      });
    }
  }

  Future<void> _connectToWiFi(String ssid, String password, String encryption) async {
    try {
      bool connected = false;

      if (encryption == 'WPA' || encryption == 'WPA2') {
        connected = await WiFiForIoTPlugin.connect(ssid,
            password: password, security: NetworkSecurity.WPA);
      } else if (encryption == 'WEP') {
        connected = await WiFiForIoTPlugin.connect(ssid,
            password: password, security: NetworkSecurity.WEP);
      } else if (encryption == 'nopass') {
        connected = await WiFiForIoTPlugin.connect(ssid,
            security: NetworkSecurity.NONE);
      }

      setState(() {
        result = connected ? "Connected to $ssid" : "Failed to connect to $ssid";
        isScanning = false;
      });
    } catch (e) {
      setState(() {
        result = "Connection error: $e";
        isScanning = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1622),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xffFFCD43),
                  width: 10,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 100,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Point camera at QR code",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ScannerOverlayPainter(
                        borderColor: const Color(0xffFFCD43),
                        cutOutSize: MediaQuery.of(context).size.width * 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                result,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: isScanning ? null : scanQRCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff214C88),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isScanning ? "Scanning..." : "Scan QR Code",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double cutOutSize;

  _ScannerOverlayPainter({
    required this.borderColor,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final center = Offset(size.width / 2, size.height / 2);
    final cutOutRect = Rect.fromCenter(
      center: center,
      width: cutOutSize,
      height: cutOutSize,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    canvas.drawRect(
      cutOutRect,
      Paint()
        ..color = Colors.transparent
        ..blendMode = BlendMode.clear,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(cutOutRect, borderPaint);

    final cornerLength = cutOutSize * 0.1;
    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawLine(
        cutOutRect.topLeft, cutOutRect.topLeft + Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(
        cutOutRect.topLeft, cutOutRect.topLeft + Offset(0, cornerLength), cornerPaint);

    // Top-right
    canvas.drawLine(
        cutOutRect.topRight, cutOutRect.topRight - Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(
        cutOutRect.topRight, cutOutRect.topRight + Offset(0, cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(
        cutOutRect.bottomLeft, cutOutRect.bottomLeft + Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(
        cutOutRect.bottomLeft, cutOutRect.bottomLeft - Offset(0, cornerLength), cornerPaint);

    // Bottom-right
    canvas.drawLine(
        cutOutRect.bottomRight, cutOutRect.bottomRight - Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(
        cutOutRect.bottomRight, cutOutRect.bottomRight - Offset(0, cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
