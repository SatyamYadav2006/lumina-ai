import 'package:flutter/material.dart';
import '../widgets/celestial_background.dart';
import '../widgets/holographic_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Privacy Policy", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3.0, fontSize: 16)),
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
                    const Text("PRIVACY POLICY", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                    const SizedBox(height: 24),
                    _buildSection(context, "1. Introduction", "Welcome to Lumina AI Astrology. We are profoundly committed to safeguarding the mystical data you provide. This privacy policy outlines how your demographic and cosmic alignments are carefully processed and protected within our ecosystem."),
                    _buildSection(context, "2. Data Collection", "To formulate precise celestial mappings, we collect minimal user data during account creation: Name, Date of Birth, Place of Birth, and corresponding Zodiac Sign. We implicitly track cosmic queries inside the Oracle Chatbot for contextual history."),
                    _buildSection(context, "3. Data Usage", "The aforementioned data is strictly utilized to communicate with advanced neural APIs to generate highly personalized daily horoscopes, astrological insights, and emotional pattern recognition inside the Oracle module."),
                    _buildSection(context, "4. Data Security", "Your profile structures and chat history are securely persisted using Google Firebase Authentication and Cloud Firestore technologies. We enforce strict client-side verification to ensure no internal leakage outside of authenticated sessions."),
                    _buildSection(context, "5. Third-Party Intelligence", "Lumina AI harnesses the power of external Large Language Models (including DeepSeek API infrastructures). Your zodiac metadata and oracle context are forwarded to these API backends exclusively for generation. No data is harvested for model training on our behalf."),
                    _buildSection(context, "6. Contact Administrator", "For any compliance queries, telemetry inquiries, or account deletion requests outside the scope of the app UI, direct correspondence to the master architect: yadavsatyam7346@gmail.com."),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.white70)),
        ],
      ),
    );
  }
}
