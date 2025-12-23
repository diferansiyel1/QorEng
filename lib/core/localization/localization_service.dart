import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Supported locales.
enum AppLocale {
  tr('tr', 'Türkçe', '🇹🇷'),
  en('en', 'English', '🇬🇧');

  const AppLocale(this.code, this.name, this.flag);

  final String code;
  final String name;
  final String flag;

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (locale) => locale.code == code,
      orElse: () => AppLocale.tr,
    );
  }
}

/// Localization service for managing app language.
class LocalizationService {
  static const String _boxName = 'settings';
  static const String _localeKey = 'locale';
  static Box? _box;

  /// Initialize the localization service.
  static Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Get saved locale or default to Turkish.
  static AppLocale getSavedLocale() {
    final code = _box?.get(_localeKey, defaultValue: 'tr') as String?;
    return AppLocale.fromCode(code ?? 'tr');
  }

  /// Save locale preference.
  static Future<void> saveLocale(AppLocale locale) async {
    await _box?.put(_localeKey, locale.code);
  }
}

/// Notifier for app locale state.
class LocaleNotifier extends Notifier<AppLocale> {
  @override
  AppLocale build() {
    return LocalizationService.getSavedLocale();
  }

  void setLocale(AppLocale locale) {
    state = locale;
    LocalizationService.saveLocale(locale);
  }

  void toggleLocale() {
    final newLocale = state == AppLocale.tr ? AppLocale.en : AppLocale.tr;
    setLocale(newLocale);
  }
}

/// Provider for current app locale.
final localeProvider = NotifierProvider<LocaleNotifier, AppLocale>(
  LocaleNotifier.new,
);

/// Extension for easy string localization access.
extension LocalizedStrings on WidgetRef {
  AppStrings get strings {
    final locale = watch(localeProvider);
    return locale == AppLocale.tr ? TurkishStrings() : EnglishStrings();
  }
}

/// Extension for BuildContext localization access.
extension LocalizedContext on BuildContext {
  AppStrings strings(WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return locale == AppLocale.tr ? TurkishStrings() : EnglishStrings();
  }
}

/// Abstract class for app strings.
abstract class AppStrings {
  // General
  String get appName;
  String get guest;
  String get engineer;
  String get calculate;
  String get result;
  String get results;
  String get inputs;
  String get exportPdf;
  String get save;
  String get cancel;
  String get close;
  String get search;
  String get searchHint;
  String get noResults;
  String get loading;
  String get error;
  String get success;
  String get warning;

  // Greetings
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get nightShift;

  // Dashboard
  String get modules;
  String get quickAccess;
  String get recentActivity;
  String get viewAll;
  String get noRecentActivity;

  // Modules
  String get electrical;
  String get electricalDesc;
  String get mechanical;
  String get mechanicalDesc;
  String get chemical;
  String get chemicalDesc;
  String get bioprocess;
  String get bioprocessDesc;

  // Electrical calculators
  String get ohmsLaw;
  String get ohmsLawDesc;
  String get powerCalculator;
  String get powerCalculatorDesc;
  String get voltageDrop;
  String get voltageDropDesc;
  String get vfdSpeed;
  String get vfdSpeedDesc;
  String get signalScaler;
  String get signalScalerDesc;

  // Mechanical calculators
  String get reynoldsNumber;
  String get reynoldsNumberDesc;
  String get hydraulicForce;
  String get hydraulicForceDesc;
  String get pressureDrop;
  String get pressureDropDesc;
  String get flowVelocity;
  String get flowVelocityDesc;

  // Chemical calculators
  String get molarity;
  String get molarityDesc;
  String get dilution;
  String get dilutionDesc;
  String get arrhenius;
  String get arrheniusDesc;
  String get odCellDensity;
  String get odCellDensityDesc;
  String get beerLambert;
  String get beerLambertDesc;
  String get phSensor;
  String get phSensorDesc;

  // Bioprocess calculators
  String get tipSpeed;
  String get tipSpeedDesc;

  // Common fields
  String get voltage;
  String get current;
  String get resistance;
  String get power;
  String get frequency;
  String get diameter;
  String get length;
  String get area;
  String get volume;
  String get mass;
  String get concentration;
  String get temperature;
  String get pressure;
  String get flowRate;
  String get velocity;
  String get density;
  String get viscosity;

  // Units
  String get volts;
  String get amperes;
  String get ohms;
  String get watts;
  String get kilowatts;
  String get hertz;
  String get meters;
  String get millimeters;
  String get liters;
  String get milliliters;
  String get grams;
  String get kilograms;
  String get molar;
  String get celsius;
  String get kelvin;
  String get pascal;
  String get bar;
  String get psi;

