import 'package:flutter/material.dart';

class MixinErrorWidget extends StatelessWidget {
  const MixinErrorWidget({
    required this.details,
    super.key,
  });

  static Widget defaultErrorWidgetBuilder(FlutterErrorDetails details) =>
      MixinErrorWidget(details: details);

  static String _stringify(Object? exception) {
    try {
      return exception.toString();
    } catch (error) {
      // ignore
    }
    return 'Error';
  }

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        child: Text(
          'Error! ${_stringify(details.exception)} \n ${_stringify(details.stack)}',
          style: const TextStyle(color: Colors.red, fontSize: 12),
          textDirection: TextDirection.ltr,
        ),
      );
}
