import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:state_view_pattern/pages/home/home_view.dart';
import 'package:state_view_pattern/state_view.dart';

import 'home/home_events.dart';

class Home extends StateView<HomeState> {
  Home({Key? key})
      : super(
          key: key,
          stateBuilder: (context) => HomeState(context),
          view: HomeView(),
        );
}

class HomeState extends StateProvider<HomeEvent> {
  final Random random = Random();
  Timer? timer;
  HomeState(super.context) {
    // create a timer to update dontListenToValue
    // and notifyListeners() constantly, to prove that
    // children widgets only rebuild on the values that they
    // are listening to
    timer = Timer.periodic(const Duration(microseconds: 200), (_) {
      dontListenToValue = random.nextInt(64000);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void onEvent(HomeEvent event) {
    if (event is HomeUpdateValue) {
      _value = event.value;
      notifyListeners();
    }
    if (event is HomeUpdateOtherValue) {
      _otherValue = event.value;
      notifyListeners();
    }
    return;
  }

  Future<void> constantlyUpdateListenable() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return;
  }

  int dontListenToValue = 0;

  String _value = 'Original Value';
  String get value => _value;

  String _otherValue = 'Original Other Value';
  String get otherValue => _otherValue;
}
