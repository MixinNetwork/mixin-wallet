import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:moor/moor.dart';

import '../mixin_database.dart';

part 'address_dao.g.dart';

extension AddressConverter on sdk.Address {
  AddressesCompanion get asAddressesCompanion => AddressesCompanion.insert(
      addressId: addressId,
      type: type,
      assetId: assetId,
      destination: destination,
      label: label,
      updatedAt: updatedAt,
      reserve: reserve,
      fee: fee);
}

@UseDao(tables: [Addresses])
class AddressDao extends DatabaseAccessor<MixinDatabase>
    with _$AddressDaoMixin {
  AddressDao(MixinDatabase db) : super(db);

  Future<List<Addresse>> getAll() => select(db.addresses).get();

  Future<int> insert(Addresse address) =>
      into(db.addresses).insertOnConflictUpdate(address);

  Future<void> insertAllOnConflictUpdate(List<sdk.Address> addresses) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.addresses,
        addresses.map((e) => e.asAddressesCompanion).toList(),
      );
    });
  }

  Future deleteAddress(Addresse address) =>
      delete(db.addresses).delete(address);

  Selectable<Addresse> addressesByAssetId(String assetId) =>
      select(db.addresses)..where((tbl) => tbl.assetId.equals(assetId));
}
