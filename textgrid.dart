class TextGrid {
  TextGrid(this.width, int height) : _cells = List.filled(width * height, ' ');
  final List<String> _cells;

  final int width;
  int get height => _cells.length ~/ width;

  void write(int x, int y, String text, { TextStyle style }) {
    assert(x >= 0);
    assert(y >= 0);
    assert(x < width);
    assert(y < height);
    List<String> characters = text.runes.map((int character) => String.fromCharCode(character)).toList();
    if (characters.isEmpty)
      return;
    assert(x + characters.length < width);
    int start = y * width + x;
    if (characters.length == 1) {
      _cells[start] = style != null ? style.wrap(text) : text;
      return;
    }
    if (style != null) {
      _cells[start] = '$style${characters.first}';
      for (int index = 1; index < characters.length - 1; index += 1)
        _cells[start + index] = characters[index];
      _cells[start + characters.length - 1] = '${characters.last}${TextStyle.none}';
    } else {
      for (int index = 0; index < characters.length; index += 1)
        _cells[start + index] = characters[index];
    }
  }

  void draw(int x, int y, TextGrid grid) {
    assert(x >= 0);
    assert(y >= 0);
    assert(x + grid.width <= width);
    assert(y + grid.height <= height);
    for (int sourceY = 0; sourceY < grid.height; sourceY += 1) {
      for (int sourceX = 0; sourceX < grid.width; sourceX += 1) {
        _cells[(y + sourceY) * width + x + sourceX] = grid._cells[sourceY * grid.width + sourceX];
      }
    }
  }

  void drawSingleBox(int boxX, int boxY, int boxWidth, int boxHeight, {TextStyle borderStyle}) {
    drawCustomBox(boxX, boxY, boxWidth, boxHeight, const <String>['┌', '┐', '└', '┘', '─', '│'], borderStyle: borderStyle);
  }
  

  void drawCustomBox(int boxX, int boxY, int boxWidth, int boxHeight, List<String> parts, {TextStyle borderStyle}) {
    assert(parts.length == 6);
    assert(boxWidth >= 2);
    assert(boxHeight >= 2);
    assert(boxX >= 0);
    assert(boxY >= 0);
    assert(boxX + boxWidth <= width);
    assert(boxY + boxHeight <= height);
    write(boxX, boxY, parts[0], style: borderStyle);
    write(boxX + boxWidth - 1, boxY, parts[1], style: borderStyle);
    write(boxX, boxY + boxHeight - 1, parts[2], style: borderStyle);
    write(boxX + boxWidth - 1, boxY + boxHeight - 1, parts[3], style: borderStyle);
    for (int x = boxX + 1; x < boxX + boxWidth - 1; x += 1) {
      write(x, boxY, parts[4], style: borderStyle);
      write(x, boxY + boxHeight - 1, parts[4], style: borderStyle);
    }
    for (int y = boxY + 1; y < boxY + boxHeight - 1; y += 1) {
      write(boxX, y, parts[5], style: borderStyle);
      write(boxX + boxWidth - 1, y, parts[5], style: borderStyle);
    }
  }

  String toString() {
    StringBuffer buffer = StringBuffer();
    for (int y = 0; y < height; y += 1) {
      for (int x = 0; x < width; x += 1) {
        buffer.write(_cells[y * width + x]);
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}

class TextStyle {
  const TextStyle({ this.foreground, this.background });

  static const none = TextStyle();

  final AnsiColor foreground;
  final AnsiColor background;

  String toString() {
    List<String> values = <String>['0'];
    if (foreground != null)
      values.add((30 + foreground.index).toString());
    if (background != null)
      values.add((40 + background.index).toString());
    return '\x1B[${values.join(";")}m';
  }

  String wrap(String value) => '${this}$value$none';
}

enum AnsiColor { black, red, green, yellow, blue, magenta, cyan, white }
