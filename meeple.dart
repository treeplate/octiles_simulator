import 'textgrid.dart';
const Map<int, String> colorsAsString = {0: "green", 1: "red", 2: "blue", 3: "yellow"};
const Map<int, AnsiColor> colorsAsAnsi = {0: AnsiColor.green, 1: AnsiColor.red, 2: AnsiColor.blue, 3: AnsiColor.yellow};

class Meeple { 
  Meeple(this.home);

  // starting side
  final int home;

  // destination side
  int get goal => home % 2 == 0 ? home + 1 : home - 1;

  String get color => colorsAsString[home];

  String toString() => "a $color Meeple";
}
