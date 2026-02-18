import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihProvider extends ChangeNotifier {
  int _count = 0;
  int _target = 33;
  String _currentTasbih = 'SubhanAllah';
  
  int get count => _count;
  int get target => _target;
  String get currentTasbih => _currentTasbih;
  
  final Map<String, String> tasbihTypes = {
    'SubhanAllah': 'سبحان اللہ',
    'Alhamdulillah': 'الحمد للہ',
    'AllahuAkbar': 'اللہ اکبر',
    'LaIlahaIllallah': 'لا الہ الا اللہ',
  };
  
  TasbihProvider() {
    _loadCount();
  }
  
  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    _count = prefs.getInt('tasbih_count') ?? 0;
    _target = prefs.getInt('tasbih_target') ?? 33;
    _currentTasbih = prefs.getString('current_tasbih') ?? 'SubhanAllah';
    notifyListeners();
  }
  
  Future<void> increment() async {
    _count++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', _count);
    notifyListeners();
  }
  
  Future<void> reset() async {
    _count = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', 0);
    notifyListeners();
  }
  
  Future<void> setTarget(int newTarget) async {
    _target = newTarget;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_target', newTarget);
    notifyListeners();
  }
  
  Future<void> setTasbih(String tasbih) async {
    _currentTasbih = tasbih;
    _count = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_tasbih', tasbih);
    await prefs.setInt('tasbih_count', 0);
    notifyListeners();
  }
}
