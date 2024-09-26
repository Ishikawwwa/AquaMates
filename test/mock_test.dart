import 'package:aqua_mates/services/database_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DatabaseService databaseService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    databaseService = DatabaseService(fakeFirestore);
  });

  test('getUserByEmail returns user document when user exists', () async {
    String testEmail = 'grisha@example.com';
    await fakeFirestore.collection('users').add({
      'email': testEmail,
      'nickname': 'Grisha',
    });

    final result = await databaseService.getUserByEmail(testEmail);

    expect(result?.get('email'), testEmail);
  });

  test('getUserByEmail returns null when user does not exist', () async {
    String testEmail = 'nonexistent@example.com';

    final result = await databaseService.getUserByEmail(testEmail);

    expect(result, isNull);
  });
}
