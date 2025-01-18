import 'dart:convert';
import 'dart:math';

import 'package:capsaul/backend/preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Generates a cryptographically secure random nonce, to be included in a
/// credential request.
String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<UserCredential> signInWithApple() async {
  // Generate nonce for preventing replay attacks
  final rawNonce = generateNonce();
  final nonce = sha256ofString(rawNonce);

  // Request credential for the currently signed-in Apple account
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: nonce,
  );
  // If Apple provides email and name (only during the first sign-in), store them
  if (appleCredential.email != null) {
    SharedPreferencesUtil().email = appleCredential.email!;
  } else {}

  if (appleCredential.givenName != null) {
    SharedPreferencesUtil().givenName = appleCredential.givenName!;
    SharedPreferencesUtil().familyName = appleCredential.familyName ?? '';
  } else {}
  if (appleCredential.identityToken == null) {
    throw Exception('Identity token is null');
  }

  // Create an OAuthCredential for Firebase Authentication
  // Debugging the idToken and rawNonce

// Create the OAuth credential for Firebase
  final oauthCredential = OAuthProvider("apple.com").credential(
    idToken: appleCredential.identityToken, // ID token must not be null
    accessToken: appleCredential.authorizationCode,
    rawNonce: rawNonce, // Ensure rawNonce is passed, not the hashed one
  );

// Debug the OAuthCredential to see what's being passed

  // Sign in with Firebase
  UserCredential userCred =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  var user = FirebaseAuth.instance.currentUser!;
  // If givenName is null (likely a second or subsequent sign-in), retrieve name from Firebase
  if (SharedPreferencesUtil().givenName.isEmpty) {
    if (user.displayName != null) {
      var nameParts = user.displayName!.split(' ');
      SharedPreferencesUtil().givenName =
          nameParts.isNotEmpty ? nameParts[0] : '';
      SharedPreferencesUtil().familyName =
          nameParts.length > 1 ? nameParts.last : '';
    }
  }

  // If email is not stored locally, retrieve it from Firebase user object
  if (SharedPreferencesUtil().email.isEmpty) {
    SharedPreferencesUtil().email = user.email ?? '';
  }

  if (appleCredential.givenName != null) {
    await user.updateProfile(
        displayName:
            '${SharedPreferencesUtil().givenName} ${SharedPreferencesUtil().familyName}');
    await user.reload();
  }

  return userCred;
}

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
  // Create a new credential
  // store email + name, need to?
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  var result = await FirebaseAuth.instance.signInWithCredential(credential);
  var givenName = result.additionalUserInfo?.profile?['given_name'] ?? '';
  var familyName = result.additionalUserInfo?.profile?['family_name'] ?? '';
  var email = result.additionalUserInfo?.profile?['email'] ?? '';
  if (email != null) SharedPreferencesUtil().email = email;
  if (givenName != null) {
    SharedPreferencesUtil().givenName = givenName;
    SharedPreferencesUtil().familyName = familyName;
  }
  return result;
}

Future<UserCredential> signInWithGoogle2() async {
  // Trigger the Google Sign-In flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) {
    // The user canceled the sign-in
    return Future.error('Sign-in canceled');
  }

  // Obtain the auth details from the Google sign-in
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a credential using the tokens
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Sign in to Firebase with the Google credential
  UserCredential result =
      await FirebaseAuth.instance.signInWithCredential(credential);

  // Retrieve user profile details from additionalUserInfo or FirebaseAuth user
  var givenName = result.additionalUserInfo?.profile?['given_name'] ?? '';
  var familyName = result.additionalUserInfo?.profile?['family_name'] ?? '';
  var email = result.additionalUserInfo?.profile?['email'] ?? '';

  // If email is not available in additionalUserInfo, fallback to FirebaseAuth user
  var firebaseUser = FirebaseAuth.instance.currentUser;
  if (email.isEmpty && firebaseUser != null) {
    email = firebaseUser.email ?? '';
  }

  // Save email and name into SharedPreferences for future use
  if (email.isNotEmpty) SharedPreferencesUtil().email = email;
  if (givenName.isNotEmpty) {
    SharedPreferencesUtil().givenName = givenName;
    SharedPreferencesUtil().familyName = familyName;
  } else if (firebaseUser != null && firebaseUser.displayName != null) {
    // If names are missing, retrieve from Firebase user displayName
    var nameParts = firebaseUser.displayName?.split(' ') ?? [];
    SharedPreferencesUtil().givenName =
        nameParts.isNotEmpty ? nameParts[0] : '';
    SharedPreferencesUtil().familyName =
        nameParts.length > 1 ? nameParts.last : '';
  }

  return result;
}

listenAuthTokenChanges() {
  FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
    SharedPreferencesUtil().authToken = '123:/';
  });
}

Future<String?> getIdToken() async {
  IdTokenResult? newToken =
      await FirebaseAuth.instance.currentUser?.getIdTokenResult(true);
  if (newToken?.token != null) {
    SharedPreferencesUtil().uid = FirebaseAuth.instance.currentUser!.uid;
  }
  return newToken?.token;
}

// Future<void> signOut(BuildContext context) async {
//   await FirebaseAuth.instance.signOut();
//   try {
//     await GoogleSignIn().signOut();
//   } catch (e) {
//     debugPrint(e.toString());
//   }
//   // context.pushReplacementNamed('auth');
// }

listenAuthStateChanges() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      SharedPreferencesUtil().onboardingCompleted = false;
    } else {}
  });
}

Future isSignedIn() async {
  return FirebaseAuth.instance.currentUser != null;
}

getFirebaseUser() {
  return FirebaseAuth.instance.currentUser;
}

Future<void> updateGivenName(String fullName) async {
  var user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.updateProfile(displayName: fullName);
  }
}
