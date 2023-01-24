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
