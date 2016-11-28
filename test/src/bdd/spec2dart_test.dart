import 'dart:async';
import "dart:io";
import "dart:convert";

import 'package:astest/bdd.dart';
import "package:test/test.dart";

String spec2dartPath = "bin/spec2dart.dart";

main() {
  test("exits with exit code 0 when supplied with no arguments", () {
    ProcessResult result = Process.runSync("dart", [spec2dartPath]);
    if (result.exitCode != 0) {
      print(result.stdout.toString());
      print(result.stderr.toString());
    }
    expect(result.exitCode, equals(0));
  });

  test("exits with an error core if a file does not exist", () {
    ProcessResult result = Process.runSync("dart", [spec2dartPath, "±—…łð@"]);
    if (result.exitCode == 0) {
      print(result.stdout.toString());
      print(result.stderr.toString());
    }
    expect(result.exitCode, isNot(0));
  });

  test("can compile one .scenario file to .dart", () {
    ProcessResult result = Process
        .runSync("dart", [spec2dartPath, "test/misc/spec2dart/1.scenario"]);
    if (result.exitCode != 0) {
      print(result.stdout.toString());
      print(result.stderr.toString());
    }
    expect(result.exitCode, equals(0));

    String dartSpec =
        new File("test/misc/spec2dart/1_test.dart").readAsStringSync();
    String wantedDartSpec =
        new File("test/misc/spec2dart/1_test.wanted.dart").readAsStringSync();
    expect(dartSpec, equals(wantedDartSpec));
  });

  test("compiles multiple files to \$f.dart", () {
    List<String> scenarioFiles = [
      "test/misc/spec2dart/1.scenario",
      "test/misc/spec2dart/2.scenario",
      "test/misc/spec2dart/3.scenario"
    ];

    var args = [spec2dartPath];
    args.addAll(scenarioFiles);
    ProcessResult result = Process.runSync("dart", args);
    if (result.exitCode != 0) {
      print(result.stdout.toString());
      print(result.stderr.toString());
    }
    expect(result.exitCode, equals(0));

    for (String scenarioFile in scenarioFiles) {
      String dartSpec =
          new File(scenarioFile.replaceAll(".scenario", "_test.dart"))
              .readAsStringSync();
      String wantedDartSpec =
          new File(scenarioFile.replaceAll(".scenario", "_test.wanted.dart"))
              .readAsStringSync();
      expect(dartSpec, equals(wantedDartSpec));
    }
  });

  test("asks if you want to overwrite if the test file exists", () async {
    // Make sure the test file is gone before trying
    new File("test/misc/spec2dart/1_test.dart").deleteSync();

    Process.start("dart", [
      spec2dartPath,
      "test/misc/spec2dart/1.scenario",
      "test/misc/spec2dart/1.scenario"
    ]).then((Process p) async {
      // Kill the process if it blocks looking for data on stdin or something.
      new Timer(new Duration(seconds: 1), () => p.kill());

      Stream lines =
          p.stdout.transform(UTF8.decoder).transform(const LineSplitter());

      var wasAsked = false;

      await for (String line in lines) {
        print(line);
        if (line.contains("overwrite?")) {
          wasAsked = true;
          p.stdin.writeln("y");
        }
      }

      expect(wasAsked, isTrue);
    });
  });
}
