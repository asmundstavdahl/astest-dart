import "package:astest/bdd.dart";
import "package:test/test.dart";

main() {
  scenario("Adding 1 and 1")
    ..as("a calculator", (c) {
      c.me = "A calculator";
    })
    ..given("1 is 1", (c) {
      expect(c.me, equals("A calculator"));
    })
    ..and("1 is not 0", (c) {
      expect(1, isNot(0));
    })
    ..and("1 is less than 2", (c) {
      expect(1, lessThan(2));
    })
    ..and("1 is greater than -1", (c) {
      expect(1, greaterThan(-1));
    })
    ..when("I add 1 and 1 together", (c) {
      c.result = 1 + 1;
    })
    ..then("the result should be 2", (c) {
      expect(c.result, equals(2));
    })
    ..and("not 3", (c) {
      expect(c.result, isNot(3));
    })();
}
