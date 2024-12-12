import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/preferences.dart';
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

// Future<UserCredential> signInWithApple() async {
//   // To prevent replay attacks with the credential returned from Apple, we
//   // include a nonce in the credential request. When signing in with
//   // Firebase, the nonce in the id token returned by Apple, is expected to
//   // match the sha256 hash of `rawNonce`.
//   final rawNonce = generateNonce();
//   final nonce = sha256ofString(rawNonce);
//   // Request credential for the currently signed in Apple account.
//   final appleCredential = await SignInWithApple.getAppleIDCredential(
//     scopes: [
//       AppleIDAuthorizationScopes.email,
//       AppleIDAuthorizationScopes.fullName
//     ],
//     nonce: nonce,
//   );
//   print(appleCredential);
//   // will be null if it's not first signIn
//   if (appleCredential.email != null) {
//     SharedPreferencesUtil().email = appleCredential.email!;
//   } else {
//     print("its null1");
//   }
//   if (appleCredential.givenName != null) {
//     SharedPreferencesUtil().givenName = appleCredential.givenName!;
//     SharedPreferencesUtil().familyName = appleCredential.familyName ?? '';
//   } else {
//     print("its null2");
//   }
//   // this would not be set again if the user uninstalls and installs the app again :/ as name and email are only given once.

//   // Create an `OAuthCredential` from the credential returned by Apple.
//   final oauthCredential = OAuthProvider("apple.com").credential(
//     idToken: appleCredential.identityToken,
//     rawNonce: rawNonce,
//   );

//   // Sign in the user with Firebase. If the nonce we generated earlier does
//   // not match the nonce in `appleCredential.identityToken`, sign in will fail.
//   UserCredential userCred =
//       await FirebaseAuth.instance.signInWithCredential(oauthCredential);
//   print("userCred, $userCred");
//   var user = FirebaseAuth.instance.currentUser!;
//   if (appleCredential.givenName != null) {
//     user.updateProfile(displayName: SharedPreferencesUtil().fullName);
//   } else {
//     var nameParts = user.displayName?.split(' ');
//     SharedPreferencesUtil().givenName = nameParts?[0] ?? '';
//     SharedPreferencesUtil().familyName = nameParts?[nameParts.length - 1] ?? '';
//   }
//   if (SharedPreferencesUtil().email.isEmpty) {
//     SharedPreferencesUtil().email = user.email ?? '';
//   }

//   debugPrint('signInWithApple Name: ${SharedPreferencesUtil().fullName}');
//   debugPrint('signInWithApple Email: ${SharedPreferencesUtil().email}');
//   return userCred;
// }

// Future<UserCredential> signInWithApple() async {
//   // Generate nonce for preventing replay attacks
//   final rawNonce = generateNonce();
//   final nonce = sha256ofString(rawNonce);

//   // Request credential for the currently signed in Apple account
//   final appleCredential = await SignInWithApple.getAppleIDCredential(
//     scopes: [
//       AppleIDAuthorizationScopes.email,
//       AppleIDAuthorizationScopes.fullName,
//     ],
//     nonce: nonce,
//   );

//   // Only set the email and name if it's the first time (they will be null otherwise)
//   if (appleCredential.email != null) {
//     SharedPreferencesUtil().email = appleCredential.email!;
//   } else {
//     print("Email is null on this sign-in.");
//   }

//   if (appleCredential.givenName != null) {
//     SharedPreferencesUtil().givenName = appleCredential.givenName!;
//     SharedPreferencesUtil().familyName = appleCredential.familyName ?? '';
//   } else {
//     print("Name is null on this sign-in.");
//   }

//   // Create an OAuthCredential for Firebase Authentication
//   final oauthCredential = OAuthProvider("apple.com").credential(
//     idToken: appleCredential.identityToken,
//     rawNonce: rawNonce,
//   );

//   // Sign in with Firebase
//   UserCredential userCred =
//       await FirebaseAuth.instance.signInWithCredential(oauthCredential);
//   var user = FirebaseAuth.instance.currentUser!;

//   // If givenName is null, retrieve the name from the user's displayName
//   if (appleCredential.givenName == null) {
//     var nameParts = user.displayName?.split(' ');
//     SharedPreferencesUtil().givenName = nameParts?[0] ?? '';
//     SharedPreferencesUtil().familyName =
//         nameParts?.length == 2 ? nameParts?.last ?? '' : '';
//   }

//   // If email is null, set it from the Firebase user object
//   if (SharedPreferencesUtil().email.isEmpty) {
//     SharedPreferencesUtil().email = user.email ?? '';
//   }

