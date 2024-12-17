import 'dart:math';

import 'package:chess/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameBoard(),
    );
  }
}

bool isWhite(int index) {
  int x = index ~/ 8;
  int y = index % 8;
  bool isWhite = (x + y) % 2 == 0;
  return isWhite;
}

bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}

class Square extends StatelessWidget {
  final ChessPiece? piece;
  final bool isWhite;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  const Square(
      {super.key,
      required this.isWhite,
      required this.piece,
      required this.isSelected,
      required this.onTap,
      required this.isValidMove});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    if (isSelected) {
      squareColor = Colors.green;
    } else if (isValidMove) {
      squareColor = Colors.green[300];
    } else {
      squareColor = isWhite ? Colors.grey[400] : Colors.grey[600];
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(isValidMove ? 8 : 0),
        color: squareColor,
        child: piece != null
            ? Image.asset((piece!.isWhite == true)
                ? piece!.imagePathWhite
                : piece!.imagePathBlack)
            : null,
      ),
    );
  }
}

enum ChessPieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  final String imagePathWhite;
  final String imagePathBlack;
  bool hasMoved;

  ChessPiece(
      {required this.imagePathBlack,
      required this.imagePathWhite,
      required this.isWhite,
      required this.type,
      this.hasMoved = false});
}

class DeadPiece extends StatelessWidget {
  final String imagePathBlack;
  final String imagePathWhite;
  final bool isWhite;
  const DeadPiece(
      {super.key,
      required this.imagePathBlack,
      required this.imagePathWhite,
      required this.isWhite});