  // Pikolab Connect
  String get pikolabConnect;
  String get pikolabConnectDesc;
  String get askExpert;
  String get sendMessage;

  // Notifications
  String get notifications;
  String get announcements;
  String get noAnnouncements;
  String get noAnnouncementsDesc;

  // Auth
  String get signIn;
  String get signOut;
  String get signInWithGoogle;
  String get continueAsGuest;
  String get unlockFeatures;
  String get unlockFeaturesDesc;

  // History
  String get history;
  String get clearHistory;
  String get noHistory;

  // Settings
  String get settings;
  String get language;
  String get theme;
  String get darkMode;
  String get lightMode;
  String get about;
  String get version;
  String get privacyPolicy;
  String get termsOfService;

  // Navigation
  String get home;
  String get dashboard;
  String get searchTools;
  String get recentActivityHint;
  String get comingSoon;
  String get clear;
  String get reset;
  String get copyValue;

  // Quick Access
  String get cableSizing;
  String get conversionLabel;
  String get viscosityLab;
  String get dynamicKinematic;
  String get spectroscopy;

  // Tab Labels
  String get powerCables;
  String get automationTab;
  String get solidsHydraulics;
  String get fluidFlow;

  // Input Labels
  String get phaseSystem;
  String get conductorMaterial;
  String get cableCrossSection;
  String get systemVoltage;
  String get copper;
  String get aluminum;
  String get singlePhase;
  String get threePhase;
  String get enterCurrent;
  String get enterLength;
  String get enterVoltage;
  String get enterValues;

  // Calculator Outputs
  String get ok;
  String get critical;
  String get voltageDropPercentage;
  String get exceedsLightingLimit;
  String get exceedsPowerLimit;

  // Pikolab Connect Extended
  String get pikolabEngineering;
  String get yourPartner;
  String get getExpertSupport;
  String get instantSupport;
  String get technicalQuestion;
  String get chatWhatsApp;
  String get requestQuote;
  String get getPricing;
  String get selectCategory;
  String get category;
  String get describeRequirements;
  String get requirementsHint;
  String get sendRequest;
  String get proMember;
  String get proCommunity;
  String get proUnlocked;
  String get unlockInsights;
  String get followLinkedInPrompt;
  String get industryInsights;
  String get earlyAccess;
  String get webinarInvitations;
  String get followOnLinkedIn;
  String get visitWebsite;
  String get thankYouFollowing;

  // Categories
  String get processAnalytics;
  String get automationControl;
  String get industrialChemicals;
  String get bioprocessEquipment;
  String get otherCategory;

  // Promo Headlines
  String get automationSystems;
  String get pumpSolutions;
  String get labEquipment;
  String get bioreactorSensors;
  String get exploreSolutions;
  String get getQuote;
  String get learnMore;

  // Auth Extended
  String get signingIn;
  String get signInFailed;

  // Errors & Messages
  String get couldNotOpenWhatsApp;
  String get couldNotOpenEmail;
  String get couldNotOpenLinkedIn;
  String get openingEmail;
  String get proFeaturesUnlocked;

  // Field Logger
  String get fieldLogger;
  String get fieldLoggerDesc;
  String get sessionName;
  String get sessionNameHint;
  String get enterSessionName;
  String get parameters;
  String get addParameter;
  String get startLogging;
  String get recordPoint;
  String get endSession;
  String get entries;
  String get sessionSummary;
  String get exportCsv;

  // Piping Master
  String get pipingMaster;
  String get pipingMasterDesc;
  String get flangeSelector;
  String get probeFitting;
  String get selectParameters;
  String get standard;
  String get pressureClass;
  String get nominalSize;
  String get assemblyKit;
  String get boltKit;
  String get spannerSize;
  String get holeDiameter;
  String get sensorConfiguration;
  String get sensorLength;
  String get fittingType;
  String get pipeDiameter;
  String get calculationResults;
  String get deadLength;
  String get insertionDepth;
  String get pipeRadius;
  String get penetration;
}

/// Turkish strings implementation.
class TurkishStrings implements AppStrings {
  // General
  @override String get appName => 'QorEng';
  @override String get guest => 'Misafir';
  @override String get engineer => 'Mühendis';
  @override String get calculate => 'Hesapla';
  @override String get result => 'Sonuç';
  @override String get results => 'Sonuçlar';
  @override String get inputs => 'Girdiler';
  @override String get exportPdf => 'PDF Dışa Aktar';
  @override String get save => 'Kaydet';
  @override String get cancel => 'İptal';
  @override String get close => 'Kapat';
  @override String get search => 'Ara';
  @override String get searchHint => 'Hesap makinesi ara...';
  @override String get noResults => 'Sonuç bulunamadı';
  @override String get loading => 'Yükleniyor...';
  @override String get error => 'Hata';
  @override String get success => 'Başarılı';
  @override String get warning => 'Uyarı';

