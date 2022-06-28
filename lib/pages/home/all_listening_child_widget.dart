import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:state_view_pattern/state_view.dart';

import '../home.dart';

class AllListeningChildWidget extends StatelessWidget {
  const AllListeningChildWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.listen<HomeState>((state) => [
          state.value,
          state.otherValue,
        ]);
    String value = context.read<HomeState>().value;
    String otherValue = context.read<HomeState>().otherValue;

    print('Building AllListeningChildWidget()');
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.amber.shade800,
      child: Text(
        'Value: $value, otherValue: $otherValue',
      ),
    );
  }
}
