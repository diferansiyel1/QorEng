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
}