  // Greetings
  @override String get goodMorning => 'Günaydın';
  @override String get goodAfternoon => 'İyi Öğlenler';
  @override String get goodEvening => 'İyi Akşamlar';
  @override String get nightShift => 'Gece Vardiyası';

  // Dashboard
  @override String get modules => 'Modüller';
  @override String get quickAccess => 'Hızlı Erişim';
  @override String get recentActivity => 'Son İşlemler';
  @override String get viewAll => 'Tümünü Gör';
  @override String get noRecentActivity => 'Henüz işlem yok';

  // Modules
  @override String get electrical => 'Elektrik';
  @override String get electricalDesc => 'Elektrik hesaplamaları';
  @override String get mechanical => 'Mekanik';
  @override String get mechanicalDesc => 'Akışkan ve basınç';
  @override String get chemical => 'Kimya';
  @override String get chemicalDesc => 'Konsantrasyon ve reaksiyon';
  @override String get bioprocess => 'Bioprocess';
  @override String get bioprocessDesc => 'Fermantasyon hesaplamaları';

  // Electrical calculators
  @override String get ohmsLaw => 'Ohm Kanunu';
  @override String get ohmsLawDesc => 'V = I × R hesapla';
  @override String get powerCalculator => 'Güç Hesaplama';
  @override String get powerCalculatorDesc => 'Elektrik gücü hesapla';
  @override String get voltageDrop => 'Voltaj Düşümü';
  @override String get voltageDropDesc => 'Kablo voltaj düşümü';
  @override String get vfdSpeed => 'VFD Hız';
  @override String get vfdSpeedDesc => 'Motor hız kontrolü';
  @override String get signalScaler => 'Sinyal Ölçekleme';
  @override String get signalScalerDesc => '4-20mA / 0-10V dönüşüm';

  // Mechanical calculators
  @override String get reynoldsNumber => 'Reynolds Sayısı';
  @override String get reynoldsNumberDesc => 'Akış rejimi analizi';
  @override String get hydraulicForce => 'Hidrolik Kuvvet';
  @override String get hydraulicForceDesc => 'Silindir kuvvet hesabı';
  @override String get pressureDrop => 'Basınç Düşümü';
  @override String get pressureDropDesc => 'Boru basınç kaybı';
  @override String get flowVelocity => 'Akış Hızı';
  @override String get flowVelocityDesc => 'Debi-hız dönüşümü';

  // Chemical calculators
  @override String get molarity => 'Molarite';
  @override String get molarityDesc => 'Çözelti konsantrasyonu';
  @override String get dilution => 'Seyreltme';
  @override String get dilutionDesc => 'C1V1 = C2V2 hesabı';
  @override String get arrhenius => 'Arrhenius';
  @override String get arrheniusDesc => 'Reaksiyon hızı';
  @override String get odCellDensity => 'OD Hücre Yoğunluğu';
  @override String get odCellDensityDesc => 'Optik yoğunluk hesabı';
  @override String get beerLambert => 'Beer-Lambert';
  @override String get beerLambertDesc => 'Absorbans hesabı';
  @override String get phSensor => 'pH Sensör';
  @override String get phSensorDesc => 'pH kalibrasyon ve tanılama';

  // Bioprocess calculators
  @override String get tipSpeed => 'Uç Hızı';
  @override String get tipSpeedDesc => 'Karıştırıcı uç hızı';

  // Common fields
  @override String get voltage => 'Voltaj';
  @override String get current => 'Akım';
  @override String get resistance => 'Direnç';
  @override String get power => 'Güç';
  @override String get frequency => 'Frekans';
  @override String get diameter => 'Çap';
  @override String get length => 'Uzunluk';
  @override String get area => 'Alan';
  @override String get volume => 'Hacim';
  @override String get mass => 'Kütle';
  @override String get concentration => 'Konsantrasyon';
  @override String get temperature => 'Sıcaklık';
  @override String get pressure => 'Basınç';
  @override String get flowRate => 'Debi';
  @override String get velocity => 'Hız';
  @override String get density => 'Yoğunluk';
  @override String get viscosity => 'Viskozite';

  // Units
  @override String get volts => 'V';
  @override String get amperes => 'A';
  @override String get ohms => 'Ω';
  @override String get watts => 'W';
  @override String get kilowatts => 'kW';
  @override String get hertz => 'Hz';
  @override String get meters => 'm';
  @override String get millimeters => 'mm';
  @override String get liters => 'L';
  @override String get milliliters => 'mL';
  @override String get grams => 'g';
  @override String get kilograms => 'kg';
  @override String get molar => 'M';
  @override String get celsius => '°C';
  @override String get kelvin => 'K';
  @override String get pascal => 'Pa';
  @override String get bar => 'bar';
  @override String get psi => 'psi';

