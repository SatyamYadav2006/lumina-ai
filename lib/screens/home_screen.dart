import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state_provider.dart';
import '../providers/theme_provider.dart';
import '../services/zodiac_service.dart';
import '../services/auth_service.dart';
import '../widgets/holographic_card.dart';
import '../widgets/celestial_background.dart';
import 'chatbot_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  bool _isGenerating = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        if (appState.isLoading || appState.currentUserData == null) {
          return const Scaffold(body: CelestialBackground(child: Center(child: CircularProgressIndicator())));
        }

        final user = appState.currentUserData!;
        final horoscope = appState.todayHoroscope;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text("LUMINA AI", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4.0, fontSize: 16)),
            centerTitle: true,
            actions: [
              IconButton(icon: const Icon(Icons.history), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
              IconButton(icon: const Icon(Icons.brightness_6), onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme()),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: Theme.of(context).colorScheme.surface,
                onSelected: (value) {
                  if (value == 'about') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                  } else if (value == 'privacy') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                  } else if (value == 'change_password') {
                     final user = AuthService().currentUser;
                     if (user != null && user.email != null) {
                        try {
                           AuthService().sendPasswordResetEmail(user.email!);
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('A resilient password reset link was sent to ${user.email}')));
                        } catch (e) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                     }
                  } else if (value == 'logout') {
                    AuthService().logOut();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'about',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                        const SizedBox(width: 12),
                        const Text('Contact Us'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'privacy',
                    child: Row(
                      children: [
                        Icon(Icons.privacy_tip_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                        const SizedBox(width: 12),
                        const Text('Privacy Policy'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'change_password',
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset, color: Theme.of(context).colorScheme.primary, size: 20),
                        const SizedBox(width: 12),
                        const Text('Change Password'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: const [
                        Icon(Icons.logout, color: Colors.redAccent, size: 20),
                        SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: CelestialBackground(
            child: Column(
              children: [
                // Top Hero Section (Fixed)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: kToolbarHeight + 20),
                        Text(
                          ZodiacService.getZodiacIconPath(user.zodiacSign),
                          style: TextStyle(
                            fontSize: 100, 
                            color: Theme.of(context).colorScheme.tertiary,
                            shadows: [Shadow(color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5), blurRadius: 20)]
                          ),
                        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                         .scaleXY(begin: 0.95, end: 1.05, duration: 4.seconds)
                         .then().shimmer(duration: 2.seconds),
                        const SizedBox(height: 16),
                        Text(
                          user.name.toUpperCase(), 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 5.0)
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "${user.zodiacSign} \u2022 ${user.placeOfBirth}".toUpperCase(), 
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 3.0)
                          ),
                        ),
                      ],
                    ).animate().fade(duration: 1.seconds),
                  ),
                ),
                
                // Bottom PageView Section
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: horoscope == null
                        ? Center(
                            child: _isGenerating 
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(color: Colors.white).animate(onPlay: (c) => c.repeat()).shimmer(),
                                    const SizedBox(height: 24),
                                    const Text("COMMUNING WITH THE STARS...", style: TextStyle(color: Colors.white, letterSpacing: 3.0, fontWeight: FontWeight.w900)).animate(onPlay: (c) => c.repeat(reverse: true)).fade().shimmer(duration: 2.seconds),
                                  ],
                                ).animate().fade(duration: 500.ms)
                              : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () {
                                  setState(() => _isGenerating = true);
                                  Provider.of<AppStateProvider>(context, listen: false).loadTodayHoroscope();
                                },
                                child: const Text("GENERATE DAILY ALIGNMENT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(),
                          )
                        : PageView(
                            controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildReadingPage(context, "THE VIBE", horoscope.mood, horoscope.dailySummary, Icons.auto_awesome),
                            _buildLuckyPage(context, horoscope.luckyNumber, horoscope.luckyColor, "${horoscope.date.day.toString().padLeft(2, '0')}/${horoscope.date.month.toString().padLeft(2, '0')}/${horoscope.date.year}"),
                            _buildReadingPage(context, "CAREER PATTERNS", "Prospects", horoscope.career, Icons.timeline),
                            _buildReadingPage(context, "HEART & LOVE", "Connection", horoscope.love, Icons.favorite_outline),
                            _buildReadingPage(context, "VITALITY", "Health", horoscope.health, Icons.hdr_strong),
                            _buildReadingPage(context, "MATERIAL WEALTH", "Finance", horoscope.finance, Icons.diamond_outlined),
                            _buildDosDontsPage(context, horoscope.dos, horoscope.donts),
                          ],
                        ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(),
        );
      },
    );
  }

  Widget _buildReadingPage(BuildContext context, String header, String subtitle, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 80),
      child: HolographicCard(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: Theme.of(context).colorScheme.tertiary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(header, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                         Text(subtitle.toUpperCase(), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Text(
                content,
                style: const TextStyle(fontSize: 16, height: 1.6, letterSpacing: 0.5),
              ).animate().fade(duration: 800.ms, delay: 200.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDosDontsPage(BuildContext context, List<String> dos, List<String> donts) {
    return Padding(
       padding: const EdgeInsets.fromLTRB(10, 20, 10, 80),
       child: HolographicCard(
         child: SingleChildScrollView(
           physics: const BouncingScrollPhysics(),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text("DIRECTIVES", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
               const SizedBox(height: 24),
               const Text("ALIGN WITH", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
               const SizedBox(height: 12),
               ...dos.map((e) => Padding(padding: const EdgeInsets.only(bottom:8), child: Text("• $e", style: const TextStyle(fontSize: 15)))),
               const SizedBox(height: 24),
               const Text("AVOID", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
               const SizedBox(height: 12),
               ...donts.map((e) => Padding(padding: const EdgeInsets.only(bottom:8), child: Text("• $e", style: const TextStyle(fontSize: 15)))),
             ],
           )
         )
       )
    );
  }

  Widget _buildLuckyPage(BuildContext context, String number, String color, String date) {
    return Padding(
       padding: const EdgeInsets.fromLTRB(10, 20, 10, 80),
       child: HolographicCard(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text("AUSPICIOUS ELEMENTS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
             const Spacer(),
             Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Expanded(child: _buildLuckyItem("NUMBER", number, context)),
                   Expanded(child: _buildLuckyItem("COLOR", color, context)),
                   Expanded(child: _buildLuckyItem("DATE", date, context)),
                ]
             ),
             const Spacer(),
           ]
         )
       )
    );
  }

  Widget _buildLuckyItem(String title, String value, BuildContext context) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Theme.of(context).colorScheme.tertiary)),
      ],
    );
  }
}
