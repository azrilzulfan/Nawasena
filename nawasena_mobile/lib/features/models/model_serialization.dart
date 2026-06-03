import 'package:flutter_test/flutter_test.dart';
import 'package:nawasena_mobile/features/auth/data/models/user_model.dart';
import 'package:nawasena_mobile/features/donor/data/models/donation_model.dart';
import 'package:nawasena_mobile/features/donor/data/models/foundation_model.dart';
import 'package:nawasena_mobile/features/donor/data/models/inventory_model.dart';
import 'package:nawasena_mobile/features/volunteer/data/models/workshop_model.dart';

void main() {
  // ── UserModel ──────────────────────────────────────────────────────────────
  group('UserModel', () {
    const rawJson = {
      '_id':       'user_001',
      'full_name': 'Budi Santoso',
      'email':     'budi@nawasena.id',
      'role':      'donor',
      'avatar_url': null,
      'volunteer_profile': null,
      'managed_foundation_id': null,
      'created_at': '2025-01-15T10:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = UserModel.fromJson(rawJson);
      expect(model.id,       'user_001');
      expect(model.fullName, 'Budi Santoso');
      expect(model.email,    'budi@nawasena.id');
      expect(model.role,     'donor');
      expect(model.isDonor,  true);
      expect(model.isVolunteer, false);
      expect(model.createdAt, isNotNull);
    });

    test('fromJson handles _id and id fields interchangeably', () {
      final withUnderscore = UserModel.fromJson({'_id': 'u1', 'full_name': 'A', 'email': 'a@b.com', 'role': 'donor'});
      final withoutUnderscore = UserModel.fromJson({'id': 'u2', 'full_name': 'B', 'email': 'b@c.com', 'role': 'volunteer'});
      expect(withUnderscore.id,   'u1');
      expect(withoutUnderscore.id, 'u2');
    });

    test('VolunteerProfile parses skills and total_hours', () {
      final json = {
        '_id': 'v1', 'full_name': 'Siti', 'email': 's@n.id', 'role': 'volunteer',
        'volunteer_profile': {
          'skills': ['Mengajar', 'Medis'],
          'total_hours': 24,
        },
      };
      final model = UserModel.fromJson(json);
      expect(model.volunteerProfile?.skills,     ['Mengajar', 'Medis']);
      expect(model.volunteerProfile?.totalHours, 24);
    });

    test('copyWith preserves unchanged fields', () {
      final original = UserModel.fromJson(rawJson);
      final updated  = original.copyWith(fullName: 'Budi Update');
      expect(updated.fullName, 'Budi Update');
      expect(updated.email,    original.email);
      expect(updated.id,       original.id);
    });
  });

  // ── FoundationModel ────────────────────────────────────────────────────────
  group('FoundationModel', () {
    final rawJson = {
      '_id':          'found_001',
      'name':         'Panti Kasih Bunda',
      'description':  'Deskripsi panti.',
      'address':      'Jl. Mawar No. 1',
      'contact_phone': '021-1234567',
      'is_verified':  true,
      'location': {
        'type': 'Point',
        'coordinates': [106.8456, -6.2088],
      },
      'bank_account': {
        'bank_name':      'BCA',
        'account_number': '1234567890',
        'account_name':   'Panti Kasih Bunda',
      },
    };

    test('fromJson parses GeoLocation correctly', () {
      final model = FoundationModel.fromJson(rawJson);
      expect(model.location?.longitude, 106.8456);
      expect(model.location?.latitude,  -6.2088);
      expect(model.location?.type,      'Point');
    });

    test('fromJson parses BankAccount correctly', () {
      final model = FoundationModel.fromJson(rawJson);
      expect(model.bankAccount?.bankName,      'BCA');
      expect(model.bankAccount?.accountNumber, '1234567890');
      expect(model.bankAccount?.accountName,   'Panti Kasih Bunda');
    });

    test('isVerified flag parsed correctly', () {
      final model = FoundationModel.fromJson(rawJson);
      expect(model.isVerified, true);
    });
  });

  // ── InventoryModel ─────────────────────────────────────────────────────────
  group('InventoryModel', () {
    final rawJson = {
      '_id':          'inv_001',
      'foundation_id': 'found_001',
      'item_name':    'Beras 5 kg',
      'category':     'Logistik',
      'unit':         'karung',
      'target_qty':   50,
      'current_qty':  10,
      'urgent_level': 'high',
      'description':  'Beras kebutuhan harian.',
    };

    test('fromJson parses category and urgentLevel as enum', () {
      final model = InventoryModel.fromJson(rawJson);
      expect(model.category,   InventoryCategory.logistik);
      expect(model.urgentLevel, UrgentLevel.high);
    });

    test('fulfillmentRatio calculated correctly', () {
      final model = InventoryModel.fromJson(rawJson);
      expect(model.fulfillmentRatio, closeTo(0.2, 0.001));
    });

    test('remainingQty calculated correctly', () {
      final model = InventoryModel.fromJson(rawJson);
      expect(model.remainingQty, 40);
    });

    test('isFulfilled returns false when currentQty < targetQty', () {
      final model = InventoryModel.fromJson(rawJson);
      expect(model.isFulfilled, false);
    });

    test('isFulfilled returns true when currentQty >= targetQty', () {
      final fulfilledJson = {...rawJson, 'current_qty': 50};
      final model = InventoryModel.fromJson(fulfilledJson);
      expect(model.isFulfilled, true);
    });

    test('fulfillmentRatio clamps to 1.0 when over target', () {
      final overJson = {...rawJson, 'current_qty': 60};
      final model = InventoryModel.fromJson(overJson);
      expect(model.fulfillmentRatio, 1.0);
    });
  });

  // ── DonationModel ──────────────────────────────────────────────────────────
  group('DonationModel', () {
    final rawJson = {
      '_id':          'don_001',
      'foundation_id': 'found_001',
      'inventory_id': 'inv_001',
      'donor_id':     'user_001',
      'type':         'goods',
      'item_detail': {
        'name': 'Beras 5 kg',
        'qty':  5,
        'unit': 'karung',
      },
      'status':       'pending',
      'is_anonymous': false,
      'qr_code_hash': 'abc123hash',
      'history_logs': [
        {
          'status':    'pending',
          'timestamp': '2025-01-15T10:00:00.000Z',
          'note':      'Donation pledge created by donor',
        },
      ],
      'created_at': '2025-01-15T10:00:00.000Z',
    };

    test('fromJson parses all core fields', () {
      final model = DonationModel.fromJson(rawJson);
      expect(model.id,          'don_001');
      expect(model.status,       DonationStatus.pending);
      expect(model.isAnonymous,  false);
      expect(model.qrCodeHash,   'abc123hash');
    });

    test('fromJson parses DonationItemDetail correctly', () {
      final model = DonationModel.fromJson(rawJson);
      expect(model.itemDetail.name, 'Beras 5 kg');
      expect(model.itemDetail.qty,  5);
      expect(model.itemDetail.unit, 'karung');
    });

    test('fromJson parses historyLogs list', () {
      final model = DonationModel.fromJson(rawJson);
      expect(model.historyLogs.length,        1);
      expect(model.historyLogs.first.status,  DonationStatus.pending);
      expect(model.historyLogs.first.note,
          'Donation pledge created by donor');
    });

    test('DonationStatus extension labels are correct', () {
      expect(DonationStatus.pending.label,  'Menunggu');
      expect(DonationStatus.sent.label,     'Dikirim');
      expect(DonationStatus.received.label, 'Diterima');
      expect(DonationStatus.verified.label, 'Terverifikasi');
    });
  });

  // ── WorkshopModel ──────────────────────────────────────────────────────────
  group('WorkshopModel', () {
    final rawJson = {
      '_id':            'ws_001',
      'foundation_id':  'found_001',
      'title':          'Mengajar Bersama',
      'description':    'Kegiatan mengajar anak yatim.',
      'event_date':     DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'status':         'open',
      'mentor_needed':  10,
      'mentor_registered_count': 3,
      'registered_volunteers': [
        {
          'user_id':   'user_001',
          'user_name': 'Budi',
          'status':    'confirmed',
          'joined_at': '2025-01-10T08:00:00.000Z',
        },
      ],
      'location': {
        'type': 'Point',
        'coordinates': [106.8456, -6.2088],
      },
      'geofence_radius_meters': 100,
    };

    test('fromJson parses status as enum', () {
      final model = WorkshopModel.fromJson(rawJson);
      expect(model.status, WorkshopStatus.open);
    });

    test('remainingSlots calculated correctly', () {
      final model = WorkshopModel.fromJson(rawJson);
      expect(model.remainingSlots, 7);
    });

    test('isFull returns false when slots available', () {
      final model = WorkshopModel.fromJson(rawJson);
      expect(model.isFull, false);
    });

    test('isFull returns true when quota reached', () {
      final fullJson = {...rawJson, 'mentor_registered_count': 10};
      final model = WorkshopModel.fromJson(fullJson);
      expect(model.isFull, true);
    });

    test('isUserRegistered returns true for registered user', () {
      final model = WorkshopModel.fromJson(rawJson);
      expect(model.isUserRegistered('user_001'), true);
      expect(model.isUserRegistered('user_999'), false);
    });

    test('registeredVolunteers parsed correctly', () {
      final model = WorkshopModel.fromJson(rawJson);
      expect(model.registeredVolunteers.length, 1);
      expect(model.registeredVolunteers.first.userId,   'user_001');
      expect(model.registeredVolunteers.first.userName, 'Budi');
      expect(model.registeredVolunteers.first.status,
          VolunteerAttendanceStatus.confirmed);
    });
  });
}