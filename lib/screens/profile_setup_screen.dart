import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/zodiac_service.dart';
import '../providers/app_state_provider.dart';
import '../widgets/celestial_background.dart';

class ProfileSetupScreen extends StatefulWidget {
  final User user;
  const ProfileSetupScreen({super.key, required this.user});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
             colorScheme: ColorScheme.dark(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
                surface: const Color(0xFF0A0F1A),
                onSurface: Colors.white,
             )
          ),
          child: child!,
        );
      }
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _presentTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
             colorScheme: ColorScheme.dark(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
                surface: const Color(0xFF0A0F1A),
                onSurface: Colors.white,
             )
          ),
          child: child!,
        );
      }
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  void _saveProfile() async {
    if (_nameController.text.trim().isEmpty || _selectedDate == null || _selectedTime == null || _placeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coordinates incomplete. Please fill all fields.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String timeString = _selectedTime!.format(context);
      String zodiacSign = ZodiacService.getZodiacSign(_selectedDate!);

      UserModel userModel = UserModel(
        uid: widget.user.uid,
        name: _nameController.text.trim(),
        dob: _selectedDate!,
        timeOfBirth: timeString,
        placeOfBirth: _placeController.text.trim(),
        zodiacSign: zodiacSign,
      );

      await FirestoreService().saveUserProfile(userModel);
      
      // Refresh AppState securely awaiting completion
      if (mounted) await Provider.of<AppStateProvider>(context, listen: false).fetchUserData(widget.user.uid);
      
      // We intentionally do NOT set _isLoading = false here upon success! 
      // The button will elegantly spin continuously until the AuthWrapper completely replaces this screen!
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
        setState(() => _isLoading = false); // Only reset on failure
      }
    }
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, spreadRadius: -5)
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 0.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 1.0, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildPremiumSelectionField({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, spreadRadius: -5)
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: label.startsWith('No ') ? Colors.white.withOpacity(0.3) : Colors.white,
                  letterSpacing: 1.0,
                  fontSize: 14
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14)
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumButton(BuildContext context, String text, VoidCallback onPressed, bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.primary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    const SizedBox(width: 12),
                    const Text(
                      "CREATING PROFILE...",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 14, letterSpacing: 2.0),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(),
                  ],
                )
              : Text(
                  text.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 4.0,
                  ),
                ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds, color: Colors.white24);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Setup Profile", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4.0, fontSize: 16, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CelestialBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(32.0, MediaQuery.of(context).padding.top + kToolbarHeight + 32, 32.0, 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text("Please enter your birth details.", style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 2.0), textAlign: TextAlign.center),
              const SizedBox(height: 48),
              _buildPremiumTextField(
                controller: _nameController,
                hint: "Full Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildPremiumSelectionField(
                label: _selectedDate == null ? 'Select Birth Date' : 'Birth Date: ${DateFormat.yMd().format(_selectedDate!)}',
                icon: Icons.calendar_month_outlined,
                onTap: _presentDatePicker,
              ),
              const SizedBox(height: 20),
              _buildPremiumSelectionField(
                label: _selectedTime == null ? 'Select Birth Time' : 'Birth Time: ${_selectedTime!.format(context)}',
                icon: Icons.access_time,
                onTap: _presentTimePicker,
              ),
              const SizedBox(height: 20),
              _buildPremiumTextField(
                controller: _placeController,
                hint: "Birth Place (City, Country)",
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: 60),
              _buildPremiumButton(context, "CREATE PROFILE", _saveProfile, _isLoading),
            ],
          ).animate().fade().slideY(begin: 0.1),
        ),
      ),
    );
  }
}
