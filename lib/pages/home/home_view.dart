import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:state_view_pattern/pages/home/some_child_widget.dart';
import 'package:state_view_pattern/state_view.dart';

import '../home.dart';
import 'all_listening_child_widget.dart';
import 'home_events.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);
  final Random random = Random();

  @override
  Widget build(BuildContext context) {
    context.listen<HomeState>((state) => [state.value]);
    String value = context.read<HomeState>().value;

    print('Building HomeView()');

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: SizedBox(
          width: size.width * 0.5,
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                'State View Pattern',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Check the debug console to see which widget are rebuilding.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30),
              const Text(
                'Tapping the button below will rebuild HomeView() and all children widgets.  '
                'This is built into Flutter and cannot be overriden.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  int randomInt = random.nextInt(64000);
                  context.read<HomeState>().onEvent(
                        HomeUpdateValue(randomInt.toString()),
                      );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.amber.shade800,
                  child: Text(
                    'Value: $value',
                  ),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                'Tapping the button below should rebuild only the SomeChildWidget.  '
                'HomeView(), a parent widget, should not be rebuilt.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30),
              SomeChildWidget(),
              const SizedBox(height: 30),
              const AllListeningChildWidget()
            ],
          ),
        ),
      ),
    );
  }
}
