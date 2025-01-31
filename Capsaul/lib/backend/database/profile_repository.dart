// 3. Create a new profile_repository.dart
import 'package:capsaul/backend/database/box.dart';
import 'package:capsaul/backend/database/profile_entity.dart';
import 'package:objectbox/objectbox.dart';

class ProfileRepository {
  final Box<Profile> _box;

  ProfileRepository() : _box = ObjectBoxUtil().box!.store.box<Profile>();

  Profile get profile => _box.get(1) ?? Profile();

  Stream<Profile> watchProfile() =>
      _box.query().watch().map((q) => q.findFirst() ?? Profile());

  Future<void> updateProfile(void Function(Profile) updater) async {
    final profile = this.profile;
    updater(profile);
    _box.put(profile);
  }
}
