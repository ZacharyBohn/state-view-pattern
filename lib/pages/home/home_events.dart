abstract class HomeEvent {}

class HomeUpdateValue extends HomeEvent {
  String value;
  HomeUpdateValue(this.value);
}

class HomeUpdateOtherValue extends HomeEvent {
  String value;
  HomeUpdateOtherValue(this.value);
}
