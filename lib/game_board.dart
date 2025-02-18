import 'package:chess/components/dead_piece.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/helper/helper_methods.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';

// Widget con estado que representa el tablero del juego de ajedrez
class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // Matriz de 8x8 que representa el tablero. Cada casilla puede tener una pieza o estar vacía (null)
  late List<List<ChessPiece?>> board;

  // Pieza actualmente seleccionada
  ChessPiece? selectedPiece;

  // Coordenadas de la pieza seleccionada
  int selectedRow = -1;
  int selectedCol = -1;

  // Lista de movimientos válidos para la pieza seleccionada
  List<List<int>> validMoves = [];

  // Listas para almacenar las piezas capturadas de cada bando
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];

  // Variable para saber de quién es el turno: true para blancas, false para negras
  bool isWhiteTurn = true;

  // Posiciones actuales de los reyes, importantes para verificar jaque y jaque mate
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];

  // Indica si hay jaque en el tablero
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    // Inicializa el tablero al iniciar el widget
    _initializeBoard();
  }

  // Función para inicializar el tablero con todas las piezas en su posición inicial
  void _initializeBoard() {
    // Crea una matriz de 8x8 inicializada con null (casillas vacías)
    List<List<ChessPiece?>> newBoard = List.generate(
      8,
      (index) => List.generate(8, (index) => null),
    );

    // Colocar peones para ambos bandos
    for (int i = 0; i < 8; i++) {
      // Peones negros en la fila 1
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imagePath: 'lib/images/pawn.png',
      );

      // Peones blancos en la fila 6
      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imagePath: 'lib/images/pawn.png',
      );
    }

    // Colocar torres
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/images/rook.png',
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/images/rook.png',
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/images/rook.png',
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/images/rook.png',
    );

    // Colocar caballos
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/images/knight.png',
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/images/knight.png',
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/images/knight.png',
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/images/knight.png',
    );

    // Colocar alfiles
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/images/bishop.png',
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/images/bishop.png',
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/images/bishop.png',
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/images/bishop.png',
    );

    // Colocar reinas
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'lib/images/queen.png',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'lib/images/queen.png',
    );

    // Colocar reyes
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'lib/images/king.png',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'lib/images/king.png',
    );

    // Asignar el tablero inicializado a la variable global
    board = newBoard;
  }

  // Función que se llama al tocar una casilla del tablero
  void pieceSelected(int row, int col) {
    setState(() {
      // Si no hay pieza seleccionada y la casilla tocada contiene una pieza
      if (selectedPiece == null && board[row][col] != null) {
        // Solo se permite seleccionar una pieza del bando cuyo turno es
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      // Si se toca otra pieza del mismo bando, se cambia la selección
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
      // Si la casilla tocada es un movimiento válido para la pieza seleccionada
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // Actualizar la lista de movimientos válidos para la pieza seleccionada
      validMoves = calculateRealValidMoves(
        selectedRow,
        selectedCol,
        selectedPiece,
        true,
      );
    });
  }

  // Calcula movimientos "crudos" (sin verificar jaque) para la pieza en (row, col)
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    // Si no hay pieza, no hay movimientos posibles
    if (piece == null) {
      return [];
    }

    // Dirección para el avance del peón: -1 para blancas (arriba) y 1 para negras (abajo)
    int direction = piece.isWhite ? -1 : 1;

    // Verificar el tipo de pieza para calcular sus movimientos
    switch (piece.type) {
      case ChessPieceType.pawn:
        // Movimiento hacia adelante de un paso si la casilla está vacía
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // Movimiento de dos pasos si es el primer movimiento del peón
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // Captura en diagonal a la izquierda
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }

        // Captura en diagonal a la derecha
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;

      case ChessPieceType.rook:
        // Direcciones posibles para la torre: vertical y horizontal
        var directions = [
          [-1, 0], // arriba
          [1, 0], // abajo
          [0, -1], // izquierda
          [0, 1], // derecha
        ];

        // Recorrer cada dirección
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            // Verificar que la nueva posición esté dentro del tablero
            if (!isInBoard(newRow, newCol)) {
              break;
            }

            // Si la casilla contiene una pieza
            if (board[newRow][newCol] != null) {
              // Si la pieza es enemiga, se puede capturar
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // captura
              }
              break; // la pieza bloquea el camino
            }
            // Agregar el movimiento como válido
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.knight:
        // Movimientos característicos del caballo (en L)
        var knightMoves = [
          [-2, -1], // dos arriba, uno izquierda
          [-2, 1], // dos arriba, uno derecha
          [-1, -2], // uno arriba, dos izquierda
          [-1, 2], // uno arriba, dos derecha
          [1, -2], // uno abajo, dos izquierda
          [1, 2], // uno abajo, dos derecha
          [2, -1], // dos abajo, uno izquierda
          [2, 1], // dos abajo, uno derecha
        ];

        // Recorrer cada posible movimiento
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          // Si hay pieza en la casilla destino
          if (board[newRow][newCol] != null) {
            // Solo se puede capturar si es enemiga
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // captura
            }
            continue; // casilla bloqueada para movimiento sin captura
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;

      case ChessPieceType.bishop:
        // Direcciones diagonales
        var directions = [
          [-1, -1], // arriba izquierda
          [-1, 1], // arriba derecha
          [1, -1], // abajo izquierda
          [1, 1], // abajo derecha
        ];

        // Recorrer cada dirección diagonal
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            // Si hay una pieza en la casilla destino
            if (board[newRow][newCol] != null) {
              // Si es enemiga se puede capturar
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // captura
              }
              break; // camino bloqueado
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.queen:
        // La reina combina movimientos de torre y alfil: vertical, horizontal y diagonal
        var directions = [
          [-1, 0], // arriba
          [1, 0], // abajo
          [0, -1], // izquierda
          [0, 1], // derecha
          [-1, -1], // arriba izquierda
          [-1, 1], // arriba derecha
          [1, -1], // abajo izquierda
          [1, 1], // abajo derecha
        ];

        // Recorrer cada dirección
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }

            // Si se encuentra una pieza
            if (board[newRow][newCol] != null) {
              // Capturar si es enemiga
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // captura
              }
              break; // camino bloqueado
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.king:
        // Movimientos posibles del rey (una casilla en cualquier dirección)
        var directions = [
          [-1, 0], // arriba
          [1, 0], // abajo
          [0, -1], // izquierda
          [0, 1], // derecha
          [-1, -1], // arriba izquierda
          [-1, 1], // arriba derecha
          [1, -1], // abajo izquierda
          [1, 1], // abajo derecha
        ];

        // Recorrer cada dirección
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          // Si la casilla destino contiene una pieza
          if (board[newRow][newCol] != null) {
            // Solo se puede capturar si es enemiga
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // captura
            }
            continue; // casilla bloqueada
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
    }
    return candidateMoves;
  }

  // Calcula los movimientos reales válidos, considerando simulaciones para evitar exponer al rey a jaque
  List<List<int>> calculateRealValidMoves(
    int row,
    int col,
    ChessPiece? piece,
    bool checkSimulation,
  ) {
    List<List<int>> realValidMoves = [];
    // Primero se obtienen los movimientos "crudos"
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // Si se debe verificar la seguridad del movimiento (simulación)
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        // Se simula el movimiento para verificar que no ponga en jaque al rey
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      // Si no se verifica la simulación, se retornan los movimientos candidatos
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  // Realiza el movimiento de la pieza seleccionada hacia (newRow, newCol)
  void movePiece(int newRow, int newCol) {
    // Si en la casilla destino hay una pieza, se captura
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // Actualiza la posición del rey si la pieza movida es el rey
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // Mueve la pieza: asigna la pieza seleccionada a la casilla destino y la elimina de la casilla original
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Verifica si el movimiento ha puesto al rey contrario en jaque
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // Reinicia la selección y los movimientos válidos
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // Verificar si se ha producido un jaque mate
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("CHECK MATE!"),
              actions: [
                // Botón para reiniciar el juego
                TextButton(
                  onPressed: resetGame,
                  child: const Text("Play Again"),
                ),
              ],
            ),
      );
    }

    // Cambiar turno al otro jugador
    isWhiteTurn = !isWhiteTurn;
  }

  // Verifica si el rey del bando especificado está en jaque
  bool isKingInCheck(bool isWhiteKing) {
    // Seleccionar la posición del rey según el bando
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // Recorrer todas las casillas del tablero
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Saltar casillas vacías o piezas del mismo bando
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        // Calcular movimientos válidos sin simular (para agilizar la comprobación)
        List<List<int>> pieceValidMoves = calculateRealValidMoves(
          i,
          j,
          board[i][j],
          false,
        );

        // Si alguno de los movimientos puede alcanzar la posición del rey, está en jaque
        if (pieceValidMoves.any(
          (move) => move[0] == kingPosition[0] && move[1] == kingPosition[1],
        )) {
          return true;
        }
      }
    }

    return false;
  }

  bool simulatedMoveIsSafe(
    ChessPiece piece,
    int startRow,
    int startCol,
    int endRow,
    int endCol,
  ) {
    // Guardar la pieza original en la casilla destino (si la hay)
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // Variable para guardar la posición original del rey, en caso de que la pieza sea el rey
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;
      // Actualizar la posición del rey solo si la pieza movida es el rey
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // Realizar el movimiento simulado
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // Verificar si el rey queda en jaque tras el movimiento
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // Revertir la simulación: restaurar el tablero a su estado original
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    // Restaurar la posición del rey si la pieza movida es el rey
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    // El movimiento es seguro si no deja al rey en jaque
    return !kingInCheck;
  }

  // Verifica si se ha producido un jaque mate para el bando indicado
  bool isCheckMate(bool isWhiteKing) {
    // Si el rey no está en jaque, no puede ser jaque mate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // Recorrer todas las piezas del bando que está en jaque
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Saltar casillas vacías o piezas del bando contrario
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        // Obtener los movimientos válidos para cada pieza, verificando la simulación
        List<List<int>> pieceValidMoves = calculateRealValidMoves(
          i,
          j,
          board[i][j],
          true,
        );

        // Si alguna pieza tiene al menos un movimiento que la saque del jaque, no es jaque mate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // Si ninguna pieza puede evitar el jaque, es jaque mate
    return true;
  }

  // Función para reiniciar el juego a su estado inicial
  void resetGame() {
    // Cerrar el diálogo de jaque mate
    Navigator.pop(context);
    // Reinicializar el tablero
    _initializeBoard();
    checkStatus = false;
    // Limpiar las piezas capturadas
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    // Restaurar las posiciones iniciales de los reyes
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    // Restablecer turno a blancas
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Sección superior para mostrar las piezas capturadas de las blancas
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder:
                  (context, index) => DeadPiece(
                    imagePath: whitePiecesTaken[index].imagePath,
                    isWhite: true,
                  ),
            ),
          ),

          // Mostrar mensaje de "CHECK!" si hay jaque
          Text(checkStatus ? "CHECK!" : ""),

          // Sección central: el tablero de ajedrez
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) {
                // Calcular la fila y columna a partir del índice
                int row = index ~/ 8;
                int col = index % 8;

                // Determinar si la casilla actual es la seleccionada
                bool isSelected = selectedRow == row && selectedCol == col;

                // Verificar si la casilla es un movimiento válido
                bool isValidMove = false;
                for (var position in validMoves) {
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                // Devolver el widget Square con la información de la casilla
                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),

          // Sección inferior para mostrar las piezas capturadas de las negras
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder:
                  (context, index) => DeadPiece(
                    imagePath: blackPiecesTaken[index].imagePath,
                    isWhite: false,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
