import 'package:shared_preferences/shared_preferences.dart';

class SaveManager {
  // ═══ أعلى إسكور ═══
  static Future<int> getHighScore() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('high_score') ?? 0;
  }

  static Future<void> setHighScore(int score) async {
    final p = await SharedPreferences.getInstance();
    final current = p.getInt('high_score') ?? 0;
    if (score > current) {
      await p.setInt('high_score', score);
    }
  }

  // ═══ اللعبة الحالية ═══
  static Future<bool> hasSavedGame() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('has_saved') ?? false;
  }

  static Future<void> saveGame({
    required int score,
    required int citizen,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('saved_score', score);
    await p.setInt('saved_citizen', citizen);
    await p.setBool('has_saved', true);
    // سجّل أعلى إسكور
    final high = p.getInt('high_score') ?? 0;
    if (score > high) {
      await p.setInt('high_score', score);
    }
  }

  static Future<int> getSavedScore() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('saved_score') ?? 0;
  }

  static Future<int> getSavedCitizen() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('saved_citizen') ?? 1;
  }

  static Future<void> clearSavedGame() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('saved_score');
    await p.remove('saved_citizen');
    await p.setBool('has_saved', false);
  }
}