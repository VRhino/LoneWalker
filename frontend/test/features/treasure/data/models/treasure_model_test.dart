import 'package:flutter_test/flutter_test.dart';
import 'package:lonewalker/features/treasure/data/models/treasure_model.dart';
import 'package:lonewalker/features/treasure/domain/entities/treasure.dart';

void main() {
  group('TreasureModel', () {
    final tJson = {
      'id': 'treasure-1',
      'title': 'Hidden Gem',
      'description': 'A rare find',
      'latitude': 40.4168,
      'longitude': -3.7038,
      'status': 'ACTIVE',
      'rarity': 'RARE',
      'max_uses': 10,
      'current_uses': 3,
      'uses_remaining': 7,
      'claimed_by_user': false,
      'created_at': '2024-01-01T00:00:00.000',
      'updated_at': '2024-01-01T00:00:00.000',
    };

    group('fromJson', () {
      test('parsea todos los campos correctamente', () {
        final t = TreasureModel.fromJson(tJson);

        expect(t.id, 'treasure-1');
        expect(t.title, 'Hidden Gem');
        expect(t.latitude, 40.4168);
        expect(t.longitude, -3.7038);
        expect(t.rarity, TreasureRarity.rare);
        expect(t.status, TreasureStatus.active);
        expect(t.maxUses, 10);
        expect(t.currentUses, 3);
        expect(t.usesRemaining, 7);
        expect(t.claimedByUser, false);
      });

      test('maneja campos opcionales null', () {
        final json = {
          ...tJson,
          'max_uses': null,
          'uses_remaining': null,
          'photo_url': null,
          'stl_file_url': null,
        };
        final t = TreasureModel.fromJson(json);

        expect(t.maxUses, isNull);
        expect(t.usesRemaining, isNull);
        expect(t.photoUrl, isNull);
        expect(t.stlFileUrl, isNull);
      });

      test('usa valores por defecto cuando faltan campos opcionales', () {
        final json = {
          'id': 'x',
          'title': 't',
          'description': 'd',
          'latitude': 1.0,
          'longitude': 1.0,
          'status': 'ACTIVE',
          'rarity': 'COMMON',
          'created_at': '2024-01-01T00:00:00.000',
          'updated_at': '2024-01-01T00:00:00.000',
        };
        final t = TreasureModel.fromJson(json);

        expect(t.currentUses, 0);
        expect(t.claimedByUser, false);
      });
    });

    group('toJson', () {
      test('serializa rareza y status como strings', () {
        final t = TreasureModel.fromJson(tJson);
        final result = t.toJson();

        expect(result['rarity'], 'RARE');
        expect(result['status'], 'ACTIVE');
      });

      test('round-trip fromJson → toJson es consistente', () {
        final t = TreasureModel.fromJson(tJson);
        final deserialized = TreasureModel.fromJson(t.toJson());

        expect(deserialized.id, t.id);
        expect(deserialized.rarity, t.rarity);
        expect(deserialized.status, t.status);
        expect(deserialized.currentUses, t.currentUses);
      });
    });
  });

  group('TreasureRarityX', () {
    test('parsea todas las rarezas correctamente', () {
      expect(TreasureRarityX.fromString('COMMON'), TreasureRarity.common);
      expect(TreasureRarityX.fromString('UNCOMMON'), TreasureRarity.uncommon);
      expect(TreasureRarityX.fromString('RARE'), TreasureRarity.rare);
      expect(TreasureRarityX.fromString('EPIC'), TreasureRarity.epic);
      expect(TreasureRarityX.fromString('LEGENDARY'), TreasureRarity.legendary);
    });

    test('es insensible a mayúsculas', () {
      expect(TreasureRarityX.fromString('rare'), TreasureRarity.rare);
      expect(TreasureRarityX.fromString('Legendary'), TreasureRarity.legendary);
    });

    test('retorna COMMON para valores desconocidos', () {
      expect(TreasureRarityX.fromString('UNKNOWN'), TreasureRarity.common);
    });

    test('stringValue retorna el string correcto', () {
      expect(TreasureRarity.epic.stringValue, 'EPIC');
      expect(TreasureRarity.legendary.stringValue, 'LEGENDARY');
    });
  });

  group('TreasureStatusX', () {
    test('parsea todos los estados correctamente', () {
      expect(TreasureStatusX.fromString('ACTIVE'), TreasureStatus.active);
      expect(TreasureStatusX.fromString('DEPLETED'), TreasureStatus.depleted);
      expect(TreasureStatusX.fromString('ARCHIVED'), TreasureStatus.archived);
    });

    test('retorna ACTIVE para valores desconocidos', () {
      expect(TreasureStatusX.fromString('INVALID'), TreasureStatus.active);
    });
  });

  group('RadarTreasureModel', () {
    final radarJson = {
      'treasure_id': 'radar-1',
      'title': 'Radar Treasure',
      'latitude': 40.42,
      'longitude': -3.70,
      'rarity': 'EPIC',
      'distance_meters': 50.0,
      'bearing_degrees': 90.0,
      'proximity_percent': 80.0,
      'can_claim': true,
    };

    test('fromJson parsea correctamente', () {
      final r = RadarTreasureModel.fromJson(radarJson);

      expect(r.treasureId, 'radar-1');
      expect(r.rarity, TreasureRarity.epic);
      expect(r.distanceMeters, 50.0);
      expect(r.bearingDegrees, 90.0);
      expect(r.canClaim, true);
    });

    test('can_claim es false por defecto', () {
      final json = {...radarJson}..remove('can_claim');
      final r = RadarTreasureModel.fromJson(json);
      expect(r.canClaim, false);
    });
  });

  group('TreasureClaimsStatsModel', () {
    test('fromJson parsea byRarity correctamente', () {
      final json = {
        'total_claimed': 10,
        'total_xp': 1000,
        'by_rarity': {'COMMON': 5, 'RARE': 3, 'EPIC': 2},
      };
      final stats = TreasureClaimsStatsModel.fromJson(json);

      expect(stats.totalClaimed, 10);
      expect(stats.totalXp, 1000);
      expect(stats.byRarity[TreasureRarity.common], 5);
      expect(stats.byRarity[TreasureRarity.rare], 3);
      expect(stats.byRarity[TreasureRarity.epic], 2);
    });

    test('byRarity vacío cuando no está presente', () {
      final json = {
        'total_claimed': 0,
        'total_xp': 0,
      };
      final stats = TreasureClaimsStatsModel.fromJson(json);
      expect(stats.byRarity, isEmpty);
    });
  });
}
