import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:state_view_pattern/state_view.dart';

import '../home.dart';
import 'home_events.dart';

class SomeChildWidget extends StatelessWidget {
  SomeChildWidget({Key? key}) : super(key: key);
  final Random random = Random();

  @override
  Widget build(BuildContext context) {
    context.listen<HomeState>((state) => [state.otherValue]);
    String otherValue = context.read<HomeState>().otherValue;

    print('Building SomeChildWidget()');
    return GestureDetector(
      onTap: () {
        int randomInt = random.nextInt(64000);
        context.read<HomeState>().onEvent(
              HomeUpdateOtherValue(randomInt.toString()),
            );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.amber.shade800,
        child: Text(
          'Value: $otherValue',
        ),
      ),
    );
  }
}
