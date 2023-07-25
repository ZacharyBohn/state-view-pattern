void main() {
  var x = Test();
  x.test();
  return;
}

abstract class X {}

class Test<T> {
  Test() {
    print('${T.runtimeType}');
    return;
  }
  void test<Y extends T>() {
    print('got type: $X');
    print('${Y}');
    return;
  }
}
