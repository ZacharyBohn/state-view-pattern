import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Example:
///
/// class Home extends StateView<HomeState> {
///  Home({Key? key})
///      : super(
///          key: key,
///          stateBuilder: (context) => HomeState(context),
///          view: Container(),
///        );
/// }
class StateView<T extends StateProvider> extends StatelessWidget {
  final T Function(BuildContext) stateBuilder;
  final Widget view;
  const StateView({
    Key? key,
    required this.stateBuilder,
    required this.view,
  })  : assert(
            // ignore: unnecessary_type_check
            T is! dynamic,
            'Must specify a type.  '
            'Eg. class HomeView extends StateView<HomeState> {}  '
            'instead of class HomeView extends StateView {}'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) => stateBuilder(context),
      child: view,
    );
  }
}

/// Example:
///
/// class HomeState extends StateProvider<HomeEvent> {
///  HomeState(super.context);
///
///  @override
///  void onEvent(HomeEvent event) {
///    return;
///  }
///}
abstract class StateProvider<E> extends ChangeNotifier {
  BuildContext context;
  StateProvider(this.context)
      :
        // ignore: unnecessary_type_check
        assert(E is! dynamic, 'Specify a base event class'),
        super();

  void onEvent(E event);
}

extension Listen on BuildContext {
  /// Used by widgets to listen to changes on a specific value in from
  /// a provider.
  ///
  /// A wrapper around context.select() that simplifies the syntax of
  /// listening to multiple values.
  /// Custom objects will need to override their hashcode function in order
  /// for deep equality to be tested.
  ///
  /// Example:
  ///
  /// context.select<HomeState>(
  ///   (HomeState state) => [
  ///     state.someValue,
  ///     state.someOtherValue,
  ///   ]
  /// );
  void listen<T>(List<dynamic> Function(T state) selector) {
    select<T, int>((T state) {
      return Object.hashAll(selector(state));
    });
    return;
  }
}
