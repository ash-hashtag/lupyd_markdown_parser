import 'package:markdown_parser/tuple.dart';

bool areListsEqual<T>(List<T> a, List<T> b) {
  if (a == b) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

class PatternMatchPart {
  final String text;
  final List<String> type;

  const PatternMatchPart({required this.text, this.type = const []});

  @override
  String toString() => '{ text: "$text", type: $type }';

  bool isEqual(PatternMatchPart other) {
    if (other == this) {
      return true;
    }
    return other.text == text && areListsEqual(other.type, type);
  }
}

class PatternMatcher {
  final Iterable<Match> Function(String) matcher;
  final String Function(String) delimiter;
  final String type;
  final bool lookInwards;
  final bool singleType;

  PatternMatcher(
      {required this.type,
      required this.matcher,
      required this.delimiter,
      required this.lookInwards,
      required this.singleType});

  @override
  String toString() => "PatternMatcher { type: $type }";
}

class RegexPatternMatcher extends PatternMatcher {
  final RegExp regex;
  RegexPatternMatcher(
      {required super.type,
      required super.matcher,
      required super.delimiter,
      required this.regex,
      required super.lookInwards,
      required super.singleType});
  factory RegexPatternMatcher.from(RegExp regExp, String type,
      String Function(String) delimiter, bool lookInwards, bool singleType) {
    return RegexPatternMatcher(
        delimiter: delimiter,
        matcher: (String input) => regExp.allMatches(input),
        type: type,
        regex: regExp,
        lookInwards: lookInwards,
        singleType: singleType);
  }
  @override
  String toString() =>
      "RegexPatternMatcher { type: $type, regex: ${regex.pattern} }";
}

List<PatternMatchPart> parseText(
    PatternMatchPart inputPart, List<PatternMatcher> patternMatchers) {
  final inputText = inputPart.text;
  final parts = <PatternMatchPart>[];

  if (patternMatchers.isEmpty) {
    return [inputPart];
  }

  final patternMatches = <Tuple<Match, PatternMatcher>>[];
  for (final patternMatcher in patternMatchers) {
    patternMatches.addAll(
        patternMatcher.matcher(inputText).map((e) => Tuple(e, patternMatcher)));
  }

  patternMatches.sort((a, b) => a.a.start - b.a.start);

  var current = 0;
  var currentTypes = [...inputPart.type];
  for (final match in patternMatches) {
    if (current > match.a.start) {
      continue;
    }
    if (current < match.a.start) {
      final part = PatternMatchPart(
          text: inputText.substring(current, match.a.start),
          type: currentTypes);
      final result = parseText(part, patternMatchers);
      parts.addAll(result);
    }

    final type = [if (!match.b.singleType) ...currentTypes, match.b.type];
    final part = PatternMatchPart(
        text:
            match.b.delimiter(inputText.substring(match.a.start, match.a.end)),
        type: type);
    if (match.b.lookInwards) {
      final result = parseText(part, patternMatchers);
      parts.addAll(result);
    } else {
      parts.add(part);
    }
    current = match.a.end;
  }
  if (current < inputText.length) {
    final input = inputText.substring(current);
    final part = PatternMatchPart(text: input, type: currentTypes);
    parts.add(part);
  }

  return parts;
}

const rawBoldRegex = r"(?<!\\)\*\*\*(.*?)(?<!\\)\*\*\*";
const rawItalicRegex = r"(?<!\\)\/\/\/(.*?)(?<!\\)\/\/\/";
const rawUnderlineRegex = r"(?<!\\)___(.*?)(?<!\\)___";
const rawHeaderRegex = r"(?<!\\)###(.*?)(?<!\\)###";
const rawHashtagRegex = r"(?<!\\)#\w+";
const rawMentionRegex = r"(?<!\\)@\w+";
const rawQuoteRegex = r"^>\|\s.*$";
const rawHyperLinkRegex = r"\[(.+)\]\((.+)\)";

List<PatternMatcher> defaultMatchers() {
  final boldMatcher = RegexPatternMatcher.from(
      RegExp(rawBoldRegex), "bold", tripleDelimiterBoth, true, false);
  final italicMatcher = RegexPatternMatcher.from(
      RegExp(rawItalicRegex), "italic", tripleDelimiterBoth, true, false);
  final underlineMatcher = RegexPatternMatcher.from(
      RegExp(rawUnderlineRegex), "underline", tripleDelimiterBoth, true, false);
  final headerMatcher = RegexPatternMatcher.from(
      RegExp(rawHeaderRegex), "header", tripleDelimiterBoth, true, false);
  final hashtagMatcher = RegexPatternMatcher.from(
      RegExp(rawHashtagRegex), "hashtag", noDelimiter, false, true);
  final mentionMatcher = RegexPatternMatcher.from(
      RegExp(rawMentionRegex), "mention", noDelimiter, false, true);
  final quoteMatcher = RegexPatternMatcher.from(
      RegExp(rawQuoteRegex, multiLine: true),
      "quote",
      tripleDelimiter,
      true,
      false);
  final hyperLinkMatcher = RegexPatternMatcher.from(
      RegExp(rawHashtagRegex), "hyperlink", noDelimiter, false, true);

  return [
    boldMatcher,
    italicMatcher,
    underlineMatcher,
    headerMatcher,
    hashtagMatcher,
    mentionMatcher,
    quoteMatcher,
    hyperLinkMatcher,
  ];
}

String tripleDelimiterBoth(String _) => _.substring(3, _.length - 3);
String noDelimiter(String _) => _;
String singleDelimiter(String _) => _.substring(1);
String doubleDelimiter(String _) => _.substring(2);
String tripleDelimiter(String _) => _.substring(3);

void defaultTest(String input, List<PatternMatcher> matchers) {
  final inputText = input;
  final parts = parseText(PatternMatchPart(text: inputText), matchers);

  print(parts);
}
