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

  // Pieza actualmente seleccionada por el usuario
  ChessPiece? selectedPiece;

  // Coordenadas (fila y columna) de la pieza seleccionada. Inicialmente -1 (ninguna seleccionada)
  int selectedRow = -1;
  int selectedCol = -1;

  // Lista de movimientos válidos para la pieza seleccionada; cada movimiento es una lista [fila, columna]
  List<List<int>> validMoves = [];

  // Listas para almacenar las piezas capturadas de cada bando (blancas y negras)
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];

  // Variable para saber de quién es el turno: true para blancas, false para negras
  bool isWhiteTurn = true;

  // Posiciones actuales de los reyes, importantes para verificar situaciones de jaque y jaque mate
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];

  // Indica si hay jaque en el tablero (para mostrar notificación)
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

    // Colocar peones para ambos bandos en sus respectivas filas
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

    // Colocar torres en las esquinas correspondientes
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

    // Colocar caballos en las posiciones iniciales
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

    // Colocar alfiles en las posiciones correspondientes
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

    // Colocar reyes y definir su posición inicial
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

    // Asignar el tablero inicializado a la variable global board
    board = newBoard;
  }

  // Función que se llama al tocar una casilla del tablero.
  // Se encarga de manejar la selección de piezas, cambio de selección y movimiento si la casilla es válida.
  void pieceSelected(int row, int col) {
    setState(() {
      // Si no hay pieza seleccionada y la casilla tocada contiene una pieza...
      if (selectedPiece == null && board[row][col] != null) {
        // Solo se permite seleccionar una pieza del bando cuyo turno es el actual
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      // Si se toca otra pieza del mismo bando, se actualiza la selección
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
      // Si se toca una casilla que es un movimiento válido para la pieza seleccionada, se realiza el movimiento
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // Actualiza la lista de movimientos válidos para la pieza seleccionada
      validMoves = calculateRealValidMoves(
        selectedRow,
        selectedCol,
        selectedPiece,
        true,
      );
    });
  }

  // Calcula los movimientos "crudos" (sin validar el jaque) para la pieza ubicada en (row, col)
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    // Si no hay pieza en la casilla, no hay movimientos posibles
    if (piece == null) {
      return [];
    }

    // Determina la dirección de avance para el peón: -1 para blancas (hacia arriba) y 1 para negras (hacia abajo)
    int direction = piece.isWhite ? -1 : 1;

    // Se calcula según el tipo de pieza
    switch (piece.type) {
      case ChessPieceType.pawn:
        // Movimiento hacia adelante de un paso, si la casilla está vacía
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // Movimiento de dos pasos si es el primer movimiento del peón y ambas casillas están vacías
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
        // Movimientos en línea recta: vertical y horizontal
        var directions = [
          [-1, 0], // arriba
          [1, 0], // abajo
          [0, -1], // izquierda
          [0, 1], // derecha
        ];

        // Para cada dirección, se recorre hasta encontrar el borde del tablero o una pieza
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            // Verifica que la nueva posición esté dentro del tablero
            if (!isInBoard(newRow, newCol)) {
              break;
            }

            // Si la casilla contiene una pieza...
            if (board[newRow][newCol] != null) {
              // Si la pieza es enemiga, se añade el movimiento de captura
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break; // Se detiene al encontrar cualquier pieza
            }
            // Si está vacía, se añade como movimiento válido
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.knight:
        // Movimientos característicos del caballo (en "L")
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];

        // Se recorre cada uno de los posibles movimientos
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          // Verificar que la nueva posición esté en el tablero
          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          // Si hay pieza en la casilla destino...
          if (board[newRow][newCol] != null) {
            // Solo se permite capturar si es una pieza enemiga
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;

      case ChessPieceType.bishop:
        // Movimientos diagonales
        var directions = [
          [-1, -1], // arriba izquierda
          [-1, 1], // arriba derecha
          [1, -1], // abajo izquierda
          [1, 1], // abajo derecha
        ];

        // Se recorre cada dirección diagonal
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            // Si hay una pieza en la casilla destino...
            if (board[newRow][newCol] != null) {
              // Se añade el movimiento si la pieza es enemiga (captura)
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break; // Se bloquea la dirección
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

        // Se recorre cada dirección y se acumulan movimientos hasta bloquearse
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }

            // Si se encuentra una pieza...
            if (board[newRow][newCol] != null) {
              // Se añade si es enemiga, permitiendo la captura
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break; // Camino bloqueado
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.king:
        // Movimientos posibles del rey: una casilla en cualquier dirección
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

        // Se evalúa cada casilla adyacente
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          // Si la casilla destino contiene una pieza...
          if (board[newRow][newCol] != null) {
            // Solo se permite capturar si es enemiga
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
    }
    // Devuelve la lista de movimientos "crudos" calculados
    return candidateMoves;
  }

  // Calcula los movimientos reales válidos para una pieza en (row, col)
  // considerando simulaciones para evitar movimientos que dejen al rey en jaque.
  List<List<int>> calculateRealValidMoves(
    int row,
    int col,
    ChessPiece? piece,
    bool checkSimulation,
  ) {
    List<List<int>> realValidMoves = [];
    // Primero, se obtienen los movimientos "crudos" sin validar el jaque
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // Si se requiere validar mediante simulación:
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        // Simula el movimiento y verifica que no ponga al rey en jaque
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      // Si no se requiere la simulación, se devuelven los movimientos candidatos
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  // Método que realiza el movimiento de la pieza seleccionada hacia la casilla (newRow, newCol)
  void movePiece(int newRow, int newCol) {
    // Si en la casilla destino hay una pieza, se captura y se agrega a la lista correspondiente
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

    // Mueve la pieza: coloca la pieza seleccionada en la casilla destino y vacía la casilla original
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Verifica si el movimiento ha puesto al rey contrario en jaque
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // Antes de reiniciar la selección, se verifica si la pieza movida es un peón que ha llegado a la última fila
    if (selectedPiece!.type == ChessPieceType.pawn) {
      // Para piezas blancas, la promoción ocurre en la fila 0; para negras, en la fila 7
      if ((selectedPiece!.isWhite && newRow == 0) ||
          (!selectedPiece!.isWhite && newRow == 7)) {
        // Llama al diálogo de promoción para que el usuario seleccione la pieza
        _showPromotionDialog(newRow, newCol, selectedPiece!.isWhite);
      }
    }

    // Reinicia la selección y los movimientos válidos
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // Verifica si se ha producido un jaque mate en el bando contrario
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

    // Cambia el turno al otro jugador
    isWhiteTurn = !isWhiteTurn;
  }

  // Función que muestra un diálogo para la promoción del peón.
  // Permite elegir entre Reina, Torre, Alfil y Caballo.
  void _showPromotionDialog(int row, int col, bool isWhite) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Promoción de Peón"),
          content: const Text(
            "Selecciona la pieza a la que deseas promover el peón:",
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  board[row][col] = ChessPiece(
                    type: ChessPieceType.queen,
                    isWhite: isWhite,
                    imagePath: 'lib/images/queen.png',
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text("Reina"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  board[row][col] = ChessPiece(
                    type: ChessPieceType.rook,
                    isWhite: isWhite,
                    imagePath: 'lib/images/rook.png',
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text("Torre"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  board[row][col] = ChessPiece(
                    type: ChessPieceType.bishop,
                    isWhite: isWhite,
                    imagePath: 'lib/images/bishop.png',
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text("Alfil"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  board[row][col] = ChessPiece(
                    type: ChessPieceType.knight,
                    isWhite: isWhite,
                    imagePath: 'lib/images/knight.png',
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text("Caballo"),
            ),
          ],
        );
      },
    );
  }

  // Verifica si el rey del bando especificado está en jaque.
  // Se recorre todo el tablero para ver si alguna pieza enemiga puede atacar la posición del rey.
  bool isKingInCheck(bool isWhiteKing) {
    // Se selecciona la posición del rey según el bando
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // Recorrer todas las casillas del tablero
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Se ignoran las casillas vacías o las piezas del mismo bando que el rey
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        // Se obtienen los movimientos válidos sin simular, para agilizar la comprobación
        List<List<int>> pieceValidMoves = calculateRealValidMoves(
          i,
          j,
          board[i][j],
          false,
        );

        // Si algún movimiento puede alcanzar la posición del rey, este se encuentra en jaque
        if (pieceValidMoves.any(
          (move) => move[0] == kingPosition[0] && move[1] == kingPosition[1],
        )) {
          return true;
        }
      }
    }

    return false;
  }

  // Simula un movimiento y verifica si es seguro, es decir, si no deja al rey en jaque.
  // Para ello, se realiza el movimiento, se comprueba la seguridad y se revierte el cambio.
  bool simulatedMoveIsSafe(
    ChessPiece piece,
    int startRow,
    int startCol,
    int endRow,
    int endCol,
  ) {
    // Guarda la pieza original en la casilla destino (si la hay) para poder restaurarla
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // Guarda la posición original del rey en caso de que la pieza movida sea el rey
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;
      // Actualiza la posición del rey en la simulación
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // Realiza el movimiento simulado en el tablero
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // Verifica si tras el movimiento el rey queda en jaque
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // Revierte el movimiento para restaurar el estado original del tablero
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    // Restaura la posición original del rey si la pieza simulada era el rey
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

  // Verifica si se ha producido un jaque mate para el bando especificado.
  // Se comprueba que el rey está en jaque y que ninguna pieza puede realizar un movimiento
  // que saque al rey del jaque.
  bool isCheckMate(bool isWhiteKing) {
    // Si el rey no está en jaque, no puede haber jaque mate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // Recorre todas las piezas del bando que está en jaque
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Se ignoran casillas vacías o piezas del bando contrario
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        // Obtiene los movimientos válidos para cada pieza, verificando con simulación
        List<List<int>> pieceValidMoves = calculateRealValidMoves(
          i,
          j,
          board[i][j],
          true,
        );

        // Si alguna pieza tiene al menos un movimiento válido que la saque del jaque, no es jaque mate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // Si ninguna pieza puede evitar el jaque, se declara jaque mate
    return true;
  }

  // Función para reiniciar el juego a su estado inicial.
  // Se cierra el diálogo de jaque mate, se reinicializa el tablero, se limpian las piezas capturadas
  // y se restablecen las posiciones iniciales y el turno.
  void resetGame() {
    // Cierra el diálogo emergente
    Navigator.pop(context);
    // Reinicializa el tablero con las posiciones iniciales
    _initializeBoard();
    checkStatus = false;
    // Limpia las listas de piezas capturadas
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    // Restaura las posiciones iniciales de los reyes
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    // Restablece el turno a las piezas blancas
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Construye la estructura principal de la pantalla usando un Scaffold
    return Scaffold(
      // Define el color de fondo de la pantalla
      backgroundColor: backgroundColor,
      // El cuerpo del Scaffold contiene una columna con varias secciones
      body: Column(
        children: [
          // ──────────────────────────────────────────────────────────────
          // Sección superior: Muestra las piezas capturadas del bando blanco
          // ──────────────────────────────────────────────────────────────
          Expanded(
            // El widget Expanded hace que esta sección ocupe el espacio que le corresponde
            child: GridView.builder(
              // Se genera un item por cada pieza capturada del bando blanco
              itemCount: whitePiecesTaken.length,
              // Deshabilita el desplazamiento para que la grilla se ajuste al tamaño del Expanded
              physics: const NeverScrollableScrollPhysics(),
              // Define un grid con un número fijo de columnas (8 en este caso)
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              // itemBuilder crea cada widget que representa una pieza capturada
              itemBuilder:
                  (context, index) => DeadPiece(
                    // Se pasa la ruta de la imagen de la pieza capturada
                    imagePath: whitePiecesTaken[index].imagePath,
                    // Se especifica que la pieza es blanca
                    isWhite: true,
                  ),
            ),
          ),

          // ──────────────────────────────────────────────────────────────
          // Indicador de jaque: Muestra el mensaje "CHECK!" si hay jaque en el tablero
          // ──────────────────────────────────────────────────────────────
          Text(
            // Si checkStatus es verdadero, se muestra "CHECK!", de lo contrario se muestra una cadena vacía
            checkStatus ? "CHECK!" : "",
            // Se pueden agregar estilos adicionales al texto si se desea
          ),

          // ──────────────────────────────────────────────────────────────
          // Sección central: Representa el tablero de ajedrez
          // ──────────────────────────────────────────────────────────────
          Expanded(
            // Se asigna un mayor flex (3) para que esta sección ocupe más espacio en la pantalla
            flex: 3,
            child: GridView.builder(
              // Se crea una grilla de 8x8 casillas (64 en total)
              itemCount: 8 * 8,
              // Deshabilita el desplazamiento vertical para que se muestre todo el tablero fijo
              physics: const NeverScrollableScrollPhysics(),
              // Define la grilla con 8 columnas, lo que garantiza que el tablero se vea como un cuadrado
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              // El itemBuilder se encarga de construir cada casilla del tablero
              itemBuilder: (context, index) {
                // Se calcula la fila y columna a partir del índice lineal
                int row = index ~/ 8; // División entera para obtener la fila
                int col = index % 8; // Módulo para obtener la columna

                // Determina si la casilla actual está seleccionada por el usuario
                bool isSelected = selectedRow == row && selectedCol == col;

                // Inicializa la bandera que indica si esta casilla es un movimiento válido
                bool isValidMove = false;
                // Se recorre la lista de movimientos válidos para ver si la casilla (row, col) es uno de ellos
                for (var position in validMoves) {
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                    break; // Se sale del ciclo al encontrar una coincidencia
                  }
                }

                // Se devuelve el widget Square que representa una casilla del tablero
                return Square(
                  // Determina el color de la casilla (blanca o negra) basado en su índice
                  isWhite: isWhite(index),
                  // Se pasa la pieza que se encuentra en la posición actual del tablero (puede ser null)
                  piece: board[row][col],
                  // Indica si la casilla está seleccionada para mostrar una indicación visual
                  isSelected: isSelected,
                  // Indica si la casilla es un destino válido para mover la pieza seleccionada
                  isValidMove: isValidMove,
                  // Función que se ejecuta al tocar la casilla: gestiona la selección y movimiento de la pieza
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),

          // ──────────────────────────────────────────────────────────────
          // Sección inferior: Muestra las piezas capturadas del bando negro
          // ──────────────────────────────────────────────────────────────
          Expanded(
            child: GridView.builder(
              // Se genera un item por cada pieza capturada del bando negro
              itemCount: blackPiecesTaken.length,
              // Deshabilita el desplazamiento para que la grilla se ajuste al tamaño del Expanded
              physics: const NeverScrollableScrollPhysics(),
              // Define la grilla con 8 columnas para una distribución uniforme
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              // itemBuilder crea cada widget que representa una pieza capturada
              itemBuilder:
                  (context, index) => DeadPiece(
                    // Se pasa la ruta de la imagen de la pieza capturada
                    imagePath: blackPiecesTaken[index].imagePath,
                    // Se especifica que la pieza es negra
                    isWhite: false,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