  // Pikolab Connect
  @override String get pikolabConnect => 'Pikolab Connect';
  @override String get pikolabConnectDesc => 'Uzman desteği alın';
  @override String get askExpert => 'Uzmana Sor';
  @override String get sendMessage => 'Mesaj Gönder';

  // Notifications
  @override String get notifications => 'Bildirimler';
  @override String get announcements => 'Duyurular';
  @override String get noAnnouncements => 'Henüz duyuru yok';
  @override String get noAnnouncementsDesc => 'Ürün güncellemeleri ve teknik ipuçları burada görünecek.';

  // Auth
  @override String get signIn => 'Giriş Yap';
  @override String get signOut => 'Çıkış Yap';
  @override String get signInWithGoogle => 'Google ile Giriş Yap';
  @override String get continueAsGuest => 'Misafir Olarak Devam Et';
  @override String get unlockFeatures => 'Profesyonel Özellikleri Aç';
  @override String get unlockFeaturesDesc => 'Hesaplamalarınızı kaydedin ve markalı mühendislik raporları oluşturun.';

  // History
  @override String get history => 'Geçmiş';
  @override String get clearHistory => 'Geçmişi Temizle';
  @override String get noHistory => 'Geçmiş boş';

  // Settings
  @override String get settings => 'Ayarlar';
  @override String get language => 'Dil';
  @override String get theme => 'Tema';
  @override String get darkMode => 'Karanlık Mod';
  @override String get lightMode => 'Aydınlık Mod';
  @override String get about => 'Hakkında';
  @override String get version => 'Versiyon';
  @override String get privacyPolicy => 'Gizlilik Politikası';
  @override String get termsOfService => 'Kullanım Koşulları';

  // Navigation
  @override String get home => 'Ana Sayfa';
  @override String get dashboard => 'Gösterge Paneli';
  @override String get searchTools => 'Araç ara...';
  @override String get recentActivityHint => 'Son hesaplamalarınız burada görünecek';
  @override String get comingSoon => 'Yakında';
  @override String get clear => 'Temizle';
  @override String get reset => 'Sıfırla';
  @override String get copyValue => 'Değeri kopyala';

  // Quick Access
  @override String get cableSizing => 'Kablo boyutlandırma';
  @override String get conversionLabel => '4-20mA dönüşüm';
  @override String get viscosityLab => 'Viskozite Lab';
  @override String get dynamicKinematic => 'Dinamik/Kinematik';
  @override String get spectroscopy => 'Spektroskopi';

  // Tab Labels
  @override String get powerCables => 'Güç & Kablo';
  @override String get automationTab => 'Otomasyon';
  @override String get solidsHydraulics => 'Katı & Hidrolik';
  @override String get fluidFlow => 'Akışkan & Debi';

  // Input Labels
  @override String get phaseSystem => 'Faz Sistemi';
  @override String get conductorMaterial => 'İletken Malzeme';
  @override String get cableCrossSection => 'Kablo Kesiti (S)';
  @override String get systemVoltage => 'Sistem Gerilimi';
  @override String get copper => 'Bakır';
  @override String get aluminum => 'Alüminyum';
  @override String get singlePhase => 'Tek Faz (1F)';
  @override String get threePhase => 'Üç Faz (3F)';
  @override String get enterCurrent => 'Akım girin';
  @override String get enterLength => 'Uzunluk girin';
  @override String get enterVoltage => 'Gerilim girin';
  @override String get enterValues => 'Hesaplamak için değer girin';

  // Calculator Outputs
  @override String get ok => 'Tamam';
  @override String get critical => 'Kritik';
  @override String get voltageDropPercentage => 'Gerilim Düşümü Yüzdesi';
  @override String get exceedsLightingLimit => 'Gerilim düşümü aydınlatma devreleri için %3 sınırını aşıyor!';
  @override String get exceedsPowerLimit => 'Gerilim düşümü güç devreleri için %5 sınırını aşıyor!';

