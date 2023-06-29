import 'package:flutter/material.dart';

/// A wrapper around change notifier that enables the use of
/// the state view pattern.  It provides an onEvent function
/// to accept events from the UI, a map of emitters which will
/// allow you to tie a change notifier higher in the widget to
/// an event to be emitted on this provider.
///
///
/// Example:
///
/// class HomeState extends StateProvider<Home, HomeEvent> {
///   HomeState(super.context);
///
///   @override
///   void onEvent(HomeEvent event) {
///     return;
///   }
/// }
///
/// OR
///
/// class HomeState extends StateProvider<Home, HomeEvent> {
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
abstract class StateProvider<W extends StatelessWidget, E>
    extends ChangeNotifier {
  final BuildContext context;
  late W widget;
  final Map<ChangeNotifier, void Function()> _listenToCallbacks = {};
  Map<ChangeNotifier, E> emitters;
  StateProvider(
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
    W? ancestor = context.findAncestorWidgetOfExactType<W>();
    if (ancestor == null) {
      throw Exception('No ancestor of type $W found for $runtimeType\n'
          'Make sure that you are following the pattern of StateProvider<Page, Event>()\n'
          'And not using StateProvider<View, Event>()');
    }
    widget = ancestor;
    return;
  }

  void onEvent(E event);

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
