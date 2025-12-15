// lib/core/extensions/string_extension.dart
extension StringExtension on String {
  // Memanfaatkan extension untuk mempermudah formatting
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}