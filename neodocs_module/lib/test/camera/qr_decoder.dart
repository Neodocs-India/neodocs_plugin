Map<String, dynamic> decodeDataAdvanced(String encodedString) {
  List<String> decodedWords = [];
  int position = 0;

  while (position < encodedString.length) {
    // Read potential length indicator digits
    int lengthStart = position;
    while (position < encodedString.length &&
        RegExp(r'\d').hasMatch(encodedString[position])) {
      position++;
    }

    if (position == lengthStart) {
      throw ArgumentError(
          'Invalid encoded string: expected length indicator at position $lengthStart');
    }

    // Try different length interpretations (from longest to shortest)
    bool found = false;
    for (int end = position; end > lengthStart; end--) {
      String lengthStr = encodedString.substring(lengthStart, end);
      int length = int.parse(lengthStr);
      int dataStart = end;

      // Check if we have enough characters for this length
      if (dataStart + length <= encodedString.length) {
        // This interpretation works
        String word = encodedString.substring(dataStart, dataStart + length);
        decodedWords.add(word);
        position = dataStart + length;
        found = true;
        break;
      }
    }

    if (!found) {
      throw ArgumentError(
          'Invalid encoded string: no valid interpretation found starting at position $lengthStart');
    }
  }

  // Map the decoded words to their respective keys
  List<String> keys = ['CN', 'TYPE', 'BATCH', 'STRIP'];
  Map<String, String> result = {};

  for (int i = 0; i < decodedWords.length && i < keys.length; i++) {
    result[keys[i]] = decodedWords[i];
  }

  return result;
}
