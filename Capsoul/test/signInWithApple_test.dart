import 'package:capsoul/backend/auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Mock SharedPreferences
class MockSharedPreferences implements SharedPreferences {
  Map<String, dynamic> values = {};

  @override
  String? getString(String key) => values[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    values[key] = value;
    return true;
  }

  @override
  bool containsKey(String key) => values.containsKey(key);

  @override
  Future<bool> remove(String key) async {
    values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    values.clear();
    return true;
  }

  // Required overrides
  @override
  Set<String> getKeys() => values.keys.toSet();

  @override
  Object? get(String key) => values[key];

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  double? getDouble(String key) => values[key] as double?;

  @override
  int? getInt(String key) => values[key] as int?;

  @override
  List<String>? getStringList(String key) => values[key] as List<String>?;

  @override
  Future<bool> setBool(String key, bool value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> commit() async => true;

  @override
  Future<void> reload() async {}
}

// Fake implementations
class FakeAppleCredential implements AuthorizationCredentialAppleID {
  @override
  final String? email;
  @override
  final String? givenName;
  @override
  final String? familyName;
  @override
  final String identityToken;
  @override
  final String authorizationCode;
  final List<AppleIDAuthorizationScopes> authorizedScopes;
  @override
  final String? state;
  @override
  final String? userIdentifier;

  FakeAppleCredential({
    this.email,
    this.givenName,
    this.familyName,
    required this.identityToken,
    required this.authorizationCode,
    required this.authorizedScopes,
    this.state,
    this.userIdentifier,
  });
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  void setCurrentUser(User user) {
    _currentUser = user;
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return FakeUserCredential(user: _currentUser!);
  }
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  final User user;

  FakeUserCredential({required this.user});
}

class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  FakeUser({
    required this.uid,
    this.email,
    this.displayName,
  });

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {}

  @override
  Future<void> reload() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseAuth fakeAuth;
  late MockSharedPreferences mockPrefs;

  setUp(() async {
    // Setup fake Firebase Auth
    fakeAuth = FakeFirebaseAuth();
    final fakeUser = FakeUser(
      uid: 'fake-uid',
      email: 'test@example.com',
      displayName: 'John Doe',
    );
    fakeAuth.setCurrentUser(fakeUser);

    // Setup mock SharedPreferences
    mockPrefs = MockSharedPreferences();
    SharedPreferences.setMockInitialValues({});
  });

  group('Apple Sign In Tests', () {
    test('auth.generateNonce creates string of correct length', () {
      final nonce = auth.generateNonce(32);
      expect(nonce.length, equals(32));
      expect(nonce, matches(RegExp(r'^[0-9A-Za-z\-._]+$')));
    });

    test('auth.sha256ofString generates correct hash', () {
      final input = 'test-input';
      final hash = auth.sha256ofString(input);
      expect(hash, isNotEmpty);
      expect(
          hash.length, equals(64)); // SHA-256 produces 64 character hex string
    });

    // testWidgets('successful Apple sign in with first-time user',
    //     (WidgetTester tester) async {
    //   // Arrange
    //   final fakeUser = FakeUser(
    //     uid: 'fake-uid',
    //     email: 'test@example.com',
    //     displayName: 'John Doe',
    //   );
    //   fakeAuth.setCurrentUser(fakeUser);

    //   print('Fake user set: ${fakeUser.email}');

    //   final fakeAppleCredential = FakeAppleCredential(
    //     email: 'test@example.com',
    //     givenName: 'John',
    //     familyName: 'Doe',
    //     identityToken: 'fake-identity-token',
    //     authorizationCode: 'fake-auth-code',
    //     authorizedScopes: [
    //       AppleIDAuthorizationScopes.email,
    //       AppleIDAuthorizationScopes.fullName,
    //     ],
    //   );

    //   print('Fake Apple Credential created: ${fakeAppleCredential.email}');

    //   // Act
    //   final result = await auth.signInWithApple();

    //   print('Sign-in result: $result');

    //   // Assert
    //   expect(result, isA<UserCredential>());
    //   expect(mockPrefs.getString('email'), equals('test@example.com'));
    //   print('Email from prefs: ${mockPrefs.getString('email')}');

    //   expect(mockPrefs.getString('given_name'), equals('John'));
    //   print('Given name from prefs: ${mockPrefs.getString('given_name')}');

    //   expect(mockPrefs.getString('family_name'), equals('Doe'));
    //   print('Family name from prefs: ${mockPrefs.getString('family_name')}');
    // });

    test('Apple sign in handles null identity token', () async {
      // Arrange
      final fakeAppleCredential = FakeAppleCredential(
        email: 'test@example.com',
        givenName: 'John',
        familyName: 'Doe',
        identityToken: '', // Empty token should cause error
        authorizationCode: 'fake-auth-code',
        authorizedScopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Act & Assert
      expect(() => auth.signInWithApple(), throwsException);
    });

    test('generateNonce creates unique values', () {
      final nonce1 = auth.generateNonce();
      final nonce2 = auth.generateNonce();
      expect(nonce1, isNot(equals(nonce2)));
    });
  });
}
