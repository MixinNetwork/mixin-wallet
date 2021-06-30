import 'package:flutter/widgets.dart';

import '../generated/l10n.dart';

export '../generated/l10n.dart';

extension L10nExtension on BuildContext {
  L10n get l10n => L10n.of(this);
}
