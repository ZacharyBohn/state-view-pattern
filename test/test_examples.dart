// ignore_for_file: prefer_const_constructors_in_immutables, avoid_unnecessary_containers, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:state_view/state_view.dart';

main() => runApp(
      MaterialApp(
        home: HomePage(initialUsername: 'test_username'),
      ),
    );

class HomePage extends StateView<HomeState> {
  final String initialUsername;
  HomePage({
    Key? key,
    required this.initialUsername,
  }) : super(
          key: key,
          stateBuilder: (context) => HomeState(context),
          view: const HomeView(),
        );
}

class HomeState extends StateProvider<HomePage, HomeEvent> {
  HomeState(BuildContext context) : super(context) {
    _username = widget.initialUsername;
  }

  late String _username;
  String get username => _username;

  @override
  void onEvent(HomeEvent event) {
    if (event is OnUserNameChanged) {
      _username = event.newUsername;
      notifyListeners();
    }
    return;
  }
}

abstract class HomeEvent {}

class OnUserNameChanged extends HomeEvent {
  final String newUsername;
  OnUserNameChanged(this.newUsername);
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeState>();
    return Scaffold(
      body: Column(
        children: [
          Text('Current username: ${state.username}'),
          TextField(
            onChanged: (String value) {
              state.onEvent(OnUserNameChanged(value));
            },
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StateView {
  SettingsPage({
    Key? key,
  }) : super(
          key: key,
          stateBuilder: (context) => HomeState(context),
          view: Container(),
        );
}

class DependenciesChangeExampleHolder extends StatefulWidget {
  const DependenciesChangeExampleHolder({super.key});

  @override
  State<DependenciesChangeExampleHolder> createState() =>
      _DependenciesChangeExampleHolderState();
}

class _DependenciesChangeExampleHolderState
    extends State<DependenciesChangeExampleHolder> {
  String value = 'init';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DependenciesChangeExampleButton(
          () {
            setState(() {
              value = 'new-value';
            });
          },
        ),
        DependenciesChangedExample(value: value),
      ],
    );
  }
}

class DependenciesChangeExampleButton extends StatelessWidget {
  final void Function() onTap;
  const DependenciesChangeExampleButton(this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text('Change Value'),
    );
  }
}

class DependenciesChangedExample
    extends StateView<DependenciesChangedExampleState> {
  final String value;
  DependenciesChangedExample({Key? key, required this.value})
      : super(
          key: key,
          stateBuilder: (context) => DependenciesChangedExampleState(context),
          view: const DependenciesChangedExampleView(),
        );
}

class DependenciesChangedExampleState extends StateProvider<
    DependenciesChangedExample, DependenciesChangedExampleEvent> {
  DependenciesChangedExampleState(super.context) {
    value = widget.value;
    onDependenciesChanged = () {
      onEvent(OnValueUpdated());
    };
    return;
  }

  late String value;

  @override
  void onEvent(DependenciesChangedExampleEvent event) {
    if (event is OnValueUpdated) {
      value = widget.value;
      notifyListeners();
    }
    return;
  }
}

abstract class DependenciesChangedExampleEvent {}

class OnValueUpdated extends DependenciesChangedExampleEvent {}

class DependenciesChangedExampleView extends StatelessWidget {
  const DependenciesChangedExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DependenciesChangedExampleState>();
    return Center(
      child: Text(state.value),
    );
  }
}

class RegisterHandlerPage extends StateView<RegisterHandlerState> {
  RegisterHandlerPage({
    super.key,
  }) : super(
          stateBuilder: (context) => RegisterHandlerState(context),
          view: RegisterHandlerView(),
        );
}

class RegisterHandlerState
    extends StateProvider<RegisterHandlerPage, RegisterHandlerEvent> {
  RegisterHandlerState(super.context) {
    registerHandler<OnTap>(_onTapHandler);
    registerHandler<OnTap2>(_onTap2Handler);
    return;
  }

  String value = 'Tap Here';
  String value2 = 'Value 2';

  void _onTapHandler(OnTap event) {
    value = 'Tapped';
    notifyListeners();
    return;
  }

  // should not be called during test
  void _onTap2Handler(OnTap2 event) {
    value2 = 'Removed';
    notifyListeners();
    return;
  }
}

abstract class RegisterHandlerEvent {}

class OnTap extends RegisterHandlerEvent {}

class OnTap2 extends RegisterHandlerEvent {}

class RegisterHandlerView extends StatelessWidget {
  RegisterHandlerView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RegisterHandlerState>();
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              state.emit(OnTap());
            },
            child: Text(state.value),
          ),
          GestureDetector(
            onTap: () {
              state.emit(OnTap2());
            },
            child: Text(state.value2),
          ),
        ],
      ),
    );
  }
}
