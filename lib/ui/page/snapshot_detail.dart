import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../util/extension/extension.dart';

class SnapshotDetail extends StatelessWidget {
  const SnapshotDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text('SnapshotDetail, id: ${context.pathParameters['id']}'),
        ),
      );
}
