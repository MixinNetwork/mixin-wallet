import 'package:moor/moor.dart';

import '../mixin_database.dart';

part 'user_dao.g.dart';

@UseDao(tables: [User])
class UserDao extends DatabaseAccessor<MixinDatabase> with _$UserDaoMixin {
  UserDao(MixinDatabase db) : super(db);

  Future<int> insert(User user) => into(db.users).insertOnConflictUpdate(user);

  Future<void> insertAll(List<User> users) async => batch((batch) {
        batch.insertAllOnConflictUpdate(db.users, users);
      });

  Future deleteUser(User user) => delete(db.users).delete(user);

  SimpleSelectStatement<Users, User> userById(String userId) =>
      select(db.users)..where((tbl) => tbl.userId.equals(userId));
}
