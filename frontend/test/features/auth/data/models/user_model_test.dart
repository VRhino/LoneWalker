import 'package:flutter_test/flutter_test.dart';
import 'package:lonewalker/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final tJson = {
      'id': 'user-1',
      'username': 'testuser',
      'email': 'test@test.com',
      'privacy_mode': 'PUBLIC',
      'exploration_percent': 5.5,
      'total_xp': 100,
      'medals_count': 2,
      'created_at': '2024-01-01T00:00:00.000',
      'updated_at': '2024-01-01T00:00:00.000',
    };

    group('fromJson', () {
      test('parsea todos los campos correctamente', () {
        final user = UserModel.fromJson(tJson);

        expect(user.id, 'user-1');
        expect(user.username, 'testuser');
        expect(user.email, 'test@test.com');
        expect(user.privacyMode, 'PUBLIC');
        expect(user.explorationPercent, 5.5);
        expect(user.totalXp, 100);
        expect(user.medalsCount, 2);
        expect(user.avatarUrl, isNull);
      });

      test('parsea avatar_url cuando está presente', () {
        final json = {
          ...tJson,
          'avatar_url': 'https://example.com/avatar.png',
        };
        final user = UserModel.fromJson(json);
        expect(user.avatarUrl, 'https://example.com/avatar.png');
      });

      test('usa valores por defecto cuando faltan campos opcionales', () {
        final json = {
          'id': 'user-1',
          'username': 'test',
          'email': 'test@test.com',
          'created_at': '2024-01-01T00:00:00.000',
          'updated_at': '2024-01-01T00:00:00.000',
        };
        final user = UserModel.fromJson(json);

        expect(user.explorationPercent, 0.0);
        expect(user.totalXp, 0);
        expect(user.medalsCount, 0);
        expect(user.privacyMode, 'PUBLIC');
      });

      test('parsea fechas correctamente', () {
        final user = UserModel.fromJson(tJson);
        expect(user.createdAt, DateTime.parse('2024-01-01T00:00:00.000'));
        expect(user.updatedAt, DateTime.parse('2024-01-01T00:00:00.000'));
      });
    });

    group('toJson', () {
      test('serializa todos los campos correctamente', () {
        final user = UserModel.fromJson(tJson);
        final result = user.toJson();

        expect(result['id'], 'user-1');
        expect(result['username'], 'testuser');
        expect(result['email'], 'test@test.com');
        expect(result['privacy_mode'], 'PUBLIC');
        expect(result['exploration_percent'], 5.5);
        expect(result['total_xp'], 100);
        expect(result['medals_count'], 2);
      });

      test('round-trip fromJson → toJson es consistente', () {
        final user = UserModel.fromJson(tJson);
        final serialized = user.toJson();
        final deserialized = UserModel.fromJson(serialized);

        expect(deserialized.id, user.id);
        expect(deserialized.username, user.username);
        expect(deserialized.email, user.email);
        expect(deserialized.explorationPercent, user.explorationPercent);
        expect(deserialized.totalXp, user.totalXp);
      });
    });
  });
}
