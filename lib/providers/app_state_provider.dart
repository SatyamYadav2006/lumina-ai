import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/horoscope_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/gemini_service.dart';

class AppStateProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final GeminiService _aiService = GeminiService();

  UserModel? _currentUserData;
  HoroscopeModel? _todayHoroscope;
  List<HoroscopeModel> _horoscopeHistory = [];

  bool _isLoading = false;

  UserModel? get currentUserData => _currentUserData;
  HoroscopeModel? get todayHoroscope => _todayHoroscope;
  List<HoroscopeModel> get horoscopeHistory => _horoscopeHistory;
  bool get isLoading => _isLoading;

  AppStateProvider() {
    _init();
  }

  // 🔹 INIT FUNCTION
  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      _isLoading = true;
      notifyListeners();

      if (user != null) {
        await fetchUserData(user.uid);
      } else {
        _currentUserData = null;
        _todayHoroscope = null;
        _horoscopeHistory = [];
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  // 🔹 FETCH USER DATA
  Future<void> fetchUserData(String uid) async {
    try {
      _currentUserData = await _firestoreService.getUserProfile(uid);

      if (_currentUserData != null) {
        await fetchHoroscopeHistory(uid);

        // 🔥 Delay to prevent UI freeze
        Future.delayed(const Duration(milliseconds: 500), () {
          loadTodayHoroscope();
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  // 🔹 FETCH HISTORY
  Future<void> fetchHoroscopeHistory(String uid) async {
    try {
      _horoscopeHistory =
          await _firestoreService.getHoroscopeHistory(uid);
    } catch (e) {
      debugPrint("Error fetching history: $e");
    }
  }

  // 🔹 CLEAR HISTORY
  Future<void> clearHistory() async {
    if (_currentUserData == null) return;
    try {
      // 1. WIPE LOCAL STATE IMMEDIATELY
      _horoscopeHistory.clear();
      _todayHoroscope = null;
      notifyListeners();
      
      // 2. WIPE REMOTE DATA
      await _firestoreService.clearHistory(_currentUserData!.uid);
      
    } catch (e) {
      debugPrint("Error clearing history: $e");
    }
  }

  // 🔹 LOAD TODAY HOROSCOPE
  Future<void> loadTodayHoroscope() async {
    if (_currentUserData == null) return;

    try {
      DateTime now = DateTime.now();
      String formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // 🔍 Check if already exists
      try {
        _todayHoroscope = _horoscopeHistory
            .firstWhere((h) => h.id == formattedDate);
      } catch (e) {
        _todayHoroscope = null;
      }

      // 🔥 If not exists → generate
      if (_todayHoroscope == null) {
        _todayHoroscope = await _aiService
            .generateDailyHoroscope(_currentUserData!, now);

        // Save to Firestore
        await _firestoreService.saveHoroscope(
            _currentUserData!.uid, _todayHoroscope!);

        _horoscopeHistory.insert(0, _todayHoroscope!);
      }
    } catch (e) {
      debugPrint("Error generating horoscope: $e");

      // 🔥 FALLBACK DATA (NO CRASH)
      DateTime now = DateTime.now();
      String formattedDate =
          "${now.year}-${now.month}-${now.day}";

      _todayHoroscope = HoroscopeModel(
        id: formattedDate,
        date: now,
        zodiacSign: _currentUserData?.zodiacSign ?? "",
        dailySummary:
            "Unable to fetch horoscope. Please check your internet or API.",
        career: "Opportunities will improve soon.",
        love: "Stay positive in relationships.",
        health: "Take care of your well-being.",
        finance: "Manage your expenses wisely.",
        mood: "Neutral",
        luckyNumber: "7",
        luckyColor: "Blue",
        luckyTime: "Evening",
        dos: ["Stay calm", "Try again later"],
        donts: ["Don't panic"],
      );
    }
    notifyListeners();
  }
}