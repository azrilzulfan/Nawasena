import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('id'),
    Locale('en'),
  ];

  /// Nama aplikasi
  ///
  /// In id, this message translates to:
  /// **'Nawasena'**
  String get appName;

  /// No description provided for @greeting_morning.
  ///
  /// In id, this message translates to:
  /// **'Selamat Pagi'**
  String get greeting_morning;

  /// No description provided for @greeting_afternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat Siang'**
  String get greeting_afternoon;

  /// No description provided for @greeting_evening.
  ///
  /// In id, this message translates to:
  /// **'Selamat Sore'**
  String get greeting_evening;

  /// No description provided for @greeting_night.
  ///
  /// In id, this message translates to:
  /// **'Selamat Malam'**
  String get greeting_night;

  /// No description provided for @btn_login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get btn_login;

  /// No description provided for @btn_register.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get btn_register;

  /// No description provided for @btn_logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get btn_logout;

  /// No description provided for @btn_save.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get btn_save;

  /// No description provided for @btn_retry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get btn_retry;

  /// No description provided for @btn_cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get btn_cancel;

  /// No description provided for @btn_donate_now.
  ///
  /// In id, this message translates to:
  /// **'Donasikan Sekarang'**
  String get btn_donate_now;

  /// No description provided for @btn_join_workshop.
  ///
  /// In id, this message translates to:
  /// **'Daftar Sebagai Relawan'**
  String get btn_join_workshop;

  /// No description provided for @btn_checkin.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Check-in'**
  String get btn_checkin;

  /// No description provided for @btn_mark_sent.
  ///
  /// In id, this message translates to:
  /// **'Tandai Sudah Dikirim'**
  String get btn_mark_sent;

  /// No description provided for @label_email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get label_email;

  /// No description provided for @label_password.
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get label_password;

  /// No description provided for @label_full_name.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get label_full_name;

  /// No description provided for @label_confirm_password.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Password'**
  String get label_confirm_password;

  /// No description provided for @label_role.
  ///
  /// In id, this message translates to:
  /// **'Peran'**
  String get label_role;

  /// No description provided for @label_donor.
  ///
  /// In id, this message translates to:
  /// **'Donor'**
  String get label_donor;

  /// No description provided for @label_volunteer.
  ///
  /// In id, this message translates to:
  /// **'Relawan'**
  String get label_volunteer;

  /// No description provided for @role_donor_desc.
  ///
  /// In id, this message translates to:
  /// **'Donasikan barang & kebutuhan ke panti'**
  String get role_donor_desc;

  /// No description provided for @role_volunteer_desc.
  ///
  /// In id, this message translates to:
  /// **'Ikuti kegiatan sosial & workshop panti'**
  String get role_volunteer_desc;

  /// No description provided for @nav_home.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get nav_home;

  /// No description provided for @nav_explore.
  ///
  /// In id, this message translates to:
  /// **'Jelajahi'**
  String get nav_explore;

  /// No description provided for @nav_history.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get nav_history;

  /// No description provided for @nav_profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get nav_profile;

  /// No description provided for @urgent_high.
  ///
  /// In id, this message translates to:
  /// **'Mendesak'**
  String get urgent_high;

  /// No description provided for @urgent_medium.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get urgent_medium;

  /// No description provided for @urgent_low.
  ///
  /// In id, this message translates to:
  /// **'Rendah'**
  String get urgent_low;

  /// No description provided for @status_pending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get status_pending;

  /// No description provided for @status_sent.
  ///
  /// In id, this message translates to:
  /// **'Dikirim'**
  String get status_sent;

  /// No description provided for @status_received.
  ///
  /// In id, this message translates to:
  /// **'Diterima'**
  String get status_received;

  /// No description provided for @status_verified.
  ///
  /// In id, this message translates to:
  /// **'Terverifikasi'**
  String get status_verified;

  /// No description provided for @workshop_open.
  ///
  /// In id, this message translates to:
  /// **'Buka'**
  String get workshop_open;

  /// No description provided for @workshop_closed.
  ///
  /// In id, this message translates to:
  /// **'Ditutup'**
  String get workshop_closed;

  /// No description provided for @workshop_done.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get workshop_done;

  /// No description provided for @category_logistik.
  ///
  /// In id, this message translates to:
  /// **'Logistik'**
  String get category_logistik;

  /// No description provided for @category_edukasi.
  ///
  /// In id, this message translates to:
  /// **'Edukasi'**
  String get category_edukasi;

  /// No description provided for @category_medis.
  ///
  /// In id, this message translates to:
  /// **'Medis'**
  String get category_medis;

  /// No description provided for @error_network.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'**
  String get error_network;

  /// No description provided for @error_unauthorized.
  ///
  /// In id, this message translates to:
  /// **'Sesi telah berakhir. Silakan login kembali.'**
  String get error_unauthorized;

  /// No description provided for @error_not_found.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan.'**
  String get error_not_found;

  /// No description provided for @error_validation.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali data yang Anda masukkan.'**
  String get error_validation;

  /// No description provided for @error_server.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan pada server. Coba lagi nanti.'**
  String get error_server;

  /// No description provided for @validator_required.
  ///
  /// In id, this message translates to:
  /// **'{field} tidak boleh kosong.'**
  String validator_required(String field);

  /// No description provided for @validator_email_invalid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid.'**
  String get validator_email_invalid;

  /// No description provided for @validator_password_min.
  ///
  /// In id, this message translates to:
  /// **'Password minimal 8 karakter.'**
  String get validator_password_min;

  /// No description provided for @validator_password_mismatch.
  ///
  /// In id, this message translates to:
  /// **'Password tidak cocok.'**
  String get validator_password_mismatch;

  /// No description provided for @validator_positive_number.
  ///
  /// In id, this message translates to:
  /// **'{field} harus lebih dari 0.'**
  String validator_positive_number(String field);

  /// No description provided for @donation_pledge_success.
  ///
  /// In id, this message translates to:
  /// **'Donasi berhasil diajukan!'**
  String get donation_pledge_success;

  /// No description provided for @donation_status_updated.
  ///
  /// In id, this message translates to:
  /// **'Status donasi berhasil diperbarui!'**
  String get donation_status_updated;

  /// No description provided for @profile_update_success.
  ///
  /// In id, this message translates to:
  /// **'Profil berhasil diperbarui!'**
  String get profile_update_success;

  /// No description provided for @workshop_register_success.
  ///
  /// In id, this message translates to:
  /// **'Berhasil mendaftar sebagai relawan!'**
  String get workshop_register_success;

  /// No description provided for @workshop_unregister_success.
  ///
  /// In id, this message translates to:
  /// **'Pendaftaran berhasil dibatalkan.'**
  String get workshop_unregister_success;

  /// No description provided for @checkin_success.
  ///
  /// In id, this message translates to:
  /// **'Check-in berhasil dikonfirmasi!'**
  String get checkin_success;

  /// No description provided for @copied_to_clipboard.
  ///
  /// In id, this message translates to:
  /// **'Disalin ke clipboard!'**
  String get copied_to_clipboard;

  /// No description provided for @geofence_inside.
  ///
  /// In id, this message translates to:
  /// **'Anda berada dalam area check-in!'**
  String get geofence_inside;

  /// No description provided for @geofence_outside.
  ///
  /// In id, this message translates to:
  /// **'Anda belum dalam area check-in'**
  String get geofence_outside;

  /// No description provided for @geofence_move_closer.
  ///
  /// In id, this message translates to:
  /// **'Dekati {distance} meter lagi ke lokasi workshop.'**
  String geofence_move_closer(String distance);

  /// No description provided for @impact_total_donations.
  ///
  /// In id, this message translates to:
  /// **'Total Donasi'**
  String get impact_total_donations;

  /// No description provided for @impact_foundations_helped.
  ///
  /// In id, this message translates to:
  /// **'Panti Dibantu'**
  String get impact_foundations_helped;

  /// No description provided for @impact_items_sent.
  ///
  /// In id, this message translates to:
  /// **'Item Dikirim'**
  String get impact_items_sent;

  /// No description provided for @impact_workshops_attended.
  ///
  /// In id, this message translates to:
  /// **'Workshop Diikuti'**
  String get impact_workshops_attended;

  /// No description provided for @impact_volunteer_hours.
  ///
  /// In id, this message translates to:
  /// **'Jam Relawan'**
  String get impact_volunteer_hours;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
