import 'package:flutter/foundation.dart';
import 'package:moor/moor_web.dart';

import '../../mixin_database.dart';

Future<MixinDatabase> constructDb(String _) async => MixinDatabase(
      WebDatabase.withStorage(
        await MoorWebStorage.indexedDbIfSupported('mixin'),
        logStatements: !kReleaseMode,
      ),
    );
