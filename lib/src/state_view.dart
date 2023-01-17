import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state_provider.dart';

/// A widget used to build pages.  It will tie together a
/// view widget with a [StateProvider] widget in order to
/// seperate out state logic and UI logic.
///
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
  StateView({
    Key? key,
    required this.stateBuilder,
    required this.view,
  }) : super(key: key) {
    assert(
      T.toString() != 'StateProvider<StatelessWidget, dynamic>',
      'Must specify a type.  '
      'Eg. class HomePage extends StateView<HomeState> {}  '
      'instead of class HomePage extends StateView {}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) => stateBuilder(context),
      child: view,
    );
  }
}