  // Pikolab Connect Extended
  @override String get pikolabEngineering => 'Pikolab Mühendislik';
  @override String get yourPartner => 'Proses Mühendisliği Ortağınız';
  @override String get getExpertSupport => 'Uzman desteği alın, teklif isteyin ve profesyonel topluluğumuza katılın.';
  @override String get instantSupport => 'WhatsApp ile anında destek alın';
  @override String get technicalQuestion => 'Sürecinizle ilgili teknik sorunuz mu var? Mühendislerimiz yardıma hazır.';
  @override String get chatWhatsApp => 'WhatsApp\'ta Sohbet';
  @override String get requestQuote => 'Teklif İste';
  @override String get getPricing => 'Ekipman ve hizmetler için fiyat alın';
  @override String get selectCategory => 'Bir kategori seçin ve ihtiyaçlarınızı açıklayın:';
  @override String get category => 'Kategori';
  @override String get describeRequirements => 'Gereksinimlerinizi açıklayın';
  @override String get requirementsHint => 'örn. biyoreaktör izleme için pH sensörleri...';
  @override String get sendRequest => 'İstek Gönder';
  @override String get proMember => 'Pro Üye';
  @override String get proCommunity => 'Pro Topluluk';
  @override String get proUnlocked => 'Pro özelliklerin kilidini açtınız!';
  @override String get unlockInsights => 'Özel içerik ve özelliklere erişin';
  @override String get followLinkedInPrompt => 'Kilidi açmak için Pikolab\'ı LinkedIn\'de takip edin:';
  @override String get industryInsights => 'Sektör analizleri ve en iyi uygulamalar';
  @override String get earlyAccess => 'Yeni hesaplayıcılara erken erişim';
  @override String get webinarInvitations => 'Özel webinar davetleri';
  @override String get followOnLinkedIn => 'LinkedIn\'de Takip Et';
  @override String get visitWebsite => 'pikolab.com\'u ziyaret edin';
  @override String get thankYouFollowing => 'Takip ettiğiniz için teşekkürler!';

  // Categories
  @override String get processAnalytics => 'Proses Analitiği';
  @override String get automationControl => 'Otomasyon ve Kontrol';
  @override String get industrialChemicals => 'Endüstriyel Kimyasallar';
  @override String get bioprocessEquipment => 'Biyoproses Ekipmanları';
  @override String get otherCategory => 'Diğer';

  // Promo Headlines
  @override String get automationSystems => 'Otomasyon ve Kontrol Sistemleri';
  @override String get pumpSolutions => 'Endüstriyel Pompa ve Akış Çözümleri';
  @override String get labEquipment => 'Proses Analitiği ve Laboratuvar Ekipmanları';
  @override String get bioreactorSensors => 'Biyoreaktör Sensörlerine mi İhtiyacınız Var?';
  @override String get exploreSolutions => 'Çözümleri Keşfedin';
  @override String get getQuote => 'Teklif Alın';
  @override String get learnMore => 'Daha Fazla Bilgi';

  // Auth Extended
  @override String get signingIn => 'Giriş yapılıyor...';
  @override String get signInFailed => 'Giriş iptal edildi veya başarısız oldu';

  // Errors & Messages
  @override String get couldNotOpenWhatsApp => 'WhatsApp açılamadı';
  @override String get couldNotOpenEmail => 'E-posta istemcisi açılamadı';
  @override String get couldNotOpenLinkedIn => 'LinkedIn açılamadı';
  @override String get openingEmail => 'E-posta istemcisi açılıyor...';
  @override String get proFeaturesUnlocked => '🎉 Pro özellikler açıldı! Takip ettiğiniz için teşekkürler.';

  // Field Logger
  @override String get fieldLogger => 'Saha Kaydı';
  @override String get fieldLoggerDesc => 'Zaman serisi veri kaydı';
  @override String get sessionName => 'Oturum Adı';
  @override String get sessionNameHint => 'örn. Reaktör 3 Testi';
  @override String get enterSessionName => 'Oturum adı girin';
  @override String get parameters => 'Parametreler';
  @override String get addParameter => 'Parametre Ekle';
  @override String get startLogging => 'Kayda Başla';
  @override String get recordPoint => 'Nokta Kaydet';
  @override String get endSession => 'Oturumu Bitir';
  @override String get entries => 'Kayıtlar';
  @override String get sessionSummary => 'Oturum Özeti';
  @override String get exportCsv => 'CSV Dışa Aktar';

  // Piping Master
  @override String get pipingMaster => 'Boru Ustası';
  @override String get pipingMasterDesc => 'Flanş ve sensör montajı';
  @override String get flangeSelector => 'Flanş Seçici';
  @override String get probeFitting => 'Prob Montaj Hesabı';
  @override String get selectParameters => 'Parametre Seçin';
  @override String get standard => 'Standart';
  @override String get pressureClass => 'Basınç Sınıfı';
  @override String get nominalSize => 'Nominal Çap';
  @override String get assemblyKit => 'Montaj Kiti';
  @override String get boltKit => 'Cıvata Kiti';
  @override String get spannerSize => 'Anahtar Ağzı';
  @override String get holeDiameter => 'Delik Çapı';
  @override String get sensorConfiguration => 'Sensör Konfigürasyonu';
  @override String get sensorLength => 'Sensör Boyu';
  @override String get fittingType => 'Bağlantı Tipi';
  @override String get pipeDiameter => 'Boru Çapı';
  @override String get calculationResults => 'Hesaplama Sonuçları';
  @override String get deadLength => 'Ölü Boy (Housing)';
  @override String get insertionDepth => 'Daldırma Derinliği';
  @override String get pipeRadius => 'Boru Yarıçapı';
  @override String get penetration => 'Nüfuz Oranı';
}

