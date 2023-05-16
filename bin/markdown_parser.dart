import 'makrdown_parser_base.dart';

void main(List<String> arguments) {
  defaultTest();
}

// void defaultTest() {
//   final boldMatcher = regexPatternMatcher(RegExp(r"\*\*\*(.*?)\*\*\*"));
//   final italicMatcher = regexPatternMatcher(RegExp(r"\/\/\/(.*?)\/\/\/"));
//   final underlineMatcher = regexPatternMatcher(RegExp(r"___(.*?)___"));
//   final matchers = [
//     Tuple(ParsedPartType.bold, boldMatcher),
//     Tuple(ParsedPartType.italic, italicMatcher),
//   ];
//   const inputText = "hello ***world*** ok///no///";

//   final parts = parseText([ParsedPart.fromString(inputText)], matchers);

//   print(parts);
// }

// enum ParsedPartType {
//   none,
//   bold,
//   italic,
// }

// class ParsedPart {
//   final String text;
//   final ParsedPartType type;

//   const ParsedPart(this.text, this.type);

//   factory ParsedPart.fromMatch(
//       String input, Tuple<ParsedPartType, PatternMatch> match) {
//     return ParsedPart(input.substring(match.b.start, match.b.end), match.a);
//   }

//   factory ParsedPart.fromString(String input,
//       [ParsedPartType type = ParsedPartType.none]) {
//     return ParsedPart(input, type);
//   }

//   @override
//   String toString() => "{ type: $type, text: \"$text\" }";
// }

// class PatternMatch {
//   final int start, end;
//   const PatternMatch(this.start, this.end);

//   factory PatternMatch.fromMatch(Match match) {
//     return PatternMatch(match.start, match.end);
//   }
// }

// typedef PatternMatcher = Iterable<PatternMatch> Function(String input);

// PatternMatcher regexPatternMatcher(RegExp regExp) =>
//     (String input) => regExp.allMatches(input).map(PatternMatch.fromMatch);

// List<ParsedPart> parseText(
//   List<ParsedPart> inputParts,
//   List<Tuple<ParsedPartType, PatternMatcher>> patternMatchers,
// ) {
//   var parts = List<ParsedPart>.from(inputParts);

//   var newParts = <ParsedPart>[];
//   for (final matcher in patternMatchers) {
//     for (final part in parts) {
//       final input = part.text;
//       var i = 0;
//       for (final match in matcher.b(input)) {
//         if (i != match.start) {
//           newParts.add(
//               ParsedPart(input.substring(i, match.start), ParsedPartType.none));
//         }
//         newParts.add(
//             ParsedPart(input.substring(match.start, match.end), matcher.a));
//         i = match.end;
//       }
//       if (i != input.length) {
//         newParts.add(
//             ParsedPart(input.substring(i, input.length), ParsedPartType.none));
//       }
//     }
//     parts = newParts;
//     newParts = [];
//   }

//   return parts;
// }
