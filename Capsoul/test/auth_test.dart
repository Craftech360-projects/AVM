import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

void main() {
  late MockGoogleSignIn googleSignIn;
  late MockFirebaseAuth firebaseAuth;

  setUp(() {
    googleSignIn = MockGoogleSignIn();
    firebaseAuth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'test-user-id',
        email: 'testuser@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
      ),
    );
  });

  test('should successfully sign in and retrieve user details', () async {
    // Mock Google Sign-In
    final googleUser = await googleSignIn.signIn();
    expect(googleUser, isNotNull,
        reason: 'Google Sign-In should return a user.');

    // Mock Google Authentication
    final googleAuth = await googleUser!.authentication;
    expect(googleAuth.accessToken, isNotNull,
        reason: 'Access token should not be null.');
    expect(googleAuth.idToken, isNotNull,
        reason: 'ID token should not be null.');

    // Create Google Auth Credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Mock Firebase Auth Sign-In
    final userCredential = await firebaseAuth.signInWithCredential(credential);
    expect(userCredential, isNotNull,
        reason: 'Firebase userCredential should not be null.');

    // Validate User Details
    expect(userCredential.user?.email, 'testuser@example.com');
    expect(userCredential.user?.displayName, 'Test User');
  });

  test('should return null when Google login is cancelled by the user',
      () async {
    googleSignIn.setIsCancelled(true);
    final googleUser = await googleSignIn.signIn();
    expect(googleUser, isNull);
  });

  test('should handle multiple login attempts correctly', () async {
    // First attempt: cancelled
    googleSignIn.setIsCancelled(true);
    final firstAttempt = await googleSignIn.signIn();
    expect(firstAttempt, isNull);

    // Second attempt: successful
    googleSignIn.setIsCancelled(false);
    final secondAttempt = await googleSignIn.signIn();
    expect(secondAttempt, isNotNull);
  });
}