/// English strings implementation.
class EnglishStrings implements AppStrings {
  // General
  @override String get appName => 'QorEng';
  @override String get guest => 'Guest';
  @override String get engineer => 'Engineer';
  @override String get calculate => 'Calculate';
  @override String get result => 'Result';
  @override String get results => 'Results';
  @override String get inputs => 'Inputs';
  @override String get exportPdf => 'Export PDF';
  @override String get save => 'Save';
  @override String get cancel => 'Cancel';
  @override String get close => 'Close';
  @override String get search => 'Search';
  @override String get searchHint => 'Search calculators...';
  @override String get noResults => 'No results found';
  @override String get loading => 'Loading...';
  @override String get error => 'Error';
  @override String get success => 'Success';
  @override String get warning => 'Warning';

  // Greetings
  @override String get goodMorning => 'Good Morning';
  @override String get goodAfternoon => 'Good Afternoon';
  @override String get goodEvening => 'Good Evening';
  @override String get nightShift => 'Night Shift';

  // Dashboard
  @override String get modules => 'Modules';
  @override String get quickAccess => 'Quick Access';
  @override String get recentActivity => 'Recent Activity';
  @override String get viewAll => 'View All';
  @override String get noRecentActivity => 'No activity yet';

  // Modules
  @override String get electrical => 'Electrical';
  @override String get electricalDesc => 'Electrical calculations';
  @override String get mechanical => 'Mechanical';
  @override String get mechanicalDesc => 'Fluid & pressure';
  @override String get chemical => 'Chemical';
  @override String get chemicalDesc => 'Concentration & reaction';
  @override String get bioprocess => 'Bioprocess';
  @override String get bioprocessDesc => 'Fermentation calculations';

  // Electrical calculators
  @override String get ohmsLaw => "Ohm's Law";
  @override String get ohmsLawDesc => 'Calculate V = I × R';
  @override String get powerCalculator => 'Power Calculator';
  @override String get powerCalculatorDesc => 'Calculate electrical power';
  @override String get voltageDrop => 'Voltage Drop';
  @override String get voltageDropDesc => 'Cable voltage drop';
  @override String get vfdSpeed => 'VFD Speed';
  @override String get vfdSpeedDesc => 'Motor speed control';
  @override String get signalScaler => 'Signal Scaler';
  @override String get signalScalerDesc => '4-20mA / 0-10V conversion';

  // Mechanical calculators
  @override String get reynoldsNumber => 'Reynolds Number';
  @override String get reynoldsNumberDesc => 'Flow regime analysis';
  @override String get hydraulicForce => 'Hydraulic Force';
  @override String get hydraulicForceDesc => 'Cylinder force calculation';
  @override String get pressureDrop => 'Pressure Drop';
  @override String get pressureDropDesc => 'Pipe pressure loss';
  @override String get flowVelocity => 'Flow Velocity';
  @override String get flowVelocityDesc => 'Flow rate to velocity';

  // Chemical calculators
  @override String get molarity => 'Molarity';
  @override String get molarityDesc => 'Solution concentration';
  @override String get dilution => 'Dilution';
  @override String get dilutionDesc => 'C1V1 = C2V2 calculation';
  @override String get arrhenius => 'Arrhenius';
  @override String get arrheniusDesc => 'Reaction rate';
  @override String get odCellDensity => 'OD Cell Density';
  @override String get odCellDensityDesc => 'Optical density calculation';
  @override String get beerLambert => 'Beer-Lambert';
  @override String get beerLambertDesc => 'Absorbance calculation';
  @override String get phSensor => 'pH Sensor';
  @override String get phSensorDesc => 'pH calibration & diagnostics';

  // Bioprocess calculators
  @override String get tipSpeed => 'Tip Speed';
  @override String get tipSpeedDesc => 'Impeller tip speed';

