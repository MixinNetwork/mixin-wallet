import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:provider/provider.dart';
import 'package:rational/rational.dart';
import 'package:vrouter/vrouter.dart' show VRouterContext;

import '../../db/mixin_database.dart';
import '../../service/app_services.dart';
import '../constants.dart';
import '../l10n.dart';

export 'package:collection/collection.dart';
export 'package:provider/provider.dart' show ReadContext, WatchContext;

export '../../ui/widget/brightness_observer.dart';
export '../l10n.dart';
export 'src/async.dart';
export 'src/errors.dart';

part 'src/iterable.dart';

part 'src/number.dart';

part 'src/path.dart';

part 'src/provider.dart';

part 'src/string.dart';

void importExtension() {}
