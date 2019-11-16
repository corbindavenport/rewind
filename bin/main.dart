import 'dart:io';

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
    // Look for pages
    rewind.loadCache(arguments[0]);
  }
}