  @override
  Widget build(BuildContext context) {
    return Image.asset(isWhite ? imagePathWhite : imagePathBlack);
  }
}

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  List<List<int>> validMoves = [];
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];
  bool isWhiteTurn = true;
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initalizeBoard();
  }

  void _initalizeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    //place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          imagePathBlack: "assets/black-pawn.png",
          imagePathWhite: "assets/white-pawn.png",
          isWhite: false,
          type: ChessPieceType.pawn);
      newBoard[6][i] = ChessPiece(
          imagePathBlack: "assets/black-pawn.png",
          imagePathWhite: "assets/white-pawn.png",
          isWhite: true,
          type: ChessPieceType.pawn);
    }

    //Place rooks

    newBoard[0][0] = ChessPiece(
        imagePathBlack: "assets/black-rook.png",
        imagePathWhite: "assets/white-rook.png",
        isWhite: false,
        type: ChessPieceType.rook);
    newBoard[0][7] = ChessPiece(
        imagePathBlack: "assets/black-rook.png",
        imagePathWhite: "assets/white-rook.png",
        isWhite: false,
        type: ChessPieceType.rook);
    newBoard[7][0] = ChessPiece(
        imagePathBlack: "assets/black-rook.png",
        imagePathWhite: "assets/white-rook.png",
        isWhite: true,
        type: ChessPieceType.rook);
    newBoard[7][7] = ChessPiece(
        imagePathBlack: "assets/black-rook.png",
        imagePathWhite: "assets/white-rook.png",
        isWhite: true,
        type: ChessPieceType.rook);

    //place knights

    newBoard[0][1] = ChessPiece(
        imagePathBlack: "assets/black-knight.png",
        imagePathWhite: "assets/white-knight.png",
        isWhite: false,
        type: ChessPieceType.knight);
    newBoard[0][6] = ChessPiece(
        imagePathBlack: "assets/black-knight.png",
        imagePathWhite: "assets/white-knight.png",
        isWhite: false,
        type: ChessPieceType.knight);
    newBoard[7][1] = ChessPiece(
        imagePathBlack: "assets/black-knight.png",
        imagePathWhite: "assets/white-knight.png",
        isWhite: true,
        type: ChessPieceType.knight);
    newBoard[7][6] = ChessPiece(
        imagePathBlack: "assets/black-knight.png",
        imagePathWhite: "assets/white-knight.png",
        isWhite: true,
        type: ChessPieceType.knight);

    //place bishops
    newBoard[0][2] = ChessPiece(
        imagePathBlack: "assets/black-bishop.png",
        imagePathWhite: "assets/white-bishop.png",
        isWhite: false,
        type: ChessPieceType.bishop);
    newBoard[0][5] = ChessPiece(
        imagePathBlack: "assets/black-bishop.png",
        imagePathWhite: "assets/white-bishop.png",
        isWhite: false,
        type: ChessPieceType.bishop);
    newBoard[7][2] = ChessPiece(
        imagePathBlack: "assets/black-bishop.png",
        imagePathWhite: "assets/white-bishop.png",
        isWhite: true,
        type: ChessPieceType.bishop);
    newBoard[7][5] = ChessPiece(
        imagePathBlack: "assets/black-bishop.png",
        imagePathWhite: "assets/white-bishop.png",
        isWhite: true,
        type: ChessPieceType.bishop);

    //place queens

    newBoard[0][3] = ChessPiece(
        imagePathBlack: "assets/black-queen.png",
        imagePathWhite: "assets/white-queen.png",
        isWhite: false,
        type: ChessPieceType.queen);
    newBoard[7][3] = ChessPiece(
        imagePathBlack: "assets/black-queen.png",
        imagePathWhite: "assets/white-queen.png",
        isWhite: true,
        type: ChessPieceType.queen);

    //place kings

    newBoard[0][4] = ChessPiece(
        imagePathBlack: "assets/black-king.png",
        imagePathWhite: "assets/white-king.png",
        isWhite: false,
        type: ChessPieceType.king);

    newBoard[7][4] = ChessPiece(
        imagePathBlack: "assets/black-king.png",
        imagePathWhite: "assets/white-king.png",
        isWhite: true,
        type: ChessPieceType.king);

    board = newBoard;
  }

  List<Move> generateMoves(List<List<ChessPiece?>> board, bool isWhiteTurn) {
    List<Move> moves = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece != null && piece.isWhite == isWhiteTurn) {
          List<Move> pieceMoves = [];
          switch (piece.type) {
            case ChessPieceType.pawn:
              _generatePawnMoves(pieceMoves, board, row, col, piece.isWhite);
              break;
            case ChessPieceType.knight:
              _generateKnightMoves(pieceMoves, board, row, col, piece.isWhite);
              break;
            case ChessPieceType.bishop:
              _generateBishopMoves(pieceMoves, board, row, col, piece.isWhite);
              break;
            case ChessPieceType.rook:
              _generateRookMoves(pieceMoves, board, row, col, piece.isWhite);
              break;
            case ChessPieceType.queen:
              _generateQueenMoves(pieceMoves, board, row, col, piece.isWhite);
              break;
            case ChessPieceType.king:
              _generateKingMoves(pieceMoves, board, row, col, piece.isWhite);
              break;
          }
          for (var move in pieceMoves) {
            if (_isMoveLegal(board, move, isWhiteTurn)) {
              moves.add(move);
            }
          }
        }
      }
    }
    return moves;
  }

  Move? findBestMove(
      List<List<ChessPiece?>> board, int depth, bool isWhiteTurn) {
    Move? bestMove;
    int bestValue = isWhiteTurn ? -99999 : 99999;

    for (var move in generateMoves(board, isWhiteTurn)) {
      final newBoard = applyMove(board, move);
      final boardValue = minimax(newBoard, depth - 1, !isWhiteTurn);

      if (isWhiteTurn && boardValue > bestValue) {
        bestValue = boardValue;
        bestMove = move;
      } else if (!isWhiteTurn && boardValue < bestValue) {
        bestValue = boardValue;
        bestMove = move;
      }
    }

    if (bestMove == null) {
      if (findBestMove(board, depth - 1, isWhiteTurn) != null && depth != 0) {
        if (findBestMove(board, depth - 1, isWhiteTurn) != null && depth != 0) {
          if (findBestMove(board, depth - 1, isWhiteTurn) != null &&
              depth != 0) {
            if (findBestMove(board, depth - 1, isWhiteTurn) != null &&
                depth != 0) {
              return findBestMove(board, depth - 1, isWhiteTurn);
            }
            return findBestMove(board, depth - 1, isWhiteTurn);
          }
          return findBestMove(board, depth - 1, isWhiteTurn);
        }

        return findBestMove(board, depth - 1, isWhiteTurn);
      }
    }
    return bestMove;
  }

  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }
      validMoves = calculateRealValidMoves(
          selectedRow, selectedCol, selectedPiece, true);
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];
    if (piece == null) {
      return [];
    }
    int direction = piece!.isWhite ? -1 : 1;
    switch (piece.type) {
      case ChessPieceType.pawn:
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1]
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
        var directions = [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];
        if (longRokCheck()) {
          directions.add([0, -2]);
        }
        if (shortRokCheck()) {
          directions.add([0, 2]);
        }
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      default:
    }
    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }
    if (selectedCol == 4 &&
        selectedRow == 7 &&
        selectedPiece?.type == ChessPieceType.king &&
        selectedPiece?.hasMoved == false &&
        newRow == 7 &&
        newCol == 6) {
      board[7][5] = ChessPiece(
          imagePathBlack: "assets/black-rook.png",
          imagePathWhite: "assets/white-rook.png",
          isWhite: true,
          type: ChessPieceType.rook);
      board[7][7] = null;
    }

    if (selectedCol == 4 &&
        selectedRow == 7 &&
        selectedPiece?.type == ChessPieceType.king &&
        selectedPiece?.hasMoved == false &&
        newRow == 7 &&
        newCol == 2) {
      board[7][3] = ChessPiece(
          imagePathBlack: "assets/black-rook.png",
          imagePathWhite: "assets/white-rook.png",
          isWhite: true,
          type: ChessPieceType.rook);
      board[7][0] = null;
    }

    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol]?.hasMoved = true;
    board[selectedRow][selectedCol] = null;

    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Mat"),
                actions: [
                  TextButton(onPressed: resetGame, child: Text("tekrar oyna"))
                ],
              )).then((value) {
        _initalizeBoard();
        checkStatus = false;
        whitePiecesTaken.clear();
        blackPiecesTaken.clear();
        whiteKingPosition = [7, 4];
        blackKingPosition = [0, 4];
        isWhiteTurn = true;
        setState(() {});
      });
    }
    if (isWhiteTurn) {
      var ai = findBestMove(board, 4, false)!;

      board[ai.toRow][ai.toCol] = board[ai.fromRow][ai.fromCol];
      board[ai.fromRow][ai.fromCol] = null;
    }

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
    checkPawnUpgrade();
  }

  bool longRokCheck() {
    if (board[7][4] != null &&
        board[7][4]?.type == ChessPieceType.king &&
        board[7][4]?.hasMoved == false) {
      if (board[7][0] != null &&
          board[7][0]?.type == ChessPieceType.rook &&
          board[7][0]?.hasMoved == false &&
          board[7][1] == null &&
          board[7][2] == null &&
          board[7][3] == null) {
        if (simulatedMoveIsSafe(board[7][4]!, 7, 4, 7, 3) &&
            simulatedMoveIsSafe(board[7][4]!, 7, 4, 7, 2)) {
          return true;
        } else {
          return false;
        }
      } else
        return false;
    } else {
      return false;
    }
  }

  bool shortRokCheck() {
    if (board[7][4] != null &&
        board[7][4]?.type == ChessPieceType.king &&
        board[7][4]?.hasMoved == false) {
      if (board[7][7] != null &&
          board[7][7]?.type == ChessPieceType.rook &&
          board[7][7]?.hasMoved == false &&
          board[7][5] == null &&
          board[7][6] == null) {
        if (simulatedMoveIsSafe(board[7][4]!, 7, 4, 7, 5) &&
            simulatedMoveIsSafe(board[7][4]!, 7, 4, 7, 6)) {
          return true;
        } else {
          return false;
        }
      } else
        return false;
    } else {
      return false;
    }
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    ChessPiece? originalDestinationPiece = board[endRow][endCol];
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;
    bool kingisCheck = isKingInCheck(piece.isWhite);
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    return !kingisCheck;
  }

  bool isCheckMate(bool isWhiteKing) {
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void checkPawnUpgrade() {
    for (int i = 0; i < 8; i++) {
      if (board[0][i] != null &&
          board[0][i]!.isWhite &&
          board[0][i]!.type == ChessPieceType.pawn) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("SEÇ"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            board[0][i] = ChessPiece(
                                imagePathBlack: "assets/black-queen.png",
                                imagePathWhite: "assets/white-queen.png",
                                isWhite: true,
                                type: ChessPieceType.queen);
                          });
                          Navigator.pop(context);
                        },
                        child: Text("vezir")),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            board[0][i] = ChessPiece(
                                imagePathBlack: "assets/black-rook.png",
                                imagePathWhite: "assets/white-rook.png",
                                isWhite: true,
                                type: ChessPieceType.rook);
                          });
                          Navigator.pop(context);
                        },
                        child: Text("kale")),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            board[0][i] = ChessPiece(
                                imagePathBlack: "assets/black-bishop.png",
                                imagePathWhite: "assets/white-bishop.png",
                                isWhite: true,
                                type: ChessPieceType.bishop);
                          });
                          Navigator.pop(context);
                        },
                        child: Text("fil")),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            board[0][i] = ChessPiece(
                                imagePathBlack: "assets/black-knight.png",
                                imagePathWhite: "assets/white-knight.png",
                                isWhite: true,
                                type: ChessPieceType.knight);
                          });
                          Navigator.pop(context);
                        },
                        child: Text("at")),
                  ],
                ));
      } else {
        continue;
      }
    }
  }

  void resetGame() {
    Navigator.pop(context);
    _initalizeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      body: Column(
        children: [
          Expanded(
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: whitePiecesTaken.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                        isWhite: true,
                        imagePathBlack: whitePiecesTaken[index].imagePathBlack,
                        imagePathWhite: whitePiecesTaken[index].imagePathWhite,
                      ))),
          Text(checkStatus ? "Şah" : ""),
          Expanded(
            flex: 20,
            child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: 8 * 8,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;
                  bool isSelected = selectedRow == row && selectedCol == col;
                  bool isValidMove = false;
                  for (var position in validMoves) {
                    if (position[0] == row && position[1] == col) {
                      isValidMove = true;
                    }
                  }

                  return Square(
                    isWhite: isWhite(index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    onTap: () => pieceSelected(row, col),
                    isValidMove: isValidMove,
                  );
                }),
          ),
          Expanded(
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: blackPiecesTaken.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                        isWhite: false,
                        imagePathBlack: blackPiecesTaken[index].imagePathBlack,
                        imagePathWhite: blackPiecesTaken[index].imagePathWhite,
                      ))),
        ],
      ),
    );
  }
}

