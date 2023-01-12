bool isCurrentVersionGreaterOrEqualThan(String current, String version) {
  final currentParts = current.split('.');
  final versionParts = version.split('.');
  for (var i = 0; i < currentParts.length; i++) {
    if (versionParts.length <= i) {
      return true;
    }
    if (int.parse(currentParts[i]) > int.parse(versionParts[i])) {
      return true;
    }
    if (int.parse(currentParts[i]) < int.parse(versionParts[i])) {
      return false;
    }
  }
  return true;
}
