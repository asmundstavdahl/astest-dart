import "dart:io";

import 'package:astest/bdd.dart';
import "package:test/test.dart";

main() {
  test("can compile text to dart skeleton", () {
    String specText = new File("test/misc/scenario/1plus1.scenario").readAsStringSync();
    String wantedSpecDart = new File("test/misc/scenario/1plus1_test.wanted.dart").readAsStringSync();

    expect(specText, isNotEmpty);
    expect(wantedSpecDart, isNotEmpty);

    String specDart = Specification.compileTextToDart(specText);
    expect(specDart, equals(wantedSpecDart));
  });
}