late List<List<ChessPiece?>> board;

class Move {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;

  Move(this.fromRow, this.fromCol, this.toRow, this.toCol);
}

int minimax(
  List<List<ChessPiece?>> board, // Satranç tahtası
  int depth, // Algoritmanın derinliği
  bool isMaximizingPlayer, // Şu anki oyuncu (maksimize mi ediyor?)
) {
  if (depth == 0 || isGameOver(board)) {
    return evaluateBoard(board);
  }

  if (isMaximizingPlayer) {
    int maxEval = -99999;
    for (var move in generateMoves(board, true)) {
      final newBoard = applyMove(board, move);
      final eval = minimax(newBoard, depth - 1, false);
      maxEval = max(maxEval, eval);
    }
    return maxEval;
  } else {
    int minEval = 99999;
    for (var move in generateMoves(board, false)) {
      final newBoard = applyMove(board, move);
      final eval = minimax(newBoard, depth - 1, true);
      minEval = min(minEval, eval);
    }
    return minEval;
  }
}

bool isGameOver(List<List<ChessPiece?>> board) {
  // Oyun bitiş durumunu kontrol eder (örneğin şah-mat, pat, vs.)
  return false;
}

int evaluateBoard(List<List<ChessPiece?>> board) {
  // Tahtadaki pozisyonu değerlendirir ve bir puan döndürür.
  int score = 0;
  for (var row in board) {
    for (var piece in row) {
      if (piece != null) {
        score += piece.isWhite
            ? getPieceValue(piece.type)
            : -getPieceValue(piece.type);
      }
    }
  }
  return score;
}

