# astest-dart
Simple testing framework for dart

## Examples
First, add your dependency:
```yaml
dependencies:
    astest:
      git: https://github.com/asmundstavdahl/astest-dart.git
```

Then, make your feature/scenario specification and run spec2dart.dart from the package:

```dart
//$ cat math.feature
Feature: 1 + 1 = 2
  As a calculator
  When I add 1 and 1 together
  Then the result should be 2
//$ pub run astest:spec2dart.dart math.feature
Converting 'math.feature'...
//$ cat math_test.dart
import "package:astest/bdd.dart";
import "package:test/test.dart";

main() {
  feature("1 + 1 = 2")
    ..as("a calculator", (c) {
      ;
    })
    ..when("I add 1 and 1 together", (c) {
      ;
    })
    ..then("the result should be 2", (c) {
      ;
    })();
}
```

Flesh out the tests as you see fit:
```dart
//$ cat math_test.dart
import "package:astest/bdd.dart";
import "package:test/test.dart";

main() {
  feature("1 + 1 = 2")
    ..as("a calculator", (c) {
      c.me = new Calculator();
    })
    ..when("I add 1 and 1 together", (c) {
      c.result = c.me.add(1, 1);
    })
    ..then("the result should be 2", (c) {
      expect(c.result, equals(2));
    })();
}
```

Finally, run the test and watch it fail:
```
$ pub run test math_test.dart
…
00:00 +0 -1: The specification did not pass.

    1 + 1 = 2
  -------------
      As     a calculator ←FAILED

  'file:///home/asmund/ws/hdb/hdb_dart/math_test.dart': malformed type: line 7 pos 18: type 'Calculator' is not loaded
        c.me = new Calculator();
…
```
