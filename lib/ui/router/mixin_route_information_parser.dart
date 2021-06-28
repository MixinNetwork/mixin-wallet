import 'package:flutter/widgets.dart';

class MixinRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.tryParse(routeInformation.location!);

    print('parseRouteInformation fuck uri: $uri, path: ${uri?.path}');
    return uri ?? Uri(path: '404');
  }

  @override
  RouteInformation? restoreRouteInformation(Uri configuration) =>
      RouteInformation(location: configuration.toString());
}
