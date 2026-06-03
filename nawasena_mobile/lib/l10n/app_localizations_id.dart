// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Nawasena';

  @override
  String get greeting_morning => 'Selamat Pagi';

  @override
  String get greeting_afternoon => 'Selamat Siang';

  @override
  String get greeting_evening => 'Selamat Sore';

  @override
  String get greeting_night => 'Selamat Malam';

  @override
  String get btn_login => 'Masuk';

  @override
  String get btn_register => 'Daftar';

  @override
  String get btn_logout => 'Keluar';

  @override
  String get btn_save => 'Simpan Perubahan';

  @override
  String get btn_retry => 'Coba Lagi';

  @override
  String get btn_cancel => 'Batal';

  @override
  String get btn_donate_now => 'Donasikan Sekarang';

  @override
  String get btn_join_workshop => 'Daftar Sebagai Relawan';

  @override
  String get btn_checkin => 'Konfirmasi Check-in';

  @override
  String get btn_mark_sent => 'Tandai Sudah Dikirim';

  @override
  String get label_email => 'Email';

  @override
  String get label_password => 'Password';

  @override
  String get label_full_name => 'Nama Lengkap';

  @override
  String get label_confirm_password => 'Konfirmasi Password';

  @override
  String get label_role => 'Peran';

  @override
  String get label_donor => 'Donor';

  @override
  String get label_volunteer => 'Relawan';

  @override
  String get role_donor_desc => 'Donasikan barang & kebutuhan ke panti';

  @override
  String get role_volunteer_desc => 'Ikuti kegiatan sosial & workshop panti';

  @override
  String get nav_home => 'Beranda';

  @override
  String get nav_explore => 'Jelajahi';

  @override
  String get nav_history => 'Riwayat';

  @override
  String get nav_profile => 'Profil';

  @override
  String get urgent_high => 'Mendesak';

  @override
  String get urgent_medium => 'Sedang';

  @override
  String get urgent_low => 'Rendah';

  @override
  String get status_pending => 'Menunggu';

  @override
  String get status_sent => 'Dikirim';

  @override
  String get status_received => 'Diterima';

  @override
  String get status_verified => 'Terverifikasi';

  @override
  String get workshop_open => 'Buka';

  @override
  String get workshop_closed => 'Ditutup';

  @override
  String get workshop_done => 'Selesai';

  @override
  String get category_logistik => 'Logistik';

  @override
  String get category_edukasi => 'Edukasi';

  @override
  String get category_medis => 'Medis';

  @override
  String get error_network =>
      'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';

  @override
  String get error_unauthorized =>
      'Sesi telah berakhir. Silakan login kembali.';

  @override
  String get error_not_found => 'Data tidak ditemukan.';

  @override
  String get error_validation => 'Periksa kembali data yang Anda masukkan.';

  @override
  String get error_server => 'Terjadi kesalahan pada server. Coba lagi nanti.';

  @override
  String validator_required(String field) {
    return '$field tidak boleh kosong.';
  }

  @override
  String get validator_email_invalid => 'Format email tidak valid.';

  @override
  String get validator_password_min => 'Password minimal 8 karakter.';

  @override
  String get validator_password_mismatch => 'Password tidak cocok.';

  @override
  String validator_positive_number(String field) {
    return '$field harus lebih dari 0.';
  }

  @override
  String get donation_pledge_success => 'Donasi berhasil diajukan!';

  @override
  String get donation_status_updated => 'Status donasi berhasil diperbarui!';

  @override
  String get profile_update_success => 'Profil berhasil diperbarui!';

  @override
  String get workshop_register_success => 'Berhasil mendaftar sebagai relawan!';

  @override
  String get workshop_unregister_success => 'Pendaftaran berhasil dibatalkan.';

  @override
  String get checkin_success => 'Check-in berhasil dikonfirmasi!';

  @override
  String get copied_to_clipboard => 'Disalin ke clipboard!';

  @override
  String get geofence_inside => 'Anda berada dalam area check-in!';

  @override
  String get geofence_outside => 'Anda belum dalam area check-in';

  @override
  String geofence_move_closer(String distance) {
    return 'Dekati $distance meter lagi ke lokasi workshop.';
  }

  @override
  String get impact_total_donations => 'Total Donasi';

  @override
  String get impact_foundations_helped => 'Panti Dibantu';

  @override
  String get impact_items_sent => 'Item Dikirim';

  @override
  String get impact_workshops_attended => 'Workshop Diikuti';

  @override
  String get impact_volunteer_hours => 'Jam Relawan';
}
