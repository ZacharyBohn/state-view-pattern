// ignore_for_file: avoid_print

import 'dart:io';

/// Creates the necessary files to the state view pattern
/// within their own folder on the current working directory
///
/// Takes 1 posisitonal argument: name
/// name will be used to construct the folder / files
void main(List<String> args) {
  if (args.isEmpty) {
    print('error: must specify a name for the file');
    return;
  }
  createPage(args[0]);
  print('files created for: ${args[0]}');
  return;
}

Future<void> createPage(String name) async {
  // create files
  var mainFile = await File('$name/$name.dart').create(recursive: true);
  var viewFile = await File('$name/${name}_view.dart').create(recursive: true);
  var eventsFile =
      await File('$name/${name}_events.dart').create(recursive: true);

  // write contents
  var mainFileFuture = writeToFile(
    mainFile,
    createPageFile(name),
  );
  var viewFileFuture = writeToFile(
    viewFile,
    createViewFile(name),
  );
  var eventsFileFuture = writeToFile(
    eventsFile,
    createEventsFile(name),
  );

  await Future.wait([
    mainFileFuture,
    viewFileFuture,
    eventsFileFuture,
  ]);
  return;
}

Future<void> writeToFile(File file, String contents) async {
  var sink = file.openWrite();
  sink.write(contents);
  await sink.close();
  return;
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}

String createPageFile(String name) {
  String nameCapitalized = name.toCapitalized();
  return '''import 'package:flutter/material.dart';
import 'package:state_view/state_view.dart';
import '${name}_view.dart';
import '${name}_events.dart';
export '${name}_events.dart';

class $nameCapitalized extends StateView<${nameCapitalized}State> {
  $nameCapitalized({Key? key})
      : super(
          key: key,
          stateBuilder: (context) => ${nameCapitalized}State(context),
          view: ${nameCapitalized}View(),
        );
}
class ${nameCapitalized}State extends StateProvider<$nameCapitalized, ${nameCapitalized}Event> {
  ${nameCapitalized}State(super.context);
  @override
  void onEvent(${nameCapitalized}Event event) {
  }
}
''';
}

String createEventsFile(String name) {
  String nameCapitalized = name.toCapitalized();
  return '''abstract class ${nameCapitalized}Event {}

class OnExampleTap extends ${nameCapitalized}Event {}
''';
}

String createViewFile(String name) {
  String nameCapitalized = name.toCapitalized();
  return '''import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '$name.dart';

class ${nameCapitalized}View extends StatelessWidget {
  const ${nameCapitalized}View({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final state = context.watch<${nameCapitalized}State>();
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.blue,
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
''';
}
