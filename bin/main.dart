import 'dart:io';
import 'package:args/args.dart';
import 'package:rewind/rewind.dart' as rewind;
import 'package:console/console.dart';

main(List<String> arguments) {
  // Make sure the console library works
  try {
    Console.init();
  } catch (err) {
    print('Your platform does not support advanced console features, cannot continue.');
    exit(-1);
  }
  if (arguments.isEmpty) {
    // Print help
    rewind.printHelp();
  } else {
    // Parse arguments
    var parser = new ArgParser();
    parser.addFlag('simple', abbr: 's');
    var args = parser.parse(arguments);
    // Find cached pages and print them
    rewind.loadCache(args.rest[0], args);
  }
}
