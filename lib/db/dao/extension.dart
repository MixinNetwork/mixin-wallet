import 'dart:convert';

import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../util/constants.dart';
import '../mixin_database.dart' hide Asset;

extension AssetResultExtension on AssetResult {
  String getDestination() {
    if (assetId == bitcoin) {
      final de = jsonDecode(this.depositEntries!) as List;
      final depositEntries = de
          .map((obj) => DepositEntry.fromJson(obj as Map<String, dynamic>))
          .toList();

      for (final entry in depositEntries) {
        if (entry.properties!.contains('SegWit')) {
          return entry.destination;
        }
      }
    }
    return destination!;
  }
}

extension AssetExtension on Asset {
  String? getDestination() {
    if (assetId == bitcoin) {
      if (depositEntries == null) {
        return null;
      }
      for (final entry in depositEntries!) {
        if (entry.properties!.contains('SegWit')) {
          return entry.destination;
        }
      }
    }
    // ignore: deprecated_member_use
    return destination;
  }
}
