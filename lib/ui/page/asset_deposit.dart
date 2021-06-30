import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../util/extension/extension.dart';

class AssetDeposit extends StatelessWidget {
  const AssetDeposit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text('AssetDeposit, id: ${context.pathParameters['id']}'),
        ),
      );
}
