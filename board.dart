import 'tiles.dart';
import 'textgrid.dart';

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

  String draw();
}

class GridBoard extends Board {
  final int sides = 4;

  static OctagonTile get flowerTile => OctagonTile({
    Direction.north: Direction.south,
    Direction.south: Direction.north,
    Direction.east: Direction.west,
    Direction.west: Direction.east,
  });

  static OctagonTile get crossTile => OctagonTile({
    Direction.north: Direction.north,
    Direction.south: Direction.south,
    Direction.east: Direction.west,
    Direction.west: Direction.east,
  });

  OctagonTile _activeTile = flowerTile..flip();

  List<List<Tile>> tiles = [
    [null, HomeTile(0), null],
    [HomeTile(3), crossTile, HomeTile(2)],
    [null, HomeTile(1), null],
  ];

  Set<HomeTile> homeTiles(int side) {
    return tiles
      .expand((row) => row)
      .whereType<HomeTile>()
      .where((HomeTile tile) => tile.side == side)
      .toSet();
  }
  
  Tile findTileAt(TileLocation at) {
    return tiles[at.y][at.x];
  }

  void replaceTileAt(TileLocation at) {
    var newTile = tiles[at.y][at.x];
    (newTile as OctagonTile).flip();
    tiles[at.y][at.x] = activeTile;
    _activeTile = newTile;
  }

  Tile findConnectingTile(Tile tile, Direction dir) {
    var y = tiles.indexWhere((List<Tile> row) => row.contains(tile));
    var x = tiles.firstWhere((List<Tile> row) => row.contains(tile)).indexWhere((Tile tiley) => tiley == tile);
    //print("Got ${tiles[y][x]}($x, $y)");
    var deltaX;
    var deltaY;
    switch (dir) {
      case Direction.north:
      //case Direction.northwest:
      //case Direction.northeast:
        deltaY = -1;
        break;
      case Direction.south:
      //case Direction.southwest:
      //case Direction.southeast:
        deltaY = 1;
        break;
      default:
        deltaY = 0;
    }
    switch (dir) {
      case Direction.west:
      //case Direction.northwest:
      //case Direction.southwest:
        deltaX = -1;
        break;
      case Direction.east:
      //case Direction.northeast:
      //case Direction.southeast:
        deltaX = 1;
        break;
      default:
        deltaX = 0;
    }
    if (x == 0) {
      if (deltaY != 0 || deltaX != 1)
        return null;
    } else if (x == tiles[y].length - 1) {
      if (deltaY != 0 || deltaX != -1)
        return null;
    }
    if (y == 0) {
      if (deltaX != 0 || deltaY != 1)
        return null;
    } else if (y == tiles.length - 1) {
      if (deltaX != 0 || deltaY != -1)
        return null;
    }
    //print("plus ($deltaX, $deltaY)");
    return tiles[y + deltaY][x + deltaX];
  }

  String draw() {
    const int dim = 9;
    TextGrid screen = TextGrid(tiles.first.length * dim, tiles.length * dim);
    for (int y = 0; y < tiles.length; y += 1) {
      for (int x = 0; x < tiles[y].length; x += 1) {
        if (tiles[y][x] == null)
          continue;
        Set<Direction> connections = Direction.values.toSet();
        if (y == 0)
          connections.remove(Direction.north);
        else if (y == tiles.length - 1)
          connections.remove(Direction.south);
        if (x == 0)
          connections.remove(Direction.east);
        else if (x == tiles[y].length - 1)
          connections.remove(Direction.west);
        screen.draw(x * dim, y * dim, tiles[y][x].draw(9, connections));
      }
    }
    return "$screen";
  }
}