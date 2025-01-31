// 4. Create profile_provider.dart
import 'package:capsaul/backend/database/profile_entity.dart';
import 'package:capsaul/backend/database/profile_repository.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();
  Profile _profile = Profile();

  Profile get profile => _profile;

  ProfileProvider() {
    _loadProfile();
    _repo.watchProfile().listen((updatedProfile) {
      _profile = updatedProfile;
      notifyListeners();
    });
  }

  void _loadProfile() {
    _profile = _repo.profile;
    notifyListeners();
  }

  Future<void> resetProfile() async {
    await _repo.updateProfile((p) => p..mergeInsights({
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