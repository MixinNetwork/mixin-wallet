import 'package:drift/drift.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

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
        fee: fee,
        tag: Value(tag),
        dust: Value(dust),
        feeAssetId: feeAssetId,
      );
}

@DriftAccessor(tables: [Addresses])
class AddressDao extends DatabaseAccessor<MixinDatabase>
    with _$AddressDaoMixin {
  AddressDao(MixinDatabase db) : super(db);

  Future<List<Addresse>> getAll() => select(db.addresses).get();

  Future<void> insertAllOnConflictUpdate(List<sdk.Address> addresses) =>
      batch((batch) => batch.insertAll(
            db.addresses,
            addresses.map((e) => e.asAddressesCompanion).toList(),
            mode: InsertMode.insertOrReplace,
          ));

  Future<void> deleteAddress(Addresse address) =>
      delete(db.addresses).delete(address);

  Selectable<Addresse> addressesByAssetId(String assetId) =>
      select(db.addresses)..where((tbl) => tbl.assetId.equals(assetId));

  Selectable<Addresse> addressesById(String addressId) =>
      select(db.addresses)..where((tbl) => tbl.addressId.equals(addressId));
}
