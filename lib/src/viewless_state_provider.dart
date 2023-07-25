import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A wrapper around change notifier that enables the use of
/// the state view pattern.  It provides an onEvent function,
/// a map of emitters which will
/// allow you to tie a change notifier higher in the widget to
/// an event to be emitted on this provider.
///
/// This is very similiar to the StateProvider except this
/// class can be used in a [MultiProvider]
///
///
/// Example:
///
/// ```dart
/// class HomeState extends ViewlessStateProvider<HomeEvent> {
///   HomeState(super.context);
///
///   @override
///   void onEvent(HomeEvent event) {
///     return;
///   }
/// }
/// ```
///
/// OR
///
/// ```dart
/// class HomeState extends ViewlessStateProvider<HomeEvent> {
///   HomeState(super.context)
///       : super(
///           emitters: {
///             context.read<AuthProvider>(): AuthProviderUpdatedEvent(),
///           },
///         );
///
///   @override
///   void onEvent(HomeEvent event) {
///     return;
///   }
/// }
/// ```
abstract class ViewlessStateProvider<E> extends ChangeNotifier {
  final BuildContext context;
  final Map<ChangeNotifier, void Function()> _listenToCallbacks = {};
  Map<ChangeNotifier, E> emitters;
  ViewlessStateProvider(
    this.context, {
    this.emitters = const {},
  }) : super() {
    assert(E.runtimeType != dynamic, 'Specify a base event class');
    for (MapEntry entry in emitters.entries) {
      ChangeNotifier provider = entry.key;
      E event = entry.value;
      // ignore: prefer_function_declarations_over_variables
      void Function() callback = () => onEvent(event);
      _listenToCallbacks[provider] = callback;
      provider.addListener(callback);
    }
    return;
  }

  /// Sends an event to this state provider.  This function
  /// must be overriden and events must be handled in the
  /// implementation.  Alternatively, use [registerHandler]
  /// and [emit].  [registerHandler] and [emit] are part of
  /// the recommend pattern
  void onEvent(E event) {}

  // String key is created from Event.toString()
  // or event.runtimeType.toString()
  final Map<String, List<Function>> _handlers = {};

  /// Registers a handler function that will be called whenever
  /// the associated event is emitted using [emit].
  /// This is an alternative to [onEvent]
  void registerHandler<EE extends E>(Function(EE) handler) {
    var key = EE.toString();
    if (key == 'dynamic') {
      throw Exception('Must specify a type when registering a handler.\n'
          'Example: registerHandler<OnTapLogout>(_logoutHandler)');
    }
    _handlers.putIfAbsent(key, () => []);
    _handlers[key]!.add(handler);
    return;
  }

  /// Used to emit an event, which is then sent to
  /// a handler function that was registered using
  /// [registerHandler]
  void emit(E event) {
    var key = event.runtimeType.toString();
    if (!_handlers.containsKey(key) || _handlers[key]!.isEmpty) {
      throw Exception('No handlers are registered for event: $E');
    }
    for (var handler in _handlers[key]!) {
      handler(event);
    }
    return;
  }

  bool get mounted => _mounted;
  bool _mounted = true;

  @override
  void dispose() {
    for (MapEntry entry in emitters.entries) {
      ChangeNotifier provider = entry.key;
      provider.removeListener(_listenToCallbacks[provider]!);
    }
    _mounted = false;
    super.dispose();
    return;
  }

  @override
  void notifyListeners() {
    if (mounted) {
      super.notifyListeners();
    }
    return;
  }
}
