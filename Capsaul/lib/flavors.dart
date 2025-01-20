import 'package:flutter/services.dart';

enum Environment {
  prod,
  dev;

  static Environment fromFlavor() {
    return Environment.values.firstWhere(
      (e) => e.name == appFlavor?.toLowerCase(),
      orElse: () {
        return Environment.dev;
      },
    );
  }
}

class F {
  static Environment env = Environment.fromFlavor();

  static String get title {
    switch (env) {
      case Environment.prod:
        return 'Capsaul';
      case Environment.dev:
        return 'Capsaul Dev';
      }
  }
}
