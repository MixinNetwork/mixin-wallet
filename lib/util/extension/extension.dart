import 'dart:math' as math;
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:provider/provider.dart';

import '../../db/mixin_database.dart';
import '../../service/app_services.dart';
import '../../service/auth/auth_manager.dart';
import '../../ui/router/mixin_router_delegate.dart';
import '../constants.dart';
import '../l10n.dart';

export 'package:provider/provider.dart';

export '../../ui/widget/brightness_observer.dart';
export '../l10n.dart';

part 'src/iterable.dart';
part 'src/number.dart';
part 'src/path.dart';
part 'src/provider.dart';
part 'src/string.dart';

void importExtension() {}
