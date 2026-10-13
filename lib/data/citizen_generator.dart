import 'dart:math';
import 'pools.dart';

// ═══════════════ الفئات ═══════════════
class Paper {
  final String title;        // اسم الورقة
  final String content;      // محتواها
  final String note;         // ملاحظة (لو فيه مشكلة)
  const Paper({
    required this.title,
    required this.content,
    required this.note,
  });
}

class Citizen {
  final int id;
  final String name;
  final int age;
  final String job;
  final String address;
  final String nationalId;
  final String licenseType;
  final String applicationReason;
  final String speech;        // كلام المواطن
  final List<Paper> papers;   // 5 أوراق
  final bool hasError;
  final String errorDescription;

  const Citizen({
    required this.id,
    required this.name,
    required this.age,
    required this.job,
    required this.address,
    required this.nationalId,
    required this.licenseType,
    required this.applicationReason,
    required this.speech,
    required this.papers,
    required this.hasError,
    required this.errorDescription,
  });
}

// ═══════════════ دالة التوليد ═══════════════
Citizen generateCitizen(int id) {
  final rng = Random(id * 9973 + 42);

  // ───── الاسم ─────
  final isMale = rng.nextBool();
  final firstName = isMale
      ? kMaleNames[rng.nextInt(kMaleNames.length)]
      : kFemaleNames[rng.nextInt(kFemaleNames.length)];
  final secondName = rng.nextBool()
      ? kMaleNames[rng.nextInt(kMaleNames.length)]
      : kFemaleNames[rng.nextInt(kFemaleNames.length)];
  final name = '$firstName $secondName';

  // ───── العمر ─────
  final age = 16 + rng.nextInt(55); // 16-70

  // ───── الرقم القومي ─────
  final nationalId = _generateNationalId(rng, age);

  // ───── العنوان ─────
  final governorate =
      kGovernorates[rng.nextInt(kGovernorates.length)];
  final street = kStreetNames[rng.nextInt(kStreetNames.length)];
  final buildingNum = 1 + rng.nextInt(200);
  final address = '$buildingNum $street، $governorate';

  // ───── المهنة ─────
  final job = kJobs[rng.nextInt(kJobs.length)];

  // ───── نوع الرخصة ─────
  final licenseType =
      kLicenseTypes[rng.nextInt(kLicenseTypes.length)];

  // ───── سبب الطلب ─────
  final applicationReason =
      kApplicationReasons[rng.nextInt(kApplicationReasons.length)];

  // ───── الكلام ─────
  final speech = _generateSpeech(rng, isMale);

  // ───── هل فيه خطأ؟ ─────
  final hasError = rng.nextDouble() < 0.5; // 50%
  ErrorType? error;
  if (hasError) {
    error = kErrorTypes[rng.nextInt(kErrorTypes.length)];
  }

  // ───── الأوراق الخمسة ─────
  final papers = _generatePapers(
    rng: rng,
    name: name,
    age: age,
    address: address,
    nationalId: nationalId,
    job: job,
    licenseType: licenseType,
    applicationReason: applicationReason,
    error: error,
  );

  return Citizen(
    id: id,
    name: name,
    age: age,
    job: job,
    address: address,
    nationalId: nationalId,
    licenseType: licenseType,
    applicationReason: applicationReason,
    speech: speech,
    papers: papers,
    hasError: hasError,
    errorDescription: error?.description ?? '',
  );
}

// ═══════════════ رقم قومي ═══════════════
String _generateNationalId(Random rng, int age) {
  // مصري: 14 رقم
  // 2 أو 3 (قرن) + 6 أرقام (سنة شهر يوم) + 4 أرقام محافظة + 4 أرقام عشوائية
  final century = rng.nextBool() ? 2 : 3;
  final year = (2024 - age) % 100;
  final month = 1 + rng.nextInt(12);
  final day = 1 + rng.nextInt(28);
  final gov = 1 + rng.nextInt(35);
  final rand = 1000 + rng.nextInt(9000);
  final y = year.toString().padLeft(2, '0');
  final m = month.toString().padLeft(2, '0');
  final d = day.toString().padLeft(2, '0');
  final g = gov.toString().padLeft(2, '0');
  return '$century$y$m$d$g$rand';
}

// ═══════════════ كلام المواطن ═══════════════
String _generateSpeech(Random rng, bool isMale) {
  final speeches = isMale
      ? [
          'يا باشا أنا مستعجل، خلصني بسرعة.',
          'والله العظيم أنا غلبان، الرخصة دي شغلي.',
          'معلش، أنا مش فاضي، عندي شغل.',
          'أنا ابن ناس، متشككش فيّ.',
          'رخصة السيارة دي بتاعة الشغل، محتاجها بكرة.',
          'أنا دافع دمغة، متعطلنيش.',
        ]
      : [
          'يا فندم، أنا ست بيت ومحتاجة الرخصة.',
          'أنا مش فاضية، عندي عيال.',
          'معلش، أنا بحترمك، خلصني.',
          'أنا شريفة، متشككش فيّ.',
          'أنا دافعة كل حاجة، إيه المشكلة؟',
          'الرخصة دي بتاعة جوزي، هو اللي محتاجها.',
        ];
  return speeches[rng.nextInt(speeches.length)];
}

