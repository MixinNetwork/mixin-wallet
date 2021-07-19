import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart' show VRouterContext;

import '../../db/mixin_database.dart';
import '../../service/app_services.dart';
import '../../service/profile/profile_manager.dart';
import '../constants.dart';
import '../l10n.dart';

export 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart'
    show UuidHashcodeExtension;
export 'package:provider/provider.dart' show ReadContext, WatchContext;

export '../../ui/widget/brightness_observer.dart';
export '../l10n.dart';

part 'src/iterable.dart';

part 'src/number.dart';

part 'src/path.dart';

part 'src/provider.dart';

part 'src/string.dart';

void importExtension() {}
