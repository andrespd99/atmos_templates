/// String extension that capitalizes the first letter of each word.
extension StringExtension on String {
  /// Returns a new string splitted by spaces, underscores, and dashes.
  /// The first letter of each word is capitalized.
  String toTitleCase() => _titleCaseImpl(this);

  String _titleCaseImpl(String input) {
    return input.trim().split(RegExp(r'\s+|_|-')).map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
