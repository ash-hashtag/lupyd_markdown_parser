import 'package:markdown_parser/tuple.dart';

bool areListsEqual<T>(List<T> a, List<T> b) {
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
}

class PatternMatcher {
  final Iterable<Match> Function(String) matcher;
  final String Function(String) delimiter;
  final String type;

  PatternMatcher(
      {required this.type, required this.matcher, required this.delimiter});

  factory PatternMatcher.fromRegExp(
          RegExp regExp, String type, String Function(String) delimiter) =>
      PatternMatcher(
          delimiter: delimiter,
          matcher: (String input) => regExp.allMatches(input),
          type: type);

  @override
  String toString() => "PatternMatcher { type: $type }";
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

    final type = [...currentTypes, match.b.type];
    final part = PatternMatchPart(
        text:
            match.b.delimiter(inputText.substring(match.a.start, match.a.end)),
        type: type);
    final result = parseText(part, patternMatchers);
    parts.addAll(result);
    current = match.a.end;
  }

  if (current < inputText.length) {
    final input = inputText.substring(current);
    final part = PatternMatchPart(text: input, type: currentTypes);
    parts.add(part);
  }

  return parts;
}
// List<PatternMatchPart> parseText(
//     PatternMatchPart inputPart, List<PatternMatcher> patternMatchers) {
//   final parts = <PatternMatchPart>[];

//   if (patternMatchers.isEmpty) {
//     return parts;
//   }

//   final firstMatcher = patternMatchers.first;

//   var i = 0;
//   for (final match in firstMatcher.matcher(inputPart.text)) {
//     if (i != match.start) {
//       parts.add(PatternMatchPart(
//           text: inputPart.text.substring(i, match.start),
//           type: inputPart.type));
//     }
//     parts.add(PatternMatchPart(
//         text: firstMatcher
//             .delimiter(inputPart.text.substring(match.start, match.end)),
//         type: [...inputPart.type, firstMatcher.type]));
//     i = match.end;
//   }

//   if (i != inputPart.text.length) {
//     parts.add(PatternMatchPart(
//         text: inputPart.text.substring(i), type: inputPart.type));
//   }

//   final remainingMatchers = patternMatchers.sublist(1);

//   print("matcher: $firstMatcher result: $parts remaining: $remainingMatchers");
//   final newParts = <PatternMatchPart>[];
//   for (final part in parts) {
//     final result = parseText(part, remainingMatchers);
//     if (result.isEmpty) {
//       newParts.add(part);
//     } else {
//       newParts.addAll(result);
//     }
//   }

//   return newParts;
// }

const rawBoldRegex = r"(?<!\\)\*\*\*(.*?)(?<!\\)\*\*\*";
const rawItalicRegex = r"(?<!\\)\/\/\/(.*?)(?<!\\)\/\/\/";
const rawUnderlineRegex = r"(?<!\\)___(.*?)(?<!\\)___";

String tripleDelimiter(String _) => _.substring(3, _.length - 3);

void defaultTest() {
  final boldMatcher =
      PatternMatcher.fromRegExp(RegExp(rawBoldRegex), "bold", tripleDelimiter);
  final italicMatcher = PatternMatcher.fromRegExp(
      RegExp(rawItalicRegex), "italic", tripleDelimiter);
  final underlineMatcher = PatternMatcher.fromRegExp(
      RegExp(rawUnderlineRegex), "underline", tripleDelimiter);
  final matchers = [
    boldMatcher,
    italicMatcher,
    underlineMatcher,
  ];
  const inputText =
      "hello ***wo///rl///d*** ok///no ***thanks***/// ___under///***bombastic*** bomba fantastic ///___";

  print("input: $inputText");
  final parts = parseText(PatternMatchPart(text: inputText), matchers);

  print(parts);
}
