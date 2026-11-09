import 'package:flutter/material.dart';
import '../models/quran_model.dart';
import '../services/quran_service.dart';
import '../utils/user_friendly_error.dart';

class QuranProvider extends ChangeNotifier {
  final QuranService _quranService = QuranService();

  List<Surah> _surahs = [];
  List<Verse> _verses = [];
  bool _isLoading = false;
  String? _error;

  List<Surah> get surahs => _surahs;
  List<Verse> get verses => _verses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSurahs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surahs = await _quranService.getSurahs();
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Could not load Quran chapters: $e\n$stackTrace');
      _error = UserFriendlyError.content(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVerses(int surahNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _verses = await _quranService.getVerses(surahNumber);
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Could not load Quran verses: $e\n$stackTrace');
      _error = UserFriendlyError.content(e);
      _isLoading = false;
      notifyListeners();
    }
  }
}
