import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/celestial_background.dart';
import '../widgets/holographic_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("About Me", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3.0, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CelestialBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              HolographicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("CONTACT CHANNELS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
                      title: const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("yadavsatyam7346@gmail.com"),
                      trailing: const Icon(Icons.open_in_new, size: 16),
                      onTap: () => _launchUrl("mailto:yadavsatyam7346@gmail.com"),
                    ),
                    ListTile(
                      leading: Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
                      title: const Text("LinkedIn", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Satyam Yadav"),
                      trailing: const Icon(Icons.open_in_new, size: 16),
                      onTap: () => _launchUrl("https://www.linkedin.com/in/satyam-yadav-58a6a6323/"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              HolographicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DEVELOPER ARCHIVE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                    const SizedBox(height: 16),
                    _buildRow("Name", "Satyam Yadav"),
                    _buildRow("University", "GLA University, Mathura"),
                    _buildRow("University Roll", "2342010578"),
                    _buildRow("Class Roll", "46"),
                    _buildRow("Section", "A"),
                    _buildRow("Dept / Year", "BCA - 3rd Year"),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: Icon(Icons.code, color: Theme.of(context).colorScheme.tertiary),
                      title: const Text("GitHub Repository", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("AI-Astrology Source"),
                      trailing: const Icon(Icons.open_in_new, size: 16),
                      onTap: () => _launchUrl("https://github.com/SatyamYadav2006/AI-Astrology.git"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white70)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
