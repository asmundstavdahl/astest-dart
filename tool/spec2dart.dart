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
      new File(path.replaceAll(".scenario", "_test.dart"))
          .writeAsStringSync(dartSpec);
    } catch (e) {
      stderr.writeln("Failed to convert ${path}: ${e.toString()}");
      exitCode = 1;
    }
  }
}