int getPieceValue(ChessPieceType type) {
  switch (type) {
    case ChessPieceType.pawn:
      return 10;
    case ChessPieceType.knight:
    case ChessPieceType.bishop:
      return 30;
    case ChessPieceType.rook:
      return 50;
    case ChessPieceType.queen:
      return 90;
    case ChessPieceType.king:
      return 900;
    default:
      return 0;
  }
}

List<Move> generateMoves(List<List<ChessPiece?>> board, bool isWhiteTurn) {
  List<Move> moves = [];
  for (int row = 0; row < 8; row++) {
    for (int col = 0; col < 8; col++) {
      ChessPiece? piece = board[row][col];
      if (piece != null && piece.isWhite == isWhiteTurn) {
        List<Move> pieceMoves = [];
        switch (piece.type) {
          case ChessPieceType.pawn:
            _generatePawnMoves(pieceMoves, board, row, col, piece.isWhite);
            break;
          case ChessPieceType.knight:
            _generateKnightMoves(pieceMoves, board, row, col, piece.isWhite);
            break;
          case ChessPieceType.bishop:
            _generateBishopMoves(pieceMoves, board, row, col, piece.isWhite);
            break;
          case ChessPieceType.rook:
            _generateRookMoves(pieceMoves, board, row, col, piece.isWhite);
            break;
          case ChessPieceType.queen:
            _generateQueenMoves(pieceMoves, board, row, col, piece.isWhite);
            break;
          case ChessPieceType.king:
            _generateKingMoves(pieceMoves, board, row, col, piece.isWhite);
            break;
        }
        for (var move in pieceMoves) {
          if (_isMoveLegal(board, move, isWhiteTurn)) {
            moves.add(move);
          }
        }
      }
    }
  }
  return moves;
}

