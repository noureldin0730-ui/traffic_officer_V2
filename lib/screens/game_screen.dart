import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/citizen_generator.dart';
import '../data/save_manager.dart';

class P {
  static const wood = Color(0xFF2B1D12);
  static const woodLight = Color(0xFF3D2817);
  static const woodDark = Color(0xFF1A1109);

  static const paperWhite = Color(0xFFF0E8D8);
  static const paperBlue = Color(0xFFD8E0E8);
  static const paperYellow = Color(0xFFF0E8C8);

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

  static const machine = Color(0xFF3A3A3A);
  static const machineDark = Color(0xFF1A1A1A);
  static const machineLight = Color(0xFF5A5A5A);
}

class GameScreen extends StatefulWidget {
  final bool startFromSave;
  const GameScreen({super.key, required this.startFromSave});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  int _score = 0;
  int _citizenId = 1;
  late Citizen _citizen;

  // حالة الرخصة
  bool _showLicense = false;
  bool _showResult = false;
  String _resultText = '';
  bool _resultCorrect = false;

  // أنيميشن طباعة الرخصة
  late AnimationController _printCtrl;

  @override
  void initState() {
    super.initState();
    _printCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _load();
  }

  @override
  void dispose() {
    _printCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.startFromSave) {
      _score = await SaveManager.getSavedScore();
      _citizenId = await SaveManager.getSavedCitizen();
    }
    _citizen = generateCitizen(_citizenId);
    setState(() {});
  }

  // ═══ موافق ═══
  void _approve() {
    HapticFeedback.mediumImpact();

    final correct = !_citizen.hasError;

    if (correct) {
      _score++;
      SaveManager.saveGame(score: _score, citizen: _citizenId);
      setState(() {
        _showLicense = true;
        _resultCorrect = true;
        _resultText = 'قرار صح! +1';
      });
      _printCtrl.forward(from: 0);
    } else {
      _score--;
      SaveManager.saveGame(score: _score, citizen: _citizenId);
      setState(() {
        _showResult = true;
        _resultCorrect = false;
        _resultText = 'قرار غلط! -1\n(${_citizen.errorDescription})';
      });
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        _nextCitizen();
      });
    }
  }

  // ═══ مرفوض ═══
  void _reject() {
    HapticFeedback.heavyImpact();

    final correct = _citizen.hasError;

    if (correct) {
      _score++;
      setState(() {
        _showResult = true;
        _resultCorrect = true;
        _resultText = 'قرار صح! +1';
      });
    } else {
      _score--;
      setState(() {
        _showResult = true;
        _resultCorrect = false;
        _resultText = 'قرار غلط! -1\n(مفيش مشكلة في الأوراق)';
      });
    }
    SaveManager.saveGame(score: _score, citizen: _citizenId);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      _nextCitizen();
    });
  }

  // ═══ المواطن اللي بعده ═══
  void _nextCitizen() {
    setState(() {
      _showResult = false;
      _showLicense = false;
      _printCtrl.reset();
      _citizenId++;
      _citizen = generateCitizen(_citizenId);
    });
  }

  // ═══ بعد ما يستلم الرخصة ═══
  void _collectLicense() {
    HapticFeedback.mediumImpact();
    _nextCitizen();
  }

  void _exit() {
    SaveManager.saveGame(score: _score, citizen: _citizenId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: P.wood,
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [P.woodLight, P.wood, P.woodDark],
              ),
            ),
          ),

          // المحتوى
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _buildPapersArea()),
                      Expanded(flex: 2, child: _buildDecisionArea()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // الرخصة (فوق كل حاجة)
          if (_showLicense) _buildLicenseOverlay(),
        ],
      ),
    );
  }

  // ═══ الشريط العلوي ═══
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: _exit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: P.inkRed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.exit_to_app, color: P.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'خروج',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: P.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: P.paperWhite,
              border: Border.all(color: P.paperBorder, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: P.inkRed, size: 16),
                const SizedBox(width: 4),
                Text(
                  'النقاط: $_score',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: P.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: P.paperBlue,
              border: Border.all(color: P.paperBorder, width: 1.5),
            ),
            child: Text(
              'المواطن: $_citizenId',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.inkBlue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          // ماكينة الطباعة
          Container(
            width: 70,
            height: 50,
            decoration: BoxDecoration(
              color: P.machine,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: P.machineDark, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 50, height: 6, color: P.machineDark),
                const SizedBox(height: 4),
                Container(
                  width: 30,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _printCtrl.isAnimating ? P.accept : P.machineLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Nour Eldin',
            style: TextStyle(
              color: P.dim,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ═══ الأوراق ═══
  Widget _buildPapersArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 8, 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: P.woodDark.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: P.woodLight),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _citizen.papers.map((p) => _buildPaper(p)).toList(),
        ),
      ),
    );
  }

  Widget _buildPaper(Paper paper) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: P.paperWhite,
        border: Border.all(color: P.paperBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paper.title,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: P.inkRed,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: P.paperLine),
          const SizedBox(height: 6),
          Text(
            paper.content,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: P.ink,
              fontSize: 9,
              height: 1.6,
            ),
          ),
          if (paper.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: P.inkRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '⚠ ${paper.note}',
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: P.inkRed,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══ منطقة القرار ═══
  Widget _buildDecisionArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: P.paperWhite,
        border: Border.all(color: P.paperBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(3, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: P.inkRed, width: 2),
                ),
                child: Text(
                  _citizen.name.substring(0, 1),
                  style: const TextStyle(
                    color: P.inkRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _citizen.name,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: P.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${_citizen.age} سنة • ${_citizen.job}',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: P.inkBlue,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: P.paperLine),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: P.paperYellow,
              border: Border.all(color: P.paperLine),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '"${_citizen.speech}"',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.inkBlue,
                fontSize: 10,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'المطلوب: ${_citizen.licenseType}',
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: P.ink,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (_showResult)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _resultCorrect
                    ? P.accept.withOpacity(0.15)
                    : P.reject.withOpacity(0.15),
                border: Border.all(
                  color: _resultCorrect ? P.accept : P.reject,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _resultText,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _resultCorrect ? P.accept : P.reject,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'موافق',
                    icon: Icons.check,
                    color: P.accept,
                    onTap: _approve,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    label: 'مرفوض',
                    icon: Icons.close,
                    color: P.reject,
                    onTap: _reject,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: P.white, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ═══════════ الرخصة ═══════════
  // ═══════════════════════════════════════

  Widget _buildLicenseOverlay() {
    return GestureDetector(
      onTap: _collectLicense,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _printCtrl,
              builder: (context, child) {
                final progress = Curves.easeOut.transform(
                  _printCtrl.value.clamp(0.0, 1.0),
                );
                final offsetY = (1 - progress) * 400;
                final opacity = progress.clamp(0.0, 1.0);

                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: Opacity(
                    opacity: opacity,
                    child: _buildLicenseCard(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseCard() {
    final now = DateTime.now();
    final issueYear = now.year;
    final expiryYear = issueYear + 5;
    final issueDate = '${now.day}/${now.month}/$issueYear';
    final expiryDate = '${now.day}/${now.month}/$expiryYear';
    final licenseNumber = _citizen.nationalId;

    return Container(
      width: 660,
      height: 360,
      decoration: BoxDecoration(
        color: P.paperWhite,
        border: Border.all(color: P.inkRed, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 40,
            offset: const Offset(8, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // علامة مائية
          Positioned(
            right: -50,
            top: -50,
            child: Opacity(
              opacity: 0.06,
              child: Icon(
                Icons.directions_car,
                size: 340,
                color: P.inkRed,
              ),
            ),
          ),

          // المحتوى
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══ الهيدر ═══
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: P.inkRed, width: 2),
                        color: P.paperYellow,
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: P.inkRed,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'جمهورية مصر العربية',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: P.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'وزارة الداخلية — إدارة المرور',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: P.inkBlue,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: P.inkRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _citizen.licenseType,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: P.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 2, color: P.inkRed),
                const SizedBox(height: 16),

                // ═══ الجسم ═══
                Expanded(
                  child: Row(
                    children: [
                      // الصورة
                      Container(
                        width: 120,
                        height: 150,
                        decoration: BoxDecoration(
                          color: P.paperYellow,
                          border: Border.all(color: P.paperBorder, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              size: 70,
                              color: P.ink.withOpacity(0.5),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'صورة شخصية',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: P.inkBlue,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // البيانات
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _licenseRow('الاسم', _citizen.name),
                            _licenseRow('الرقم القومي', _citizen.nationalId),
                            _licenseRow('العنوان', _citizen.address),
                            _licenseRow('المهنة', _citizen.job),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: _licenseDateBox(
                                    'تاريخ الإصدار',
                                    issueDate,
                                    P.inkGreen,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _licenseDateBox(
                                    'تاريخ الانتهاء',
                                    expiryDate,
                                    P.inkRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      // الختم
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: P.inkRed, width: 2.5),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ختم',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: P.inkRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'رسمي',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: P.inkRed,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Container(height: 2, color: P.inkRed),
                const SizedBox(height: 10),

                // ═══ الفوتر ═══
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'رقم الرخصة: $licenseNumber',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: P.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Text(
                      'صالح في جميع أنحاء الجمهورية',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: P.inkBlue,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _licenseRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.inkBlue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _licenseDateBox(String label, String date, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}