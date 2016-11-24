import "dart:io";

import 'package:astest/bdd.dart';
import "package:test/test.dart";

main() {
  test("exits with exit code 0 when supplied with no arguments", () {
    ProcessResult result = Process.runSync("dart", ["tool/spec2dart.dart"]);
    if (result.exitCode != 0) {
      print(result.stdout.toString());
      print(result.stderr.toString());
    }
    expect(result.exitCode, equals(0));
  });

  test("exits with an error core if a file does not exist", () {
    ProcessResult result =
        Process.runSync("dart", ["tool/spec2dart.dart", "±—…łð@"]);
    if (result.exitCode == 0) {
      print(result.stdout.toString());
      print(result.stderr.toString());
    }
    expect(result.exitCode, isNot(0));
  });

  test("can compile one .scenario file to .dart", () {
    ProcessResult result = Process.runSync(
        "dart", ["tool/spec2dart.dart", "test/misc/spec2dart/1.scenario"]);
    if (result.exitCode != 0) {
      print(result.stdout.toString());
      print(result.stderr.toString());
    }
    expect(result.exitCode, equals(0));

    String dartSpec =
        new File("test/misc/spec2dart/1_test.dart").readAsStringSync();
    String wantedDartSpec =
        new File("test/misc/spec2dart/1_test.wanted.dart")
            .readAsStringSync();
    expect(dartSpec, equals(wantedDartSpec));
  });

  test("compiles multiple files to \$f.dart", () {
    List<String> scenarioFiles = [
      "test/misc/spec2dart/1.scenario",
      "test/misc/spec2dart/2.scenario",
      "test/misc/spec2dart/3.scenario"
    ];

    var args = ["tool/spec2dart.dart"];
    args.addAll(scenarioFiles);
    ProcessResult result =
        Process.runSync("dart", args);
    if (result.exitCode != 0) {
      print(result.stdout.toString());
      print(result.stderr.toString());
    }
    expect(result.exitCode, equals(0));

    for (String scenarioFile in scenarioFiles) {
      String dartSpec =
          new File(scenarioFile.replaceAll(".scenario", "_test.dart"))
              .readAsStringSync();
      String wantedDartSpec = new File(
              scenarioFile.replaceAll(".scenario", "_test.wanted.dart"))
          .readAsStringSync();
      expect(dartSpec, equals(wantedDartSpec));
    }
  });
}