// ═══════════════ توليد الأوراق ═══════════════
List<Paper> _generatePapers({
  required Random rng,
  required String name,
  required int age,
  required String address,
  required String nationalId,
  required String job,
  required String licenseType,
  required String applicationReason,
  required ErrorType? error,
}) {
  // ═══ خطأ في الاسم ═══
  String cardName = name;
  String formName = name;
  String receiptName = name;
  String note1 = '';
  if (error?.code == 'name_mismatch') {
    // غيّر اسم واحد
    formName = _changeName(name, rng);
    note1 = 'الاسم مختلف بين الأوراق';
  }

  // ═══ خطأ في الرقم القومي ═══
  String cardId = nationalId;
  String receiptId = nationalId;
  if (error?.code == 'id_mismatch') {
    receiptId = _changeId(nationalId, rng);
  }

  // ═══ خطأ في العنوان ═══
  String cardAddress = address;
  String receiptAddress = address;
  if (error?.code == 'address_mismatch') {
    receiptAddress = _changeAddress(address, rng);
  }

  // ═══ خطأ في السن ═══
  int cardAge = age;
  if (error?.code == 'underage') {
    cardAge = 16;
  }

  // ═══ خطأ في إيصال الكهرباء ═══
  String receiptDate = '2024';
  if (error?.code == 'expired_receipt') {
    receiptDate = '2022';
  }

  // ═══ خطأ الشهادة الصحية ═══
  String healthDate = '2024';
  if (error?.code == 'expired_health') {
    healthDate = '2022';
  }

  // ═══ الصورة القديمة ═══
  String photoNote = 'صورة حديثة';
  if (error?.code == 'old_photo') {
    photoNote = 'الصورة قديمة';
  }

  // ═══ الرخصة القديمة ═══
  String oldLicenseDate = '2023';
  if (error?.code == 'expired_license') {
    oldLicenseDate = '2020';
  }

  // ═══ التوقيع ═══
  String signatureNote = 'موقّع';
  if (error?.code == 'missing_signature') {
    signatureNote = 'غير موقّع';
  }

  // ═══ نوع الرخصة ═══
  String licenseTypeNote = licenseType;
  if (error?.code == 'wrong_license_type') {
    licenseTypeNote = 'نوع الرخصة غلط';
  }

  return [
    Paper(
      title: 'بطاقة الرقم القومي',
      content:
          'الاسم: $cardName\n'
          'الرقم القومي: $cardId\n'
          'السن: $cardAge\n'
          'العنوان: $cardAddress\n'
          'المهنة: $job',
      note: error?.code == 'underage' ? 'السن أقل من 18' : '',
    ),
    Paper(
      title: 'إيصال الكهرباء',
      content:
          'الاسم: $receiptName\n'
          'الرقم القومي: $receiptId\n'
          'العنوان: $receiptAddress\n'
          'تاريخ الإصدار: $receiptDate',
      note: error?.code == 'expired_receipt'
          ? 'الإيصال قديم'
          : '',
    ),
    Paper(
      title: 'نموذج الطلب',
      content:
          'الاسم: $formName\n'
          'نوع الرخصة: $licenseTypeNote\n'
          'سبب الطلب: $applicationReason\n'
          'التوقيع: $signatureNote',
      note: error?.code == 'missing_signature'
          ? 'التوقيع ناقص'
          : '',
    ),
    Paper(
      title: 'الشهادة الصحية',
      content:
          'الاسم: $name\n'
          'نتيجة الكشف: سليم\n'
          'تاريخ الإصدار: $healthDate',
      note: error?.code == 'expired_health'
          ? 'الشهادة قديمة'
          : '',
    ),
    Paper(
      title: 'الصورة الشخصية',
      content:
          'الاسم: $name\n'
          'المواصفات: $photoNote',
      note: error?.code == 'old_photo'
          ? 'الصورة قديمة'
          : '',
    ),
  ];
}

// ═══════════════ تعديل اسم ═══════════════
String _changeName(String name, Random rng) {
  final parts = name.split(' ');
  if (parts.length < 2) return '$name (مختلف)';
  // غيّر حرف في الاسم الأول
  final first = parts[0];
  if (first.length > 2) {
    final chars = first.split('');
    chars[1] = chars[1] == 'ح' ? 'خ' : 'ح';
    return '${chars.join(' ')} ${parts.sublist(1).join(' ')}';
  }
  return name;
}

// ═══════════════ تعديل رقم قومي ═══════════════
String _changeId(String id, Random rng) {
  // غيّر رقم واحد
  final chars = id.split('');
  final pos = rng.nextInt(chars.length);
  final current = chars[pos];
  chars[pos] = current == '0' ? '1' : '0';
  return chars.join();
}

// ═══════════════ تعديل عنوان ═══════════════
String _changeAddress(String address, Random rng) {
  final parts = address.split('، ');
  if (parts.length < 2) return address;
  return '${parts[0]}، ${parts[1]}';
}