bool _isMoveLegal(List<List<ChessPiece?>> board, Move move, bool isWhiteTurn) {
  // Tahtayı geçici olarak güncelle
  ChessPiece? capturedPiece =
      board[move.toRow][move.toCol]; // Hedef karedeki taş
  board[move.toRow][move.toCol] = board[move.fromRow][move.fromCol];
  board[move.fromRow][move.fromCol] = null;

  // Şahın tehdit altında olup olmadığını kontrol et
  bool isInCheck = _isKingInCheck(board, isWhiteTurn);

  // Tahtayı eski haline getir
  board[move.fromRow][move.fromCol] = board[move.toRow][move.toCol];
  board[move.toRow][move.toCol] = capturedPiece;

  return !isInCheck; // Şah tehdit altında değilse hamle geçerlidir
}

bool _isKingInCheck(List<List<ChessPiece?>> board, bool isWhiteTurn) {
  // Şahın pozisyonunu bul
  int kingRow = -1, kingCol = -1;
  for (int row = 0; row < 8; row++) {
    for (int col = 0; col < 8; col++) {
      ChessPiece? piece = board[row][col];
      if (piece != null &&
          piece.type == ChessPieceType.king &&
          piece.isWhite == isWhiteTurn) {
        kingRow = row;
        kingCol = col;
        break;
      }
    }
    if (kingRow != -1) break;
  }

  // Şahın tehdit altında olup olmadığını kontrol et
  return _isSquareAttacked(board, kingRow, kingCol, !isWhiteTurn);
}

bool _isSquareAttacked(
    List<List<ChessPiece?>> board, int row, int col, bool byWhite) {
  // Tüm rakip taşların geçerli hamlelerini kontrol et
  for (int r = 0; r < 8; r++) {
    for (int c = 0; c < 8; c++) {
      ChessPiece? piece = board[r][c];
      if (piece != null && piece.isWhite == byWhite) {
        List<Move> moves = [];
        switch (piece.type) {
          case ChessPieceType.pawn:
            _generatePawnMoves(moves, board, r, c, piece.isWhite);
            break;
          case ChessPieceType.knight:
            _generateKnightMoves(moves, board, r, c, piece.isWhite);
            break;
          case ChessPieceType.bishop:
            _generateBishopMoves(moves, board, r, c, piece.isWhite);
            break;
          case ChessPieceType.rook:
            _generateRookMoves(moves, board, r, c, piece.isWhite);
            break;
          case ChessPieceType.queen:
            _generateQueenMoves(moves, board, r, c, piece.isWhite);
            break;
          case ChessPieceType.king:
            _generateKingMoves(moves, board, r, c, piece.isWhite);
            break;
        }
        for (var move in moves) {
          if (move.toRow == row && move.toCol == col) {
            return true;
          }
        }
      }
    }
  }
  return false;
}

