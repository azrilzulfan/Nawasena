// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nawasena';

  @override
  String get greeting_morning => 'Good Morning';

  @override
  String get greeting_afternoon => 'Good Afternoon';

  @override
  String get greeting_evening => 'Good Evening';

  @override
  String get greeting_night => 'Good Night';

  @override
  String get btn_login => 'Sign In';

  @override
  String get btn_register => 'Register';

  @override
  String get btn_logout => 'Sign Out';

  @override
  String get btn_save => 'Save Changes';

  @override
  String get btn_retry => 'Try Again';

  @override
  String get btn_cancel => 'Cancel';

  @override
  String get btn_donate_now => 'Donate Now';

  @override
  String get btn_join_workshop => 'Register as Volunteer';

  @override
  String get btn_checkin => 'Confirm Check-in';

  @override
  String get btn_mark_sent => 'Mark as Sent';

  @override
  String get label_email => 'Email';

  @override
  String get label_password => 'Password';

  @override
  String get label_full_name => 'Full Name';

  @override
  String get label_confirm_password => 'Confirm Password';

  @override
  String get label_role => 'Role';

  @override
  String get label_donor => 'Donor';

  @override
  String get label_volunteer => 'Volunteer';

  @override
  String get role_donor_desc => 'Donate goods & supplies to orphanages';

  @override
  String get role_volunteer_desc => 'Join social activities & workshops';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_explore => 'Explore';

  @override
  String get nav_history => 'History';

  @override
  String get nav_profile => 'Profile';

  @override
  String get urgent_high => 'Urgent';

  @override
  String get urgent_medium => 'Moderate';

  @override
  String get urgent_low => 'Low';

  @override
  String get status_pending => 'Pending';

  @override
  String get status_sent => 'Sent';

  @override
  String get status_received => 'Received';

  @override
  String get status_verified => 'Verified';

  @override
  String get workshop_open => 'Open';

  @override
  String get workshop_closed => 'Closed';

  @override
  String get workshop_done => 'Done';

  @override
  String get category_logistik => 'Logistics';

  @override
  String get category_edukasi => 'Education';

  @override
  String get category_medis => 'Medical';

  @override
  String get error_network =>
      'Cannot reach server. Check your internet connection.';

  @override
  String get error_unauthorized => 'Session expired. Please sign in again.';

  @override
  String get error_not_found => 'Resource not found.';

  @override
  String get error_validation => 'Please check the data you entered.';

  @override
  String get error_server => 'Server error. Please try again later.';

  @override
  String validator_required(String field) {
    return '$field is required.';
  }

  @override
  String get validator_email_invalid => 'Invalid email format.';

  @override
  String get validator_password_min =>
      'Password must be at least 8 characters.';

  @override
  String get validator_password_mismatch => 'Passwords do not match.';

  @override
  String validator_positive_number(String field) {
    return '$field must be greater than 0.';
  }

  @override
  String get donation_pledge_success => 'Donation submitted successfully!';

  @override
  String get donation_status_updated => 'Donation status updated!';

  @override
  String get profile_update_success => 'Profile updated successfully!';

  @override
  String get workshop_register_success =>
      'Registered as volunteer successfully!';

  @override
  String get workshop_unregister_success => 'Registration cancelled.';

  @override
  String get checkin_success => 'Check-in confirmed successfully!';

  @override
  String get copied_to_clipboard => 'Copied to clipboard!';

  @override
  String get geofence_inside => 'You are within the check-in area!';

  @override
  String get geofence_outside => 'You are outside the check-in area';

  @override
  String geofence_move_closer(String distance) {
    return 'Move $distance meters closer to the workshop location.';
  }

  @override
  String get impact_total_donations => 'Total Donations';

  @override
  String get impact_foundations_helped => 'Foundations Helped';

  @override
  String get impact_items_sent => 'Items Sent';

  @override
  String get impact_workshops_attended => 'Workshops Attended';

  @override
  String get impact_volunteer_hours => 'Volunteer Hours';
}
