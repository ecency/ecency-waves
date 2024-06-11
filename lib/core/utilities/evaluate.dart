class Evaluate{
  static String? stringOrNull(String? param) {
    if (param == null) return null;
    return "'$param'";
  }
}