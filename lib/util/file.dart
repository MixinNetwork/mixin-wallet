import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<Directory> getMixinDocumentsDirectory() {
  if (Platform.isLinux) {
    // https://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap08.html
    final home = Platform.environment['HOME'];
    assert(home != null, 'failed to get HOME environment.');
    return Future.value(Directory(p.join(home!, '.mixin')));
  }
  return getApplicationDocumentsDirectory();
}
