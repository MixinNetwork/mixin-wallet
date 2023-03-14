// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_dao.dart';

// **************************************************************************
// DaoGenerator
// **************************************************************************

mixin _$ChainDaoMixin on DatabaseAccessor<MixinDatabase> {
  Addresses get addresses => attachedDatabase.addresses;
  Assets get assets => attachedDatabase.assets;
  Snapshots get snapshots => attachedDatabase.snapshots;
  Users get users => attachedDatabase.users;
  Fiats get fiats => attachedDatabase.fiats;
  AssetsExtra get assetsExtra => attachedDatabase.assetsExtra;
  CollectibleTokenMeta get collectibleTokenMeta =>
      attachedDatabase.collectibleTokenMeta;
  CollectibleToken get collectibleToken => attachedDatabase.collectibleToken;
  Collections get collections => attachedDatabase.collections;
  CollectibleOutput get collectibleOutput => attachedDatabase.collectibleOutput;
  Chains get chains => attachedDatabase.chains;
  Selectable<bool> checkExistsById(String chainId) {
    return customSelect(
        'SELECT EXISTS (SELECT 1 AS _c1 FROM chains WHERE chain_id = ?1) AS _c0',
        variables: [
          Variable<String>(chainId)
        ],
        readsFrom: {
          chains,
        }).map((QueryRow row) => row.read<bool>('_c0'));
  }
}
