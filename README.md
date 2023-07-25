# State View Package

State View is a Dart package that offers a set of widgets and patterns for implementing the state view pattern in Flutter apps. This pattern aims to separate the application state from UI logic, making code organization cleaner and more maintainable.

## Installation

To use the State View package, you first need to add the package to your Flutter project:

```bash
dart pub add state_view
```

### Install Create Page Script

To use the State View package's create page scrpit, you first need to activate the script on your system. Open your terminal and run the following command:

```zsh
dart pub global activate state_view
```

Make sure to add Dart package executables to your system path. On MacOS / Linux, you can achieve this by adding the following line to your ~/.zshrc file (assuming zsh is the default shell):

```zsh
export PATH="$PATH:~/.pub-cache/bin"
```

On Windows you can achieve this by adding this to your user's PATH environment variable:

```cmd
%LOCALAPPDATA%\Pub\Cache\bin
```

## Creating a Page

The state view pattern requires a certain amount of boilerplate code. To streamline this process, the package provides a script that automatically creates the necessary files and folders for a new page.

To create a new page, navigate to the folder where you want to create it (e.g., /lib/pages/) and run the script, providing the name of the page in snake case:

```zsh
create_page some_new_page
```

The script will automatically convert the page name to Pascal case for the actual class names.

## Examples

As Flutter apps grow, using a StatefulWidget for managing business logic, state, and UI logic in a single file can become unwieldy. The State View package addresses this by offering a clean separation between business logic/state and UI logic.

There are three main components to the state view pattern:

-   Page: A widget that glues the state and UI together.
-   StateProvider: Holds business logic and state, and responds to UI events.
-   UI: Holds UI logic and emits UI events.

### Code Example

Let's see an example of how to use these components:

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
  HomeState(super.context) {
    registerHandler<OnSaveButtonTap>(_handleLogin);
    return;
  }

  void _handleSave(OnSaveButtonTap event) {
    // TODO: handle login
  }
}

abstract class HomeEvent {}

class OnSaveButtonTap extends HomeEvent {}
```

In this example, HomePage acts as the glue between HomeState (business logic) and HomeView (UI). HomeState registers one or more handlers for each event, which serves as an interface between the business logic and UI. UI widgets would interact with HomeState by calling emit and emitting specific events. This separation enhances readability and maintainability as the app scales.

## Events

To keep the HomeState.emit function typed, it's recommended to define an abstract class for each StateProvider you create. Each UI event should be represented as a class extending this abstract event class. You can also include any necessary data in these event classes.

For example:

```dart
abstract class HomeEvent {}

class OnSaveButtonTap extends HomeEvent {}

class OnUserNameChanged extends HomeEvent {
    final String newUsername;
    OnUserNameChanged(this.newUsername);
}
```

Here's how the UI would use these events:

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
              state.emit(OnUserNameChanged(value));
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              state.emit(OnSaveButtonTap());
            },
          ),
        ],
      ),
    );
  }
}
```

### onEvent

Alternatively, you can override the onEvent function in the state provider, and just call onEvent to provide events to the state provider.

Here's an example:

```dart
class HomeState extends StateProvider<HomePage, HomeEvent> {
  HomeState(super.context);

  @override
  void onEvent() {
    if (event is OnSaveButtonTap) {
      _handleSave(event);
    }
    return;
  }

  void _handleSave(OnSaveButtonTap event) {
    // TODO: handle login
  }
}
```

Then, from the UI you would call:

```dart
context.read<HomeState>().onEvent(OnSaveButtonTap());
```

This is an older method to emit events, and is not recommended since extra logic tends to be added to the onEvent function, aside from just asigning handlers. But this is functionally the same as the registerHandler / emit pattern.

## MultiProvider

The StateProvider widget cannot be used directly within a MultiProvider. However, you can use the ViewlessStateProvider, which is nearly identical but can be used in a MultiProvider.

Note: The rest of the documentation contains additional examples and explanations of how to use the State View package effectively. For further details, please refer to the actual package files.
