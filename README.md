# An example of the state view pattern

## Goals

- Provide widgets to simplify state management, and encourage the use of clean state management.

## Copy from

The only file that needs to be copied / used from this repo is lib/state_view.dart

## StateView

This will represent a page or a widget that holds a fair amount of complexity.
For simplier widgets, prefer the use of just a stateful widget.  This widget's
purpose is primarly to reduce boiler plate.

```dart
class Home extends StateView<HomeState> {
  Home({Key? key})
      : super(
          key: key,
          stateBuilder: (context) => HomeState(context),
          view: HomeView(),
        );
}
```


## StateProvider

This represents the state for a page.  It holds variables, updates listeners, and responds to events.
Events can be used as an interface between UI and state.  For example, when a submit button is tapped,
then a SubmitButtonTappedEvent can be created, then the state can add logic to respond to that event
speficially, instead of the submit button updating the state directly.

BuildContext is passed into the state provider to provide the state provider the ability to show dialogs,
and navigate as necessary.

```dart
class HomeState extends StateProvider<HomeEvent> {
  HomeState(super.context);


  @override
  void onEvent(HomeEvent event) {
    if (event is HomeUpdateValue) {
      _value = event.value;
      notifyListeners();
    }
    return;
  }



  String _value = 'Original Value';
  String get value => _value;
}
```



## context.listen

Typically, when a provider notifies its listeners, all of the listeners are rebuilt.  The listen() function
will allow widgets to select widget values of a provider that they wish to listen to.  The provider package
already has a function, select(), that allows this.  This function merely simplifies the syntax of listening
to multiple values, without having to make a select() call on each one.

```dart
context.listen<HomeState>((state) => [
          state.value,
          state.otherValue,
        ]);
```

## Events

Events can be defined using a base event (in this case HomeEvent) as an abstract class.  Other event will extend this base class.
The onEvent() function within the state provider can then check the exact type of the incoming event, and respond accordingly.

```dart
abstract class HomeEvent {}

class HomeUpdateValue extends HomeEvent {
  String value;
  HomeUpdateValue(this.value);
}

class HomeUpdateOtherValue extends HomeEvent {
  String value;
  HomeUpdateOtherValue(this.value);
}
```

## File structure

- home.dart (holds the Home widget, and the HomeState widget)
- home (folder)
  - home_view.dart (all the UI logic lives here)
  - home_events.dart
