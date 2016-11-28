#!/usr/bin/env dart
import 'dart:io';

import 'package:args/args.dart';
import "package:astest/bdd.dart";

main(List<String> arguments) {
  exitCode = 0; //presume success
  final parser = new ArgParser();

  ArgResults argResults = parser.parse(arguments);
  List<String> paths = argResults.rest;

  for (var path in paths) {
    stderr.writeln("Converting '${path}'...");
    try {
      String textSpec = new File(path).readAsStringSync();
      String dartSpec = Specification.compileTextToDart(textSpec);
      File outputFile = new File(path
          .replaceAll(".scenario", "_test.dart")
          .replaceAll(".feature", "_test.dart"));

      bool writeToFile = false;
      if (outputFile.existsSync()) {
        print("Warning: desination file exists; oddverwrite? [yN]");
        String response = stdin.readLineSync();
        switch (response) {
          case "y":
          case "Y":
          case "yes":
          case "Yes":
          case "YES":
            writeToFile = true;
        }
      } else {
        writeToFile = true;
      }

      if (writeToFile) {
        outputFile.writeAsStringSync(dartSpec);
      }
    } catch (e) {
      stderr.writeln("Failed to convert ${path}: ${e.toString()}");
      exitCode = 1;
    }
  }
}
