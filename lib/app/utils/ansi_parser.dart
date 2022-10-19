/// Simple parser for ANSI color sequences

class AnsiSpan {
  final String text;
  final List<int> codes;

  AnsiSpan(this.text, this.codes);
}

Iterable<AnsiSpan> parseAnsi(String input) sync* {
  final matches = _regexp.allMatches(input);
  int offset = 0;
  List<int> codes = [];

  for (final match in matches) {
    final text = input.substring(offset, match.start);
    if (text.isNotEmpty) {
      yield AnsiSpan(text, codes);
      codes.clear();
    }

    codes.addAll(_parseCodes(match.group(1)!));
    offset = match.end;
  }

  yield AnsiSpan(input.substring(offset), codes);
}

List<int> _parseCodes(String input) =>
    input.trim().split(';').map((chunk) => int.tryParse(chunk) ?? 0).toList();

final _regexp = RegExp(r'\u001b\[(\d+(:?;\d+)*)m');
