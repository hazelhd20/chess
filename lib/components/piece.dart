// Enumeración que define los diferentes tipos de piezas del ajedrez
enum ChessPieceType { 
  pawn,    // Peón
  rook,    // Torre
  knight,  // Caballo
  bishop,  // Alfil
  queen,   // Reina
  king     // Rey
}

// Clase que representa una pieza de ajedrez en el juego
class ChessPiece {
  // Tipo de la pieza, usando la enumeración ChessPieceType
  final ChessPieceType type;
  // Indica si la pieza es blanca (true) o negra (false)
  final bool isWhite;
  // Ruta a la imagen que representa la pieza visualmente
  final String imagePath;

  // Constructor que inicializa la pieza con su tipo, color e imagen
  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
  });
}
