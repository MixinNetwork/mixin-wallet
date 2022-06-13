import 'package:drift/drift.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../mixin_database.dart';

part 'user_dao.g.dart';

extension UserMapper on sdk.User {
  User toDbUser() => User(
      userId: userId,
      identityNumber: identityNumber,
      relationship: relationship,
      fullName: fullName,
      avatarUrl: avatarUrl,
      phone: phone,
      isVerified: isVerified,
      appId: app?.appId,
      biography: biography,
      muteUntil: DateTime.tryParse(muteUntil),
      isScam: isScam ? 1 : 0,
      createdAt: createdAt);
}

@DriftAccessor(tables: [User])
class UserDao extends DatabaseAccessor<MixinDatabase> with _$UserDaoMixin {
  UserDao(MixinDatabase db) : super(db);

  Future<int> insert(User user) => into(db.users).insertOnConflictUpdate(user);

  Future<void> insertAll(List<User> users) async => batch((batch) {
        batch.insertAllOnConflictUpdate(db.users, users);
      });

  Future deleteUser(User user) => delete(db.users).delete(user);

  SimpleSelectStatement<Users, User> userById(String userId) =>
      select(db.users)..where((tbl) => tbl.userId.equals(userId));

  Selectable<String> findExistsUsers(List<String> userIds) =>
      (select(db.users)..where((tbl) => tbl.userId.isIn(userIds)))
          .map((u) => u.userId);
}
