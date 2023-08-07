import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewless_state_provider.dart';

/// A wrapper around change notifier that enables the use of
/// the state view pattern.  It provides an emit function
/// to accept events from the UI, a map of emitters which will
/// allow you to tie a change notifier higher in the widget to
/// an event to be emitted on this provider.
///
///
/// Example:
///
/// ```dart
/// class HomeState extends StateProvider<Home, HomeEvent> {
///   HomeState(super.context) {
///     registerHandler<OnExampleTap>(_handler);
///     return;
///   }
///
///   void _handler(OnExampleTap event) {
///     // handle event
///   }
/// }
/// ```
///
/// OR
///
/// ```dart
/// class HomeState extends StateProvider<Home, HomeEvent> {
///   HomeState(super.context)
///       : super(
///           emitters: {
///             context.read<AuthProvider>(): AuthProviderUpdatedEvent(),
///           },
///         ) {
///     registerHandler<OnExampleTap>(_handler);
///   }
///
///   void _handler(OnExampleTap event) {
///     // handle event
///   }
/// }
/// ```
///
/// This class cannot be used in a [MultiProvider].
/// Use [ViewlessStateProvider] instead.
///
abstract class StateProvider<W extends StatefulWidget, E>
    extends ChangeNotifier {
  final BuildContext context;
  late W widget;
  final Map<ChangeNotifier, void Function()> _listenToCallbacks = {};
  Map<ChangeNotifier, E> emitters;
  void Function()? onDependenciesChanged;
  StateProvider(
    this.context, {
    this.emitters = const {},
    this.onDependenciesChanged,
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
    _updateWidgetReference();
    return;
  }

  /// This method is called by the state_view package in order
  /// to update widget reference and call onDependenciesChanged()
  void dependenciesDidChange() {
    _updateWidgetReference();
    onDependenciesChanged?.call();
    return;
  }

  void _updateWidgetReference() {
    W? ancestor = context.findAncestorWidgetOfExactType<W>();
    if (ancestor == null) {
      throw Exception('No ancestor of type $W found for $runtimeType\n'
          'Make sure that you are following the pattern of StateProvider<Page, Event>()\n'
          'And not using StateProvider<View, Event>()');
    }
    widget = ancestor;
    return;
  }

  /// Sends an event to this state provider.  This function
  /// must be overridden and events must be handled in the
  /// implementation.  Alternatively, use [registerHandler]
  /// and [emit].  [registerHandler] and [emit] are
  /// recommended.
  void onEvent(E event) {}

  // String key is created from Event.toString()
  // or event.runtimeType.toString()
  final Map<String, List<Function>> _handlers = {};

  /// Registers a handler function that will be called whenever
  /// the associated event is emitted using [emit].
  /// This is an alternative to [onEvent].
  /// Multiple handlers can be defined for the same event.  They
  /// will be called in the order in which they were registered.
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
