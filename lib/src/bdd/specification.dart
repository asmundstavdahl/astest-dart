library astest.bdd.specification;

import "package:test/test.dart";

import "../context.dart";

class Specification {
  String description;

  Specification(this.description);

  /// Generates a dart code skeleton from [specText] and returns it as a String.
  static String compileTextToDart(String specText) {
    String dart = '''
import "package:astest/bdd.dart";
import "package:test/test.dart";

main() {''';

    var lines = specText.split("\n");
    var featureOrScenarioStringPrefix = "";
    for (var lineNumber = 1; lineNumber <= lines.length; lineNumber++) {
      var line = lines[lineNumber - 1];

      if (line.contains(new RegExp(r"^$"))) {
        continue;
      }

      var keywordPattern = new RegExp(
          r"^\s*(Feature|Scenario|As|I want|So that|Given|When|Then|And|But|Examples?):?[ \t]+(.*)$");
      if (line.contains(keywordPattern)) {
        var matches = keywordPattern.allMatches(line);
        var keyword = matches.elementAt(0).group(1);
        var restOfLine = matches.elementAt(0).group(2);
        restOfLine = restOfLine.replaceAll('\\', '\\\\');
        restOfLine = restOfLine.replaceAll('"', '\\"');

        switch (keyword) {
          case "Scenario":
            dart = dart + "${featureOrScenarioStringPrefix}\n  scenario(\"${restOfLine}\")";
            featureOrScenarioStringPrefix = "();\n";
            break;
          case "Feature":
            dart = dart + "${featureOrScenarioStringPrefix}\n  feature(\"${restOfLine}\")";
            featureOrScenarioStringPrefix = "();\n";
            break;
          case "As":
          case "I want":
          case "So that":
          case "Given":
          case "When":
          case "Then":
          case "And":
          case "But":
          case "Example":
          case "Examples":
            dart = dart +
                '''

    ..${keyword.toLowerCase().replaceAll(" ", "_")}("${restOfLine}", (c) {
      ;
    })''';
        }
      }
    }

    dart = dart + "();\n}\n";

    return dart;
  }

  Context context = new Context();
  Map<String, List<SpecificationProceedure>> callbacks = {};
  List<String> _as = [];
  List<String> _iWant = [];
  List<String> _soThat = [];
  String _prevProceedureKey;

  call() => run();

  run() {
    tearDown(() {
      for (var proceedureKey in callbacks.keys) {
        for (var sp in callbacks[proceedureKey]) {
          if (sp.error != null) {
            fail(sp.error);
          }
        }
      }
    });

    String currentSpecificationProgress = "\n    ${description}\n  ${'-' * (description.length + 4)}";

    //test(getScenarioTestDescription(), () {
      for (var proceedureKey in callbacks.keys) {
        var firstLetterPattern = new RegExp(r"^.");
        String proceedureLabel = proceedureKey.replaceFirst(firstLetterPattern, proceedureKey[0].toUpperCase()).padRight(6);
        for (var sp in callbacks[proceedureKey]) {
          currentSpecificationProgress =
              currentSpecificationProgress + "\n      ${proceedureLabel} ${sp.description}";
          sp.error = "The specification did not pass.\n ${currentSpecificationProgress} ←FAILED\n";
          test(sp.error, (){
            sp(context);
          });
          sp.error = null;
        }
      }
    //});
  }

  getScenarioTestDescription() {
    String description = "";
    if (_as.length > 0) {
      description = description +
          """
As a
  - ${_as.join("\\n  - ")}
  """;
    }
    if (_iWant.length > 0) {
      description = description +
          """
I want
  - ${_iWant.join("\\n  - ")}
  """;
    }
    if (_soThat.length > 0) {
      description = description +
          """
So that
  - ${_soThat.join("\\n  - ")}
""";
    }
  }

  Function as(String s, Function proceedure) {
    String proceedureKey = "as";
    if (callbacks[proceedureKey] == null)
      callbacks[proceedureKey] = new List<Function>();
    callbacks[proceedureKey].add(new SpecificationProceedure(s, proceedure));
    _prevProceedureKey = proceedureKey;
    _as.add(s);
    return this;
  }

  Function i_want(String s, Function proceedure) {
    String proceedureKey = "i_want";
    if (callbacks[proceedureKey] == null)
      callbacks[proceedureKey] = new List<Function>();
    callbacks[proceedureKey].add(new SpecificationProceedure(s, proceedure));
    _prevProceedureKey = proceedureKey;
    _iWant.add(s);
    return this;
  }

  Function so_that(String s, Function proceedure) {
    String proceedureKey = "so_that";
    if (callbacks[proceedureKey] == null)
      callbacks[proceedureKey] = new List<Function>();
    callbacks[proceedureKey].add(new SpecificationProceedure(s, proceedure));
    _prevProceedureKey = proceedureKey;
    _soThat.add(s);
    return this;
  }

  Function given(String s, Function proceedure) {
    String proceedureKey = "given";
    if (callbacks[proceedureKey] == null)
      callbacks[proceedureKey] = new List<Function>();
    callbacks[proceedureKey].add(new SpecificationProceedure(s, proceedure));
    _prevProceedureKey = proceedureKey;
    return this;
  }

  Function when(String s, Function proceedure) {
    String proceedureKey = "when";
    if (callbacks[proceedureKey] == null)
      callbacks[proceedureKey] = new List<Function>();
    callbacks[proceedureKey].add(new SpecificationProceedure(s, proceedure));
    _prevProceedureKey = proceedureKey;
    return this;
  }

  Function then(String s, Function proceedure) {
    String proceedureKey = "then";
    if (callbacks[proceedureKey] == null)
      callbacks[proceedureKey] = new List<Function>();
    callbacks[proceedureKey].add(new SpecificationProceedure(s, proceedure));
    _prevProceedureKey = proceedureKey;
    return this;
  }

  Function and(String s, Function proceedure) {
    String proceedureKey = _prevProceedureKey;
    if (callbacks[proceedureKey] == null)
      callbacks[proceedureKey] = new List<Function>();
    assert(_prevProceedureKey != null);
    callbacks[_prevProceedureKey]
        .add(new SpecificationProceedure(s, proceedure));
    return this;
  }
}

class SpecificationProceedure {
  String description;
  Function function;
  String error = null;
  SpecificationProceedure(this.description, this.function);
  call(Context context) => function(context);
}
