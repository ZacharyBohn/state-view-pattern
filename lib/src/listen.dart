import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension Listen on BuildContext {
  /// Used by widgets to listen to changes for a specific value(s) in
  /// a [StateProvide].  When the listened to state notifies its
  /// listeners, then the listening widget will rebuild, but only for
  /// the values that are being listened to.
  ///
  ///
  /// Example:
  ///
  /// ```dart
  /// context.select<HomeState>(
  ///   (HomeState state) => [
  ///     state.someValue,
  ///     state.someOtherValue,
  ///   ]
  /// );
  /// ```
  ///
  /// Note:
  /// Custom classes will need to override their hashcode function in order
  /// for deep equality to be tested.
  void listen<T>(List<dynamic> Function(T state) selector) {
    select<T, int>((T state) {
      return const DeepCollectionEquality().hash(selector(state));
    });
    return;
  }
}
