const Map<int, String> colors = {0: "green", 1: "red", 2: "blue", 3: "yellow"};

class Meeple { 
  Meeple(this.home);

  // starting side
  final int home;

  // destination side
  int get goal => home % 2 == 0 ? home + 1 : home - 1;

  String get color => colors[home];

  String toString() => "a $color Meeple";
}
