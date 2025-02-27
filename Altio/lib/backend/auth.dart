import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:altio/backend/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

// Future<UserCredential> signInWithApple() async {
//   // Generate nonce for preventing replay attacks
//   final rawNonce = generateNonce();
//   final nonce = sha256ofString(rawNonce);

//   // Request Apple ID credential
//   final appleCredential = await SignInWithApple.getAppleIDCredential(
//     scopes: [
//       AppleIDAuthorizationScopes.email,
//       AppleIDAuthorizationScopes.fullName,
//     ],
//     nonce: nonce,
//   );

//   // Store email and name from the credential if available (first sign-in)
//   if (appleCredential.email != null) {
//     SharedPreferencesUtil().email = appleCredential.email!;
//   }
//   if (appleCredential.givenName != null) {
//     SharedPreferencesUtil().givenName = appleCredential.givenName!;
//     SharedPreferencesUtil().familyName = appleCredential.familyName ?? '';
//   }

//   if (appleCredential.identityToken == null) {
//     throw Exception('Identity token is null');
//   }

//   // Create OAuth credential for Firebase Authentication
//   final oauthCredential = OAuthProvider("apple.com").credential(
//     idToken: appleCredential.identityToken, // must not be null
//     accessToken: appleCredential.authorizationCode,
//     rawNonce: rawNonce, // pass the raw nonce
//   );

//   // Sign in with Firebase
//   UserCredential userCred =
//       await FirebaseAuth.instance.signInWithCredential(oauthCredential);
//   final user = FirebaseAuth.instance.currentUser!;

//   // If givenName is missing (likely on subsequent sign-ins), derive it from displayName if available.
//   if (SharedPreferencesUtil().givenName.isEmpty) {
//     if (user.displayName != null) {
//       final nameParts = user.displayName!.split(' ');
//       SharedPreferencesUtil().givenName =
//           nameParts.isNotEmpty ? nameParts[0] : '';
//       SharedPreferencesUtil().familyName =
//           nameParts.length > 1 ? nameParts.last : '';
//     }
//   }

//   // Ensure email is stored locally.
//   if (SharedPreferencesUtil().email.isEmpty) {
//     SharedPreferencesUtil().email = user.email ?? '';
//   }

//   // On the first sign-in, update the user profile with the retrieved names.
//   if (appleCredential.givenName != null) {
//     await user.updateProfile(
//       displayName:
//           '${SharedPreferencesUtil().givenName} ${SharedPreferencesUtil().familyName}',
//     );
//     await user.reload();
//   }

//   // Check if the user is new and create a Firestore document accordingly.
//   final additionalInfo = userCred.additionalUserInfo;
//   final isNewUser = additionalInfo?.isNewUser ?? false;
//   if (isNewUser) {
//     // Construct a username from the given and family name.
//     final username =
//         ('${SharedPreferencesUtil().givenName} ${SharedPreferencesUtil().familyName}')
//             .trim();
//     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//       'user_id': user.uid,
//       'username': username,
//       'hasDevice': false, // default value
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   return userCred;
// }

Future<UserCredential> signInWithApple() async {
  try {
    dev.log('🍎 Starting Apple Sign In process...');

    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    dev.log('🔐 Generated nonce for security');

    dev.log('📱 Requesting Apple ID credential...');
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    dev.log('✅ Received Apple credential');

    if (appleCredential.email != null) {
      dev.log('📧 Storing email: ${appleCredential.email}');
      SharedPreferencesUtil().email = appleCredential.email!;
    }

    if (appleCredential.givenName != null) {
      dev.log(
          '👤 Storing name: ${appleCredential.givenName} ${appleCredential.familyName}');
      SharedPreferencesUtil().givenName = appleCredential.givenName!;
      SharedPreferencesUtil().familyName = appleCredential.familyName ?? '';
    }

    if (appleCredential.identityToken == null) {
      dev.log('❌ Error: Identity token is null');
      throw Exception('Identity token is null');
    }

    dev.log('🔑 Creating Firebase OAuth credential...');
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );

    dev.log('🔥 Signing in with Firebase...');
    UserCredential userCred =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    final user = FirebaseAuth.instance.currentUser!;
    dev.log('✅ Firebase sign in successful. UID: ${user.uid}');

    if (SharedPreferencesUtil().givenName.isEmpty) {
      dev.log('🔍 Attempting to derive name from display name...');
      if (user.displayName != null) {
        final nameParts = user.displayName!.split(' ');
        SharedPreferencesUtil().givenName =
            nameParts.isNotEmpty ? nameParts[0] : '';
        SharedPreferencesUtil().familyName =
            nameParts.length > 1 ? nameParts.last : '';
        dev.log(
            '📝 Derived name: ${SharedPreferencesUtil().givenName} ${SharedPreferencesUtil().familyName}');
      }
    }

    if (SharedPreferencesUtil().email.isEmpty) {
      dev.log('📧 Storing Firebase email: ${user.email}');
      SharedPreferencesUtil().email = user.email ?? '';
    }

    if (appleCredential.givenName != null) {
      dev.log('🔄 Updating Firebase profile...');
      await user.updateProfile(
        displayName:
            '${SharedPreferencesUtil().givenName} ${SharedPreferencesUtil().familyName}',
      );
      await user.reload();
    }

    dev.log('📚 Handling Firestore document...');
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      dev.log('📝 Creating new Firestore document...');
      String username =
          ('${SharedPreferencesUtil().givenName} ${SharedPreferencesUtil().familyName}')
              .trim();
      if (username.isEmpty) {
        username = user.displayName ?? user.email?.split('@').first ?? 'User';
      }
      dev.log('👤 Using username: $username');

      await userDoc.set({
        'user_id': user.uid,
        'username': username,
        'hasDevice': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      dev.log('✏️ Checking existing document...');
      final data = docSnapshot.data();
      if (data == null || !data.containsKey('hasDevice')) {
        dev.log('🔄 Updating hasDevice field...');
        await userDoc.update({'hasDevice': false});
      }
    }

    dev.log('✅ Apple Sign In process completed successfully');
    return userCred;
  } catch (e) {
    dev.log('❌ Error during Apple Sign In: $e');
    rethrow;
  }
}