  // Common fields
  @override String get voltage => 'Voltage';
  @override String get current => 'Current';
  @override String get resistance => 'Resistance';
  @override String get power => 'Power';
  @override String get frequency => 'Frequency';
  @override String get diameter => 'Diameter';
  @override String get length => 'Length';
  @override String get area => 'Area';
  @override String get volume => 'Volume';
  @override String get mass => 'Mass';
  @override String get concentration => 'Concentration';
  @override String get temperature => 'Temperature';
  @override String get pressure => 'Pressure';
  @override String get flowRate => 'Flow Rate';
  @override String get velocity => 'Velocity';
  @override String get density => 'Density';
  @override String get viscosity => 'Viscosity';

  // Units
  @override String get volts => 'V';
  @override String get amperes => 'A';
  @override String get ohms => 'Ω';
  @override String get watts => 'W';
  @override String get kilowatts => 'kW';
  @override String get hertz => 'Hz';
  @override String get meters => 'm';
  @override String get millimeters => 'mm';
  @override String get liters => 'L';
  @override String get milliliters => 'mL';
  @override String get grams => 'g';
  @override String get kilograms => 'kg';
  @override String get molar => 'M';
  @override String get celsius => '°C';
  @override String get kelvin => 'K';
  @override String get pascal => 'Pa';
  @override String get bar => 'bar';
  @override String get psi => 'psi';

  // Pikolab Connect
  @override String get pikolabConnect => 'Pikolab Connect';
  @override String get pikolabConnectDesc => 'Get expert support';
  @override String get askExpert => 'Ask Expert';
  @override String get sendMessage => 'Send Message';

  // Notifications
  @override String get notifications => 'Notifications';
  @override String get announcements => 'Announcements';
  @override String get noAnnouncements => 'No announcements yet';
  @override String get noAnnouncementsDesc => 'Product updates and technical tips will appear here.';

  // Auth
  @override String get signIn => 'Sign In';
  @override String get signOut => 'Sign Out';
  @override String get signInWithGoogle => 'Sign in with Google';
  @override String get continueAsGuest => 'Continue as Guest';
  @override String get unlockFeatures => 'Unlock Professional Features';
  @override String get unlockFeaturesDesc => 'Save your calculations and generate branded engineering reports.';

  // History
  @override String get history => 'History';
  @override String get clearHistory => 'Clear History';
  @override String get noHistory => 'History is empty';

  // Settings
  @override String get settings => 'Settings';
  @override String get language => 'Language';
  @override String get theme => 'Theme';
  @override String get darkMode => 'Dark Mode';
  @override String get lightMode => 'Light Mode';
  @override String get about => 'About';
  @override String get version => 'Version';
  @override String get privacyPolicy => 'Privacy Policy';
  @override String get termsOfService => 'Terms of Service';

  // Navigation
  @override String get home => 'Home';
  @override String get dashboard => 'Dashboard';
  @override String get searchTools => 'Search tools...';
  @override String get recentActivityHint => 'Your recent calculations will appear here';
  @override String get comingSoon => 'Coming soon';
  @override String get clear => 'Clear';
  @override String get reset => 'Reset';
  @override String get copyValue => 'Copy value';

  // Quick Access
  @override String get cableSizing => 'Cable sizing';
  @override String get conversionLabel => '4-20mA conversion';
  @override String get viscosityLab => 'Viscosity Lab';
  @override String get dynamicKinematic => 'Dynamic/Kinematic';
  @override String get spectroscopy => 'Spectroscopy';

  // Tab Labels
  @override String get powerCables => 'Power & Cables';
  @override String get automationTab => 'Automation';
  @override String get solidsHydraulics => 'Solids & Hydraulics';
  @override String get fluidFlow => 'Fluid & Flow';

  // Input Labels
  @override String get phaseSystem => 'Phase System';
  @override String get conductorMaterial => 'Conductor Material';
  @override String get cableCrossSection => 'Cable Cross-Section (S)';
  @override String get systemVoltage => 'System Voltage';
  @override String get copper => 'Copper';
  @override String get aluminum => 'Aluminum';
  @override String get singlePhase => 'Single Phase (1P)';
  @override String get threePhase => 'Three Phase (3P)';
  @override String get enterCurrent => 'Enter current';
  @override String get enterLength => 'Enter length';
  @override String get enterVoltage => 'Enter voltage';
  @override String get enterValues => 'Enter values to calculate';

  // Calculator Outputs
  @override String get ok => 'OK';
  @override String get critical => 'Critical';
  @override String get voltageDropPercentage => 'Voltage Drop Percentage';
  @override String get exceedsLightingLimit => 'Voltage drop exceeds 3% limit for lighting circuits!';
  @override String get exceedsPowerLimit => 'Voltage drop exceeds 5% limit for power circuits!';

