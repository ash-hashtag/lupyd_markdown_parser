import 'package:lupyd_markdown_parser/lupyd_markdown_parser.dart';

void main(List<String> arguments) {
  test();
}

void test() {
  const inputText =
      r"""hello @nope_dolalt ***wo///rl///d*** ok///no ***thanks***/// ___under///***bombastic*** bomba fantastic ///___ ####hashtag### ___hello___ #nope
>| hello quoted text #hashtag
// hyperlink: [nope](word)   """;

  var matchers = defaultMatchers();

  defaultTest(inputText, matchers);
}