//   debugPrint('signInWithApple Name: ${SharedPreferencesUtil().fullName}');
//   debugPrint('signInWithApple Email: ${SharedPreferencesUtil().email}');

//   return userCred;
// }

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
  print(appleCredential.toString());
  // If Apple provides email and name (only during the first sign-in), store them
  if (appleCredential.email != null) {
    SharedPreferencesUtil().email = appleCredential.email!;
  } else {
    print("Email is null on this sign-in.");
  }

  if (appleCredential.givenName != null) {
    SharedPreferencesUtil().givenName = appleCredential.givenName!;
    SharedPreferencesUtil().familyName = appleCredential.familyName ?? '';
    print(appleCredential.givenName);
    print(appleCredential.familyName);
  } else {
    print("Name is null on this sign-in.");
  }
  print('OAuthCredential ID Token: ${appleCredential.identityToken}');
  if (appleCredential.identityToken == null) {
    throw Exception('Identity token is null');
  }

  // Create an OAuthCredential for Firebase Authentication
  // Debugging the idToken and rawNonce
  print('Apple ID Token: ${appleCredential.identityToken}');
  print('Raw Nonce: $rawNonce');
  print('SHA-256 Nonce: $nonce');

// Create the OAuth credential for Firebase
  final oauthCredential = OAuthProvider("apple.com").credential(
    idToken: appleCredential.identityToken, // ID token must not be null
    accessToken: appleCredential.authorizationCode,
    rawNonce: rawNonce, // Ensure rawNonce is passed, not the hashed one
  );

// Debug the OAuthCredential to see what's being passed
  print("OAuth Credential: ${oauthCredential.toString()}");

  // Sign in with Firebase
  UserCredential userCred =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  print(userCred.toString());
  var user = FirebaseAuth.instance.currentUser!;
  print(user);
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

  // Optionally, update the Firebase profile if name needs to be set
  if (appleCredential.givenName != null) {
    await user.updateProfile(
        displayName:
            '${SharedPreferencesUtil().givenName} ${SharedPreferencesUtil().familyName}');
    await user.reload(); // Refresh user profile data
  }

  // Debugging output to check the saved information
  debugPrint(
      'signInWithApple Name: ${SharedPreferencesUtil().givenName} ${SharedPreferencesUtil().familyName}');
  debugPrint('signInWithApple Email: ${SharedPreferencesUtil().email}');

  return userCred;
}

Future<UserCredential> signInWithGoogle() async {
  print('Signing in with Google');
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  print('Google User: $googleUser');
  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
  print('Google Auth: $googleAuth');

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
  // test subsequent signIn
  debugPrint('signInWithGoogle Email: ${SharedPreferencesUtil().email}');
  debugPrint('signInWithGoogle Name: ${SharedPreferencesUtil().givenName}');
  return result;
}

Future<UserCredential> signInWithGoogle2() async {
  print('Signing in with Google...>.>>');

  // Trigger the Google Sign-In flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) {
    // The user canceled the sign-in
    print('Google sign-in was canceled.');
    return Future.error('Sign-in canceled');
  }
  print('Google User: $googleUser');

  // Obtain the auth details from the Google sign-in
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  print('Google Auth: $googleAuth');

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

  // Debugging output
  debugPrint('signInWithGoogle Email: ${SharedPreferencesUtil().email}');
  debugPrint('signInWithGoogle Name: ${SharedPreferencesUtil().givenName}');

  return result;
}

listenAuthTokenChanges() {
  FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
    SharedPreferencesUtil().authToken = '123:/';

    // try {
    //   var token = await getIdToken();
    //   SharedPreferencesUtil().authToken = token ?? '';
    // } catch (e) {
    //   debugPrint('Error getting token: $e');
    // }
  });
}

Future<String?> getIdToken() async {
  IdTokenResult? newToken =
      await FirebaseAuth.instance.currentUser?.getIdTokenResult(true);
  if (newToken?.token != null)
    SharedPreferencesUtil().uid = FirebaseAuth.instance.currentUser!.uid;
  return newToken?.token;
}

Future<void> signOut(BuildContext context) async {
  print(">>>sign out");
  await FirebaseAuth.instance.signOut();
  try {
    await GoogleSignIn().signOut();
  } catch (e) {
    debugPrint(e.toString());
  }
  // context.pushReplacementNamed('auth');
}

listenAuthStateChanges() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      debugPrint('User is currently signed out!');
      SharedPreferencesUtil().onboardingCompleted = false;
    } else {
      debugPrint('User is signed in!');
    }
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
