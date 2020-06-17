import 'tiles.dart';

class TileLocation {
  const TileLocation(this.x, this.y);
  final int x; 
  final int y; 
}

abstract class Board {
  Board();
  
  int get sides;
  
  OctagonTile get activeTile => _activeTile;
  OctagonTile _activeTile;
  
  void replaceTileAt(TileLocation location);
  
  Tile findTileAt(TileLocation location);
  
  Tile findConnectingTile(Tile from, Direction direction);
  
  bool get won {
    outer: for(int i = 0; i < sides; i++) {
      Set<HomeTile> homes = homeTiles(i);
      for (HomeTile home in homes) {
        if (home.meepleGoalSide != i) {
          continue outer;
        }
      }
      return true;
    }
    return false;
  }

  Set<HomeTile> homeTiles(int side);
}

class DefaultBoard extends Board {
  final int sides = 4;
  OctagonTile _activeTile = OctagonTile({Direction.north: Direction.south, Direction.south: Direction.north, Direction.east: Direction.north, Direction.west: Direction.south}, true);
  List<List<Tile>> tiles = [
    [null, HomeTile(0), null],
    [HomeTile(3), OctagonTile({Direction.north: Direction.north, Direction.south: Direction.south, Direction.east: Direction.west, Direction.west: Direction.east}), HomeTile(2)],
    [null, HomeTile(1), null],
  ];
  Set<HomeTile> homeTiles(int side) {
    var flattened = tiles.expand((row) => row).toList();
    return flattened.where((Tile tile) => tile is HomeTile && tile.side == side).toSet().cast<HomeTile>();
  }
  Tile findTileAt(TileLocation at) {
    return tiles[at.y][at.x];
  }

  void replaceTileAt(TileLocation at) {
    var newy = tiles[at.y][at.x];
    (newy as OctagonTile).flip();
    tiles[at.y][at.x] = activeTile;
    _activeTile = newy;
  }

  Tile findConnectingTile(Tile tile, Direction dir) {
    var y = tiles.indexWhere((List<Tile> row) => row.contains(tile));
    var x = tiles.firstWhere((List<Tile> row) => row.contains(tile)).indexWhere((Tile tiley) => tiley == tile);
    print("Got ${tiles[y][x]}($x, $y)");
    var byx;
    var byy;
    switch(dir) {
      case Direction.north:
      case Direction.northwest:
      case Direction.northeast:
        byy = -1;
        break;
      case Direction.south:
      case Direction.southwest:
      case Direction.southeast:
        byy = 1;
        break;
      default:
        byy = 0;
    }
    switch(dir) {
      case Direction.west:
      case Direction.northwest:
      case Direction.southwest:
        byx = -1;
        break;
      case Direction.east:
      case Direction.northeast:
      case Direction.southeast:
        byx = 1;
        break;
      default:
        byx = 0;
    }
    print("plus ($byx, $byy)");
    return tiles[y + byy][x + byx];
  }
}