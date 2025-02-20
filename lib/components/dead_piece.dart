import 'package:flutter/material.dart';

// Widget sin estado que representa una pieza capturada (pieza muerta) en el juego
class DeadPiece extends StatelessWidget {
  // Ruta a la imagen que representa la pieza capturada
  final String imagePath;
  // Indica si la pieza capturada es blanca o negra. Esto se utiliza para aplicar un tinte
  // diferente a la imagen, lo que ayuda a distinguir visualmente el bando de la pieza.
  final bool isWhite;

  // Constructor del widget que recibe la ruta de la imagen y el color (bando) de la pieza
  const DeadPiece({
    super.key,
    required this.imagePath,
    required this.isWhite,
  });

  @override
  Widget build(BuildContext context) {
    // Construye un widget Image que carga la imagen de la pieza capturada
    return Image.asset(
      imagePath,
      // Se aplica un tinte (color) a la imagen:
      // - Si la pieza es blanca, se aplica un tono gris claro (Colors.grey[400])
      // - Si la pieza es negra, se aplica un tono gris oscuro (Colors.grey[800])
      // Esto ayuda a diferenciar visualmente las piezas capturadas de cada bando.
      color: isWhite ? Colors.grey[400] : Colors.grey[800],
    );
  }
}
