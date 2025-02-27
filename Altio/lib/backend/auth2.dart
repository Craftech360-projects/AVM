
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

//   // Check if identity token is null
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

//   // Firestore document handling
//   final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
//   final docSnapshot = await userDoc.get();

//   if (!docSnapshot.exists) {
//     // Create new document with fallback username
//     String username = ('${SharedPreferencesUtil().givenName} ${SharedPreferencesUtil().familyName}').trim();
//     if (username.isEmpty) {
//       username = user.displayName ?? user.email?.split('@').first ?? 'User';
//     }

//     await userDoc.set({
//       'user_id': user.uid,
//       'username': username,
//       'hasDevice': false, // default value
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   } else {
//     // Update existing document if needed
//     final data = docSnapshot.data() as Map<String, dynamic>?;
//     if (data == null || !data.containsKey('hasDevice')) {
//       await userDoc.update({'hasDevice': false});
//     }
//   }

//   return userCredential;
// }

// // Helper function to generate a nonce
// String generateNonce([int length = 32]) {
//   const charset =
//       '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
//   final random = Random.secure();
//   return List.generate(length, (_) => charset[random.nextInt(charset.length)])
//       .join();
// }

// // Helper function to hash the nonce
// String sha256ofString(String input) {
//   final bytes = utf8.encode(input);
//   final digest = sha256.convert(bytes);
//   return digest.toString();
// }

// // SharedPreferences utility class (mock implementation)
// class SharedPreferencesUtil {
//   static final SharedPreferencesUtil _instance = SharedPreferencesUtil._internal();
//   factory SharedPreferencesUtil() => _instance;
//   SharedPreferencesUtil._internal();

//   String _email = '';
//   String _givenName = '';
//   String _familyName = '';

//   String get email => _email;
//   set email(String value) => _email = value;

//   String get givenName => _givenName;
//   set givenName(String value) => _givenName = value;

//   String get familyName => _familyName;
//   set familyName(String value) => _familyName = value;
// }