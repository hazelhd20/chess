import 'package:chess/components/piece.dart'; 
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';

/// Widget Stateless que representa una casilla del tablero de ajedrez.
class Square extends StatelessWidget {
  /// Indica si la casilla es blanca (true) o negra (false).
  final bool isWhite;

  /// Pieza que se encuentra en la casilla (null si está vacía).
  final ChessPiece? piece;

  /// Indica si la casilla está seleccionada actualmente.
  final bool isSelected;

  /// Indica si la casilla es un movimiento válido para la pieza seleccionada.
  final bool isValidMove;

  /// Función que se ejecuta al tocar la casilla.
  final void Function()? onTap;

  /// Constructor que recibe todas las propiedades requeridas.
  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove,
  });

  @override
  Widget build(BuildContext context) {
    // Variable que contendrá el color de fondo de la casilla.
    Color? squareColor;

    // Si la casilla está seleccionada, se resalta en verde.
    if (isSelected) {
      squareColor = Colors.green;
    }
    // Si la casilla es un movimiento válido, se resalta con un verde más claro.
    else if (isValidMove) {
      squareColor = Colors.green[300];
    }
    // Si no se cumple ninguna de las condiciones anteriores,
    // se asigna un color base según si la casilla es blanca o negra.
    else {
      squareColor = isWhite ? foregroundColor : backgroundColor; 
    }

    // Se utiliza un GestureDetector para detectar toques en la casilla.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Se establece el color de fondo de la casilla.
        color: squareColor,
        // Se aplica un margen para resaltar la casilla si es un movimiento válido.
        margin: EdgeInsets.all(isValidMove ? 8 : 0),
        // Si hay una pieza en la casilla, se muestra su imagen; en caso contrario, la casilla queda vacía.
        child: piece != null
            ? Image.asset(
                piece!.imagePath,
                // Se aplica un color a la imagen según el bando de la pieza:
                // blanco para piezas blancas y negro para piezas negras.
                color: piece!.isWhite ? Colors.white : Colors.black,
              )
            : null,
      ),
    );
  }
}
