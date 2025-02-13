flutter clean; dart run build_runner build; echo "1"
flutter pub get
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
flutter build apk --release --flavor prod -t lib/main_prod.dart



//IOS APK
flutter build ipa --flavor prod --release

//ANDROID APK
flutter build apk --flavor prod --release

//ANDROID APP BUNDLE
flutter build appbundle --flavor prod --release

For a universal APK (single APK for all architectures):
flutter build apk --flavor prod --release --target-platform android-arm,android-arm64,android-x64

For an APK optimized for specific architectures:
flutter build apk --flavor prod --release --split-per-abi