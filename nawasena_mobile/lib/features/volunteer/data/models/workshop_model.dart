import 'package:equatable/equatable.dart';
import 'package:nawasena_mobile/features/donor/data/models/foundation_model.dart';

enum WorkshopStatus { open, closed, done, unknown }

extension WorkshopStatusX on WorkshopStatus {
  String get label {
    switch (this) {
      case WorkshopStatus.open:    return 'Buka';
      case WorkshopStatus.closed:  return 'Ditutup';
      case WorkshopStatus.done:    return 'Selesai';
      case WorkshopStatus.unknown: return '-';
    }
  }

  static WorkshopStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'open':   return WorkshopStatus.open;
      case 'closed': return WorkshopStatus.closed;
      case 'done':   return WorkshopStatus.done;
      default:       return WorkshopStatus.unknown;
    }
  }
}

enum VolunteerAttendanceStatus { confirmed, attended, absent, unknown }

extension VolunteerAttendanceStatusX on VolunteerAttendanceStatus {
  static VolunteerAttendanceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed': return VolunteerAttendanceStatus.confirmed;
      case 'attended':  return VolunteerAttendanceStatus.attended;
      case 'absent':    return VolunteerAttendanceStatus.absent;
      default:          return VolunteerAttendanceStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case VolunteerAttendanceStatus.confirmed: return 'Terdaftar';
      case VolunteerAttendanceStatus.attended:  return 'Hadir';
      case VolunteerAttendanceStatus.absent:    return 'Tidak Hadir';
      case VolunteerAttendanceStatus.unknown:   return '-';
    }
  }
}

class RegisteredVolunteer extends Equatable {
  final String userId;
  final String userName;
  final VolunteerAttendanceStatus status;
  final DateTime? joinedAt;

  const RegisteredVolunteer({
    required this.userId,
    required this.userName,
    required this.status,
    this.joinedAt,
  });

  factory RegisteredVolunteer.fromJson(Map<String, dynamic> json) {
    return RegisteredVolunteer(
      userId:   json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      status:   VolunteerAttendanceStatusX.fromString(
        json['status']?.toString() ?? '',
      ),
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id':   userId,
    'user_name': userName,
    'status':    status.name,
    'joined_at': joinedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [userId, userName, status, joinedAt];
}

class WorkshopModel extends Equatable {
  final String id;
  final String foundationId;
  final String title;
  final String description;
  final DateTime eventDate;
  final WorkshopStatus status;
  final int mentorNeeded;
  final int mentorRegisteredCount;
  final List<RegisteredVolunteer> registeredVolunteers;
  final GeoLocation? location;
  final int geofenceRadiusMeters;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkshopModel({
    required this.id,
    required this.foundationId,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.status,
    required this.mentorNeeded,
    required this.mentorRegisteredCount,
    this.registeredVolunteers = const [],
    this.location,
    this.geofenceRadiusMeters = 100,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    final volunteersRaw = json['registered_volunteers'] as List<dynamic>? ?? [];
    return WorkshopModel(
      id:           (json['_id'] ?? json['id'] ?? '').toString(),
      foundationId: json['foundation_id']?.toString() ?? '',
      title:        json['title']?.toString() ?? '',
      description:  json['description']?.toString() ?? '',
      eventDate:    json['event_date'] != null
          ? DateTime.tryParse(json['event_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: WorkshopStatusX.fromString(json['status']?.toString() ?? ''),
      mentorNeeded: (json['mentor_needed'] as num?)?.toInt() ?? 0,
      mentorRegisteredCount: (json['mentor_registered_count'] as num?)?.toInt() ?? 0,
      registeredVolunteers: volunteersRaw
          .map((e) => RegisteredVolunteer.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      location: json['location'] != null
          ? GeoLocation.fromJson(Map<String, dynamic>.from(json['location']))
          : null,
      geofenceRadiusMeters:
      (json['geofence_radius_meters'] as num?)?.toInt() ?? 100,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':            id,
    'foundation_id':  foundationId,
    'title':          title,
    'description':    description,
    'event_date':     eventDate.toIso8601String(),
    'status':         status.name,
    'mentor_needed':  mentorNeeded,
    'mentor_registered_count': mentorRegisteredCount,
    'registered_volunteers': registeredVolunteers.map((v) => v.toJson()).toList(),
    'location':       location?.toJson(),
    'geofence_radius_meters': geofenceRadiusMeters,
    'created_at':     createdAt?.toIso8601String(),
    'updated_at':     updatedAt?.toIso8601String(),
  };

  int get remainingSlots =>
      (mentorNeeded - mentorRegisteredCount).clamp(0, mentorNeeded);

  bool get isFull => mentorRegisteredCount >= mentorNeeded;

  bool isUserRegistered(String userId) =>
      registeredVolunteers.any((v) => v.userId == userId);

  @override
  List<Object?> get props => [
    id, foundationId, title, description, eventDate, status,
    mentorNeeded, mentorRegisteredCount, registeredVolunteers,
    location, geofenceRadiusMeters, createdAt, updatedAt,
  ];
}