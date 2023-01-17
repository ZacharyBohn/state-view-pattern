## Overview

State view is a package that provides a few widgets for following the state view pattern.  This is a pattern that strongly seperates app state from UI logic.

## Examples

When writing Flutter apps, it is easy to use a StatefulWidget to contain business logic, business state, and UI logic.  As a project gets larger, have files which are made of 1000's of lines of code becomes unwieldy.  This package provides a pattern of clean seperation between business logic / state and UI logic.

There are 3 components to the state view pattern.
- Page: a widget that glues the state and UI together
- StateProvider: holds business logic and state / responds to UI events
- UI: holds UI logic / emits UI events

Let's look at some examples:

```dart
class HomePage extends StateView<HomeState> {
  HomePage({Key? key})
      : super(
          key: key,
          stateBuilder: (context) => HomeState(context),
          view: HomeView(),
        );
}

class HomeState extends StateProvider<HomePage, HomeEvent> {
  HomeState(super.context);

  @override
  void onEvent(HomeEvent event) {
    return;
  }
}

abstract class HomeEvent {}
```

This consists of a `HomePage` which merely glues together the state and UI.  This is the widget that will be navigated to.
Next is `HomeState` which should hold business logic and business data.  It defines an `onEvent` function which should be its only public member alongside getters.  All UI widgets, when interacting with `HomeState` will exclusively use the `onEvent` function to do so.  This allows an interface of sorts to be defined between business logic and UI.  UI will therefore never mutate business state directly.  Instead of updating a variable directly on the state provider, UI will emit an event based on the UI interaction (ie OnSubmitButtonTapEvent) and call the state providers `onEvent` function (ie `state.onEvent(OnSubmitButtonTapEvent());`).  This will allow the `onEvent` function to be a high level definition for everything that the state provider can do, and it will define exactly when certain functions are called.  This greatly improves readability, especially as an app grows.
Finally, the `HomeView` can be any widget (usually a stateless widget) that will read values from `HomeState` and emit events to it.

## Events

The `HomeState.onEvent` function is typed.  An abstract class should be defined for each `StateProvider` that is created.  This allows an interface to be constructed between the UI and the state provider.  Each event that the UI is able to emit, should be defined as a class that extends the abstract event.  Then, if any data needs to be defined in the event, it can then be placed in one of the event classes.  Let's look at an example:

```dart
abstract class HomeEvent {}

class OnSaveButtonTap extends HomeEvent {}

class OnUserNameChanged extends HomeEvent {
    final String newUsername;
    OnUserNameChanged(this.newUsername);
}
```

Now that the events are defined, let's look at how the UI would use them:

```dart
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<HomeState>();
    return Scaffold(
      body: Column(
        children: [
          TextField(
            onChanged: (String value) {
              state.onEvent(OnUserNameChanged(value));
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              state.onEvent(OnSaveButtonTap());
            },
          ),
        ],
      ),
    );
  }
}
```

Here `HomeState` can be accessed using `context.read<SomeStateProviderHere>()`.  If `HomeView` needed to be rebuilt whenever `HomeState` notified its listeners, then `context.watch<SomeStateProviderHere>()` could be used.

Let's look at one final sample that ties everything together as well as introduces the emitters if we need the `StateProvider` to respond to another `StateProvider` higher in the widget tree.


```dart

class HomePage extends StateView<HomeState> {
  final String initialUsername;
  HomePage({
    Key? key,
    required this.initialUsername,
  }) : super(
          key: key,
          stateBuilder: (context) => HomeState(context),
          view: HomeView(),
        );
}

class HomeState extends StateProvider<HomePage, HomeEvent> {
  HomeState(BuildContext context)
      : super(
          context,
          // if AuthProvider was a ChangeNotifier or StateProvider
          // higher in the widget tree, then whenever it notifies
          // its listeners, then the OnAuthUpdated event will be
          // emitted on this class
          emitters: {
            context.read<AuthProvider>(): OnAuthUpdated(),
          },
        ) {
    // the `widget` variable can be used to access variables
    // defined on the HomePage class.  This is just to avoid
    // having to define parameters multiple times.
    _username = widget.initialUsername;
  }

  late String _username;
  String get username => _username;

  @override
  void onEvent(HomeEvent event) {
    // check which event was emitted and define
    // handlers for each event
    if (event is OnUserNameChanged) {
        // accessing event variables
      _username = event.newUsername;
      notifyListeners();
    }
    if (event is OnSaveButtonTap) {
      // send username to database
    }
    if (event is OnAuthUpdated) {
      // respond to auth event
    }
    return;
  }
}

// base event define for HomeState typing
abstract class HomeEvent {}

class OnSaveButtonTap extends HomeEvent {}

class OnUserNameChanged extends HomeEvent {
  final String newUsername;
  OnUserNameChanged(this.newUsername);
}

class OnAuthUpdated extends HomeEvent {}

/// This would start a new file: home_view.dart
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // watch is used instead of read so that this widget
    // will rebuild when HomeState notifies listeners
    final state = context.watch<HomeState>();
    return Scaffold(
      body: Column(
        children: [
          Text('Current username: ${state.username}'),
          TextField(
            onChanged: (String value) {
                // emitting a UI event with a value
              state.onEvent(OnUserNameChanged(value));
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
                // emitting a UI event
              state.onEvent(OnSaveButtonTap());
            },
          ),
        ],
      ),
    );
  }
}
```