import 'meeple.dart';

enum MeepleActionKind { move, stop, invalid }
enum Direction {
  // the order of this enum is critical for reverseDirection()
  north, south, northeast, southwest, east, west, southeast, northwest
}

Direction reverseDirection(Direction direction) {
  return Direction.values[direction.index % 2 == 0 ? direction.index + 1 : direction.index - 1];
}

class MeepleAction {
  const MeepleAction(this.kind, [ this.direction ]);
  const MeepleAction.stop() : kind = MeepleActionKind.stop, direction = null;
  const MeepleAction.invalid() : kind = MeepleActionKind.invalid, direction = null;
  const MeepleAction.move(this.direction) : kind = MeepleActionKind.move;

  final MeepleActionKind kind;
  final Direction direction;
}

abstract class Tile {
  bool get isEmpty => true; 
  MeepleAction enterFrom(Meeple meeple, Direction direction);
}

class OctagonTile extends Tile {
  OctagonTile(this._connections, [this._flipped = false]);

  final Map<Direction, Direction> _connections;
  
  bool get flipped => _flipped;
  bool _flipped;

  void flip() {
    assert(!flipped);
    _flipped = true;
  }

  MeepleAction enterFrom(Meeple meeple, Direction direction) => flipped ? MeepleAction.move(_connections[direction]) : MeepleAction.invalid();
  String toString() => "OctagonTile:" + (flipped ? "$_connections" : "face down");
}

class PrintedTile extends Tile {
  PrintedTile(this.from, this.to);

  final Direction from;
  final Direction to;

  MeepleAction enterFrom(Meeple meeple, Direction direction) {
    if (direction == from)
      return MeepleAction.move(to);
    if (direction == to)
      return MeepleAction.move(from);
    return MeepleAction.invalid();
  }
  String toString() => "PrintedTile from $from to $to";
}

abstract class MeepleTile extends Tile{
  Meeple _meeple;

  bool get isEmpty => _meeple == null;

  MeepleAction enterFrom(Meeple meeple, Direction direction) {
    if (isEmpty) {
      _meeple = meeple;
      return const MeepleAction.stop();
    }
    return const MeepleAction.invalid();
  }

  Meeple exit() {
    assert(!isEmpty);
    Meeple result = _meeple;
    _meeple = null;
    return result;
  }
}

class SquareTile extends MeepleTile { 
  String toString() => "A SquareTile" + (isEmpty ? '' : ' with $_meeple');
}

class HomeTile extends MeepleTile {
  HomeTile(this.side) {
    _meeple = Meeple(side);
  }
  int get meepleGoalSide => _meeple?.goal ?? null;
  final int side;

  MeepleAction enterFrom(Meeple meeple, Direction direction) {
    if (meeple.goal == side)
      super.enterFrom(meeple, direction);
    return MeepleAction.invalid();
  }

  String toString() => colors[side] + "'s home" + (isEmpty ? '' : ' with $_meeple'); 
}