// Future<UserCredential> signInWithGoogle() async {
//   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//   final GoogleSignInAuthentication? googleAuth =
//       await googleUser?.authentication;
//   final credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth?.accessToken,
//     idToken: googleAuth?.idToken,
//   );

//   // Sign in with Firebase
//   UserCredential result =
//       await FirebaseAuth.instance.signInWithCredential(credential);

//   // Get user details from the result
//   final user = result.user!;
//   final additionalInfo = result.additionalUserInfo;
//   final isNewUser = additionalInfo?.isNewUser ?? false;

//   // Optional: Retrieve profile details from the sign in
//   final givenName = additionalInfo?.profile?['given_name'] ?? '';
//   final familyName = additionalInfo?.profile?['family_name'] ?? '';
//   // You can decide how to construct the username; here we simply concatenate them.
//   final username = '$givenName $familyName'.trim();

//   // Store user info in SharedPreferences if needed
//   if (additionalInfo?.profile?['email'] != null) {
//     SharedPreferencesUtil().email = additionalInfo?.profile?['email'];
//   }
//   SharedPreferencesUtil().givenName = givenName;
//   SharedPreferencesUtil().familyName = familyName;

//   // For a new user, create a Firestore document with default values
//   if (isNewUser) {
//     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//       'user_id': user.uid,
//       'username': username,
//       'hasDevice': false,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   return result;
// }
Future<UserCredential> signInWithGoogle() async {
  // Sign in with Google
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create Firebase credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Sign in with Firebase
  UserCredential result =
      await FirebaseAuth.instance.signInWithCredential(credential);

  // Get user details from the result
  final user = result.user!;
  final additionalInfo = result.additionalUserInfo;

  // Retrieve profile details from the sign-in
  final givenName = additionalInfo?.profile?['given_name'] ?? '';
  final familyName = additionalInfo?.profile?['family_name'] ?? '';
  final email = additionalInfo?.profile?['email'] ?? '';

  // Construct username
  final username = '$givenName $familyName'.trim();

  // Store user info in SharedPreferences if needed
  if (email.isNotEmpty) {
    SharedPreferencesUtil().email = email;
  }
  SharedPreferencesUtil().givenName = givenName;
  SharedPreferencesUtil().familyName = familyName;

  // Firestore document handling
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final docSnapshot = await userDoc.get();

  if (!docSnapshot.exists) {
    // Create new document with fallback username
    String fallbackUsername = username;
    if (fallbackUsername.isEmpty) {
      fallbackUsername =
          user.displayName ?? user.email?.split('@').first ?? 'User';
    }

    await userDoc.set({
      'user_id': user.uid,
      'username': fallbackUsername,
      'hasDevice': false, // default value
      'createdAt': FieldValue.serverTimestamp(),
    });
  } else {
    // Update existing document if needed
    final data = docSnapshot.data();
    if (data == null || !data.containsKey('hasDevice')) {
      await userDoc.update({'hasDevice': false});
    }
  }

  return result;
}

void listenAuthTokenChanges() {
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

void listenAuthStateChanges() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      SharedPreferencesUtil().onboardingCompleted = false;
    } else {}
  });
}

Future isSignedIn() async {
  return FirebaseAuth.instance.currentUser != null;
}

User? getFirebaseUser() {
  return FirebaseAuth.instance.currentUser;
}

Future<void> updateGivenName(String fullName) async {
  var user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.updateProfile(displayName: fullName);
  }
}
