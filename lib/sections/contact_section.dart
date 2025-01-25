import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  Future<Map<String, dynamic>> _loadContactInfo() async {
    final String jsonString = await rootBundle.loadString('contact_info.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return jsonData['contact_info'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadContactInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Failed to load contact info."));
        }

        final contactInfo = snapshot.data;

        if (contactInfo == null) {
          return const Center(child: Text("No contact information available."));
        }

        return Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [Colors.black, Colors.transparent],
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'images/contact.png',
                  height: MediaQuery.of(context).size.height * 0.35,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Get in Touch",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildContactButton(
                label: contactInfo['phone']['number'],
                icon: Icons.call_outlined,
                color: Colors.greenAccent,
                onPressed: () => _makePhoneCall(contactInfo['phone']['number'], context),
              ),
              const SizedBox(height: 20),
              _buildContactButton(
                label: contactInfo['telegram']['id'],
                icon: Icons.telegram_outlined,
                color: Colors.lightBlueAccent,
                onPressed: () => _openLink(contactInfo['telegram']['link'], context),
              ),
              const SizedBox(height: 20),
              _buildContactButton(
                label: contactInfo['email']['address'],
                icon: Icons.email_outlined,
                color: Colors.redAccent,
                onPressed: () => _openMailApp(contactInfo['email']['address'], "", "", context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        iconColor: Colors.black,
        minimumSize: const Size(300, 52),
      ),
      label: Text(label),
      icon: Icon(icon),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showErrorDialog(context, "Unable to make the call. Please try again.");
    }
  }

  Future<void> _openLink(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorDialog(context, "Unable to open the link. Please try again.");
    }
  }

  Future<void> _openMailApp(String email, String subject, String body, BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorDialog(context, "Unable to open the mail app. Please try again later.");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