void _generatePawnMoves(List<Move> moves, List<List<ChessPiece?>> board,
    int row, int col, bool isWhite) {
  if (isWhite) {
    // Beyaz piyonlar
    if (row - 1 >= 0 && board[row - 1][col] == null) {
      moves.add(Move(row, col, row - 1, col)); // Tek adım yukarı
    }
    if (row - 1 >= 0 &&
        col - 1 >= 0 &&
        board[row - 1][col - 1]?.isWhite == false) {
      moves.add(Move(row, col, row - 1, col - 1)); // Diagonal capture
    }
    if (row - 1 >= 0 &&
        col + 1 < 8 &&
        board[row - 1][col + 1]?.isWhite == false) {
      moves.add(Move(row, col, row - 1, col + 1)); // Diagonal capture
    }
  } else {
    // Siyah piyonlar
    if (row + 1 < 8 && board[row + 1][col] == null) {
      moves.add(Move(row, col, row + 1, col)); // Tek adım aşağı
    }
    if (row + 1 < 8 &&
        col - 1 >= 0 &&
        board[row + 1][col - 1]?.isWhite == true) {
      moves.add(Move(row, col, row + 1, col - 1)); // Diagonal capture
    }
    if (row + 1 < 8 &&
        col + 1 < 8 &&
        board[row + 1][col + 1]?.isWhite == true) {
      moves.add(Move(row, col, row + 1, col + 1)); // Diagonal capture
    }
  }
}

void _generateKnightMoves(List<Move> moves, List<List<ChessPiece?>> board,
    int row, int col, bool isWhite) {
  List<List<int>> knightMoves = [
    [-2, -1],
    [-2, 1],
    [2, -1],
    [2, 1],
    [-1, -2],
    [-1, 2],
    [1, -2],
    [1, 2]
  ];
  for (var move in knightMoves) {
    int newRow = row + move[0];
    int newCol = col + move[1];
    if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
      ChessPiece? target = board[newRow][newCol];
      if (target == null || target.isWhite != isWhite) {
        moves.add(Move(row, col, newRow, newCol));
      }
    }
  }
}

void _generateBishopMoves(List<Move> moves, List<List<ChessPiece?>> board,
    int row, int col, bool isWhite) {
  List<List<int>> directions = [
    [-1, -1],
    [-1, 1],
    [1, -1],
    [1, 1]
  ];
  for (var direction in directions) {
    int newRow = row;
    int newCol = col;
    while (true) {
      newRow += direction[0];
      newCol += direction[1];
      if (newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8) break;
      ChessPiece? target = board[newRow][newCol];
      if (target == null) {
        moves.add(Move(row, col, newRow, newCol));
      } else {
        if (target.isWhite != isWhite) {
          moves.add(Move(row, col, newRow, newCol));
        }
        break;
      }
    }
  }
}

void _generateRookMoves(List<Move> moves, List<List<ChessPiece?>> board,
    int row, int col, bool isWhite) {
  List<List<int>> directions = [
    [0, -1],
    [0, 1],
    [-1, 0],
    [1, 0]
  ];
  for (var direction in directions) {
    int newRow = row;
    int newCol = col;
    while (true) {
      newRow += direction[0];
      newCol += direction[1];
      if (newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8) break;
      ChessPiece? target = board[newRow][newCol];
      if (target == null) {
        moves.add(Move(row, col, newRow, newCol));
      } else {
        if (target.isWhite != isWhite) {
          moves.add(Move(row, col, newRow, newCol));
        }
        break;
      }
    }
  }
}

void _generateQueenMoves(List<Move> moves, List<List<ChessPiece?>> board,
    int row, int col, bool isWhite) {
  _generateRookMoves(moves, board, row, col, isWhite);
  _generateBishopMoves(moves, board, row, col, isWhite);
}

void _generateKingMoves(List<Move> moves, List<List<ChessPiece?>> board,
    int row, int col, bool isWhite) {
  List<List<int>> kingMoves = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
    [-1, -1],
    [-1, 1],
    [1, -1],
    [1, 1]
  ];
  for (var move in kingMoves) {
    int newRow = row + move[0];
    int newCol = col + move[1];
    if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
      ChessPiece? target = board[newRow][newCol];
      if (target == null || target.isWhite != isWhite) {
        moves.add(Move(row, col, newRow, newCol));
      }
    }
  }
}

List<List<ChessPiece?>> applyMove(List<List<ChessPiece?>> board, Move move) {
  final newBoard = List<List<ChessPiece?>>.from(
    board.map((row) => List<ChessPiece?>.from(row)),
  );

  newBoard[move.toRow][move.toCol] = newBoard[move.fromRow][move.fromCol];
  newBoard[move.fromRow][move.fromCol] = null;
  return newBoard;
}
