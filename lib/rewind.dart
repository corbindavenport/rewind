import 'package:console/console.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'dart:convert' as convert;

void printHelp() {
  Console.setBold(true);
  print('Rewind version 1.1');
  Console.setBold(false);
  print('Usage: rewind [arguments] <url>\n');
  Console.setBold(true);
  print('Optional arguments:');
  Console.setBold(false);
  print('-s     Output cached links as non-formatted list (helpful for scripting)');
  print('');
}

void printFormattedResults(String waybackResult, String googleCacheResult, String bingCacheResult) {
  print('\n');
  // Wayback Machine
  if (waybackResult == '') {
    print('Wayback Machine: ${Icon.HEAVY_BALLOT_X}');
  } else {
    Console.setBold(true);
    print('Wayback Machine:');
    Console.setBold(false);
    print(waybackResult);
  }
  print('');
  // Google Cache
  if (googleCacheResult == '') {
    print('Google Cache: ${Icon.HEAVY_BALLOT_X}');
  } else {
    Console.setBold(true);
    print('Google Cache:');
    Console.setBold(false);
    print(googleCacheResult);
  }
  print('');
  // Bing Cache
  if (bingCacheResult == '') {
    print('Bing Cache: ${Icon.HEAVY_BALLOT_X}');
  } else {
    Console.setBold(true);
    print('Bing Cache:');
    Console.setBold(false);
    print(bingCacheResult);
  }
  print('');
}

Future<String> checkWayback(String address) async {
  var response = await http.get('http://archive.org/wayback/available?url=' + address);
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    try {
      var url = jsonResponse['archived_snapshots']['closest']['url'].toString();
      return url;
    } catch(err) {
      return '';
    }
  } else {
    return 'Wayback Machine request failed with error: ${response.statusCode}';
  }
}

Future<String> checkGoogleCache(String address) async {
  var cacheAddress = 'http://webcache.googleusercontent.com/search?q=cache:' + address;
  var response = await http.get(cacheAddress);
  if (response.statusCode == 200) {
    var document = parse(response.body);
    var cacheHead = document.querySelector('div[id\$="google-cache-hdr"]');
    if (cacheHead == null) {
      return '';
    } else {
      return cacheAddress;
    }
  } else {
    return 'Google Cache request failed with error: ${response.statusCode}';
  }
}

Future<String> checkBingCache(String address) async {
  var cacheAddress = 'http://www.bing.com/search?q=url:' + Uri.encodeComponent(address);
  // Retrieve English page so the aria label can be matched
  var response = await http.get(cacheAddress + '&setlang=en');
  if (response.statusCode == 200) {
    var html = parse(response.body).outerHtml.toString();
    // Check for a cache link somewhere in the HTML
    if (html.contains('http://cc.bingj.com/cache.aspx')) {
      return cacheAddress;
    } else {
      return '';
    }
  } else {
    return 'Bing Cache request failed with error: ${response.statusCode}';
  }
}

void printSimpleResults(address) async {
  var waybackResult = await checkWayback(address);
  var googleCacheResult = await checkGoogleCache(address);
  var bingCacheResult = await checkBingCache(address);
  // Wayback Machine
  if (waybackResult != '') {
    print(waybackResult);
  }
  // Google Cache
  if (googleCacheResult != '') {
    print(googleCacheResult);
  }
  // Bing Cache
  if (bingCacheResult != '') {
    print(bingCacheResult);
  }
}

void loadCache(String address, args) async {
  if (args['simple'] as bool) {
    printSimpleResults(address);
  } else {
    Console.setBold(true);
    var bar = ProgressBar(complete: 4);
    bar.update(1);
    // Wayback Machine
    var waybackResult = await checkWayback(address);
    bar.update(2);
    // Google Machine
    var googleCacheResult = await checkGoogleCache(address);
    bar.update(3);
    // Bing Cache
    var bingCacheResult = await checkBingCache(address);
    bar.update(4);
    // Print results
    Console.setBold(false);
    printFormattedResults(waybackResult, googleCacheResult, bingCacheResult);
  }
}