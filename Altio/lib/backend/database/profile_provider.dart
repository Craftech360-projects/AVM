// 4. Create profile_provider.dart
import 'dart:async';

import 'package:altio/backend/database/profile_entity.dart';
import 'package:altio/backend/database/profile_repository.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();
  Profile _profile = Profile();
  StreamSubscription<Profile>? _profileSubscription;

  Profile get profile => _profile;

  ProfileProvider() {
    _loadProfile();
    _profileSubscription = _repo.watchProfile().listen((updatedProfile) {
      _profile = updatedProfile;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _loadProfile() {
    _profile = _repo.profile;
    notifyListeners();
  }

  Future<void> resetProfile() async {
    await _repo.updateProfile((p) => p
      ..mergeInsights({
        'core': '',
        'lifestyle': '',
        'hobbies': [],
        'interests': [],
        'habits': [],
        'work': '',
        'skills': [],
        'learnings': '',
        'others': '',
      }));
  }
}
