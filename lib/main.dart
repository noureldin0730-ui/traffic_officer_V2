import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/game_screen.dart';
import 'data/save_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const TrafficOfficerApp());
}

class TrafficOfficerApp extends StatelessWidget {
  const TrafficOfficerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Officer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF2B1D12),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
          ),
          child: child!,
        );
      },
      home: const StartScreen(),
    );
  }
}

// ═══════════ الألوان — مكتب حكومي ═══════════
class P {
  static const wood = Color(0xFF2B1D12);
  static const woodLight = Color(0xFF3D2817);
  static const woodDark = Color(0xFF1A1109);

  static const paperWhite = Color(0xFFF0E8D8);
  static const paperBlue = Color(0xFFD8E0E8);
  static const paperGreen = Color(0xFFDDE8D8);
  static const paperYellow = Color(0xFFF0E8C8);
  static const paperPink = Color(0xFFF0D8D8);

  static const paperLine = Color(0xFFB8B0A0);
  static const paperBorder = Color(0xFF8B7355);

  static const ink = Color(0xFF1A1A1A);
  static const inkBlue = Color(0xFF1E3A5F);
  static const inkRed = Color(0xFF8B1A1A);
  static const inkGreen = Color(0xFF2E5A2E);

  static const accept = Color(0xFF4A9B6F);
  static const reject = Color(0xFFC0392B);

  static const dim = Color(0xFF8B7355);
  static const white = Color(0xFFF0E8D8);
  static const gold = Color(0xFFD4AF37);
}

// ═══════════ شاشة البداية ═══════════
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});
  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _highScore = 0;
  int _savedScore = 0;
  int _savedCitizen = 1;
  bool _hasSaved = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hs = await SaveManager.getHighScore();
    final saved = await SaveManager.hasSavedGame();
    final score = await SaveManager.getSavedScore();
    final citizen = await SaveManager.getSavedCitizen();
    if (!mounted) return;
    setState(() {
      _highScore = hs;
      _hasSaved = saved;
      _savedScore = score;
      _savedCitizen = citizen;
      _loading = false;
    });
  }

  void _startNew() {
    HapticFeedback.lightImpact();
    SaveManager.clearSavedGame();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameScreen(startFromSave: false),
      ),
    ).then((_) => _load());
  }

  void _continue() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameScreen(startFromSave: true),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: P.wood,
        body: Center(
          child: CircularProgressIndicator(color: P.accept),
        ),
      );
    }

    return Scaffold(
      backgroundColor: P.wood,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [P.woodLight, P.wood, P.woodDark],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // ────── الشمال: العنوان + الأزرار ──────
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ورقة العنوان
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: P.paperWhite,
                          border: Border.all(
                            color: P.paperBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(4, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 160,
                              height: 2,
                              color: P.paperLine,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'TRAFFIC OFFICER',
                              style: TextStyle(
                                color: P.ink,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'موظف إدارة المرور',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: P.inkBlue,
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 60,
                              height: 3,
                              color: P.inkRed,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // أعلى إسكور
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: P.gold,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'أعلى إسكور: $_highScore',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: P.gold,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // زر "كمّل"
                      if (_hasSaved) ...[
                        GestureDetector(
                          onTap: _continue,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: P.accept,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(3, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'كمّل اللعب',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: P.white,
                                    fontSize: 18,
                                    letterSpacing: 3,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'إسكور: $_savedScore • مواطن: $_savedCitizen',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: P.white.withOpacity(0.8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // زر "ابدأ من الأول"
                      GestureDetector(
                        onTap: _startNew,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: _hasSaved ? Colors.transparent : P.inkRed,
                            border: Border.all(
                              color: _hasSaved
                                  ? P.inkRed
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: !_hasSaved
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(3, 5),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            _hasSaved ? 'ابدأ من الأول' : 'ابدأ اللعب',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: _hasSaved ? P.inkRed : P.white,
                              fontSize: 18,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nour Eldin',
                        style: TextStyle(
                          color: P.dim.withOpacity(0.7),
                          fontSize: 11,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ────── اليمين: ورقة + ختم ──────
              Expanded(
                flex: 2,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(12, 8),
                        child: Container(
                          width: 170,
                          height: 220,
                          decoration: BoxDecoration(
                            color: P.paperBlue,
                            border: Border.all(color: P.paperBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(3, 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 170,
                        height: 220,
                        decoration: BoxDecoration(
                          color: P.paperWhite,
                          border: Border.all(color: P.paperBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(3, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            ...List.generate(5, (i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                child: Container(
                                  height: 2,
                                  color: P.paperLine,
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: P.inkRed,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'مرور',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: P.inkRed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}