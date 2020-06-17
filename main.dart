import 'dart:io';

import 'meeple.dart';
import 'board.dart';
import 'tiles.dart';

void main() {
	Board board = DefaultBoard();
  int currentPlayer = 0;
  while (!board.won) {
    print('Current player: $currentPlayer (${colors[currentPlayer]})');
    print('Board:');
    showBoard(board);
    print('Active tile:');
    showTile(board.activeTile);
    print('Select tile to replace: ');
    TileLocation tilePosition = readTilePosition();
    board.replaceTileAt(tilePosition);
    print('Select tile with meeple to move: ');
    TileLocation meeplePosition = readTilePosition();
    Tile sourceTile = board.findTileAt(meeplePosition);
    Direction meepleDirection = readDirection('Select direction to move in');
    if (sourceTile is MeepleTile && !(sourceTile as MeepleTile).isEmpty) {
      Meeple meeple = (sourceTile as MeepleTile).exit();
      Tile tile = sourceTile;
      tile = board.findConnectingTile(tile, meepleDirection);
      loop: while (true) {
        MeepleAction action = tile.enterFrom(meeple, reverseDirection(meepleDirection));
        switch (action.kind) {
          case MeepleActionKind.move:
            print("moving");
            tile = board.findConnectingTile(tile, action.direction);
            meepleDirection = action.direction;
            break;
          case MeepleActionKind.stop:
            break loop;
          case MeepleActionKind.invalid:
            // TODO: handle this better
            print("Invalid move (says ${tile}). Your meeple is now dead.");
            break loop;
        }
      }
    } else {
      // TODO: handle this better
      print('There is no meeple there. You have now cheated.');
    }
    currentPlayer=(currentPlayer + 1) % 4;
  }
  print("Done.");
}

void showBoard(Board board) {
  //TODO: prettier board
  print((board as DefaultBoard).tiles);
}

void showTile(Tile tile) {
  //TODO: prettier tile
  print(tile);
}

TileLocation readTilePosition() {
  print("Tile x:");
  int x = int.parse(stdin.readLineSync());
  print("Tile y:");
  int y = int.parse(stdin.readLineSync());
  return TileLocation(x, y);
}

Direction readDirection(String message) {
  while (true) {
    print('$message (n/ne/e/se/s/sw/w/nw)? ');
    String input = stdin.readLineSync();
    switch (input) {
      case 'n': return Direction.north;
      case 'ne': return Direction.northeast;
      case 'e': return Direction.east;
      case 'se': return Direction.southeast;
      case 's': return Direction.south;
      case 'sw': return Direction.southwest;
      case 'w': return Direction.west;
      case 'nw': return Direction.northwest;
    }
  }
}