  // Pikolab Connect Extended
  @override String get pikolabEngineering => 'Pikolab Engineering';
  @override String get yourPartner => 'Your Process Engineering Partner';
  @override String get getExpertSupport => 'Get expert support, request quotes, and join our professional community.';
  @override String get instantSupport => 'Get instant support via WhatsApp';
  @override String get technicalQuestion => 'Have a technical question about your process? Our engineers are ready to help.';
  @override String get chatWhatsApp => 'Chat on WhatsApp';
  @override String get requestQuote => 'Request Quote';
  @override String get getPricing => 'Get pricing for equipment & services';
  @override String get selectCategory => 'Select a category and describe your needs:';
  @override String get category => 'Category';
  @override String get describeRequirements => 'Describe your requirements';
  @override String get requirementsHint => 'e.g., pH sensors for bioreactor monitoring...';
  @override String get sendRequest => 'Send Request';
  @override String get proMember => 'Pro Member';
  @override String get proCommunity => 'Pro Community';
  @override String get proUnlocked => 'You have unlocked pro features!';
  @override String get unlockInsights => 'Unlock exclusive insights & features';
  @override String get followLinkedInPrompt => 'Follow Pikolab on LinkedIn to unlock:';
  @override String get industryInsights => 'Industry insights & best practices';
  @override String get earlyAccess => 'Early access to new calculators';
  @override String get webinarInvitations => 'Exclusive webinar invitations';
  @override String get followOnLinkedIn => 'Follow on LinkedIn';
  @override String get visitWebsite => 'Visit pikolab.com';
  @override String get thankYouFollowing => 'Thank you for following!';

  // Categories
  @override String get processAnalytics => 'Process Analytics';
  @override String get automationControl => 'Automation & Control';
  @override String get industrialChemicals => 'Industrial Chemicals';
  @override String get bioprocessEquipment => 'Bioprocess Equipment';
  @override String get otherCategory => 'Other';

  // Promo Headlines
  @override String get automationSystems => 'Automation & Control Systems';
  @override String get pumpSolutions => 'Industrial Pump & Flow Solutions';
  @override String get labEquipment => 'Process Analytics & Lab Equipment';
  @override String get bioreactorSensors => 'Need Bioreactor Sensors?';
  @override String get exploreSolutions => 'Explore Solutions';
  @override String get getQuote => 'Get Quote';
  @override String get learnMore => 'Learn More';

  // Auth Extended
  @override String get signingIn => 'Signing in...';
  @override String get signInFailed => 'Sign-in was cancelled or failed';

  // Errors & Messages
  @override String get couldNotOpenWhatsApp => 'Could not open WhatsApp';
  @override String get couldNotOpenEmail => 'Could not open email client';
  @override String get couldNotOpenLinkedIn => 'Could not open LinkedIn';
  @override String get openingEmail => 'Opening email client...';
  @override String get proFeaturesUnlocked => '🎉 Pro features unlocked! Thank you for following.';

  // Field Logger
  @override String get fieldLogger => 'Field Logger';
  @override String get fieldLoggerDesc => 'Time-series data logging';
  @override String get sessionName => 'Session Name';
  @override String get sessionNameHint => 'e.g., Reactor 3 Test';
  @override String get enterSessionName => 'Enter session name';
  @override String get parameters => 'Parameters';
  @override String get addParameter => 'Add Parameter';
  @override String get startLogging => 'Start Logging';
  @override String get recordPoint => 'Record Point';
  @override String get endSession => 'End Session';
  @override String get entries => 'Entries';
  @override String get sessionSummary => 'Session Summary';
  @override String get exportCsv => 'Export CSV';

  // Piping Master
  @override String get pipingMaster => 'Piping Master';
  @override String get pipingMasterDesc => 'Flange & sensor fittings';
  @override String get flangeSelector => 'Flange Selector';
  @override String get probeFitting => 'Probe Fitting Calculator';
  @override String get selectParameters => 'Select Parameters';
  @override String get standard => 'Standard';
  @override String get pressureClass => 'Pressure Class';
  @override String get nominalSize => 'Nominal Size';
  @override String get assemblyKit => 'Assembly Kit';
  @override String get boltKit => 'Bolt Kit';
  @override String get spannerSize => 'Spanner Size';
  @override String get holeDiameter => 'Hole Diameter';
  @override String get sensorConfiguration => 'Sensor Configuration';
  @override String get sensorLength => 'Sensor Length';
  @override String get fittingType => 'Fitting Type';
  @override String get pipeDiameter => 'Pipe Diameter';
  @override String get calculationResults => 'Calculation Results';
  @override String get deadLength => 'Dead Length (Housing)';
  @override String get insertionDepth => 'Insertion Depth';
  @override String get pipeRadius => 'Pipe Radius';
  @override String get penetration => 'Penetration';
}
