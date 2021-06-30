part of '../extension.dart';

extension PathExtension on String {
  bool pathMatch(String path) {
    final regExp = pathToRegExp(this);
    return regExp.hasMatch(path);
  }

  Map<String, String> extractPathParameters(
    String path, {
    bool caseSensitive = false,
  }) {
    final parameters = <String>[];
    final regExp = pathToRegExp(
      this,
      parameters: parameters,
      caseSensitive: caseSensitive,
    );
    final match = regExp.matchAsPrefix(path);
    if (match != null) return extract(parameters, match);

    return {};
  }

  Uri toUri(Map<String, String> args) => Uri.parse(pathToFunction(this)(args));
}

extension UriExtension on Uri {
  bool pathMatch(Uri uri) => path.pathMatch(uri.path);
}
