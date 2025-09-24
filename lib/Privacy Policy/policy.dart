import 'package:flutter/material.dart';
class privacy_policy extends StatelessWidget {
  const privacy_policy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0D1622),
      appBar: AppBar(
        title: Text("Privacy Policy",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 14),),
        centerTitle: true,
        backgroundColor: Color(0xff1A293E),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text('''
        Privacy Policy

Effective Date: [Insert Date]

Your privacy is important to us. This Privacy Policy explains how [Your App Name] ("we", "our", or "us") collects, uses, and protects your information when you use our mobile application.

1. Information We Collect
We may collect the following information from you while you use the app:

Location Data: We collect precise GPS location to provide real-time AR WiFi heatmaps and help visualize WiFi signal strength in your environment.

Camera Access: The app uses your device's camera to display augmented reality content. We do not store or transmit any images or video from your camera.

Compass/Heading Data: We access device orientation to determine your direction of movement and update AR overlays accordingly.

WiFi Signal Data: We access the currently connected WiFi network's signal strength to generate accurate heatmaps. We do not collect or share WiFi names (SSIDs) or passwords.

Device Information: Basic device data (e.g., OS version, device model) may be collected to help us improve app performance.

2. How We Use Your Information
We use the collected information to:

Generate and update AR WiFi heatmaps.

Improve accuracy and user experience within the app.

Debug issues and enhance performance.

We do not sell or share your personal information with third parties.

3. Data Storage
All data processing is done locally on your device. We do not store, upload, or transmit any personal or location data to our servers or any external third parties.

4. Permissions
To function properly, our app requires the following permissions:

Camera: To display AR content.

Location: To track movement and place AR heatmap tiles.

WiFi Information: To assess the current signal strength.

Compass/Orientation: To rotate AR elements based on your direction.

You may revoke permissions at any time in your device settings, but doing so may affect app functionality.

5. Children's Privacy
Our app is not intended for use by children under the age of 13. We do not knowingly collect any personal data from children.

6. Changes to This Privacy Policy
We may update this policy from time to time. Any changes will be reflected in this document, and the effective date will be updated at the top.

7. Contact Us
If you have any questions or concerns about this Privacy Policy, you can contact us at:

[Your Name or Company Name]
Email: [Your Contact Email]
Website: [Your Website, if any]
        ''',style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }
}
