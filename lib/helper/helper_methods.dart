// Función que determina si una casilla (identificada por un índice lineal) debe ser de color blanco
bool isWhite(int index) {
  // Se calcula la fila dividiendo el índice entre 8 (división entera)
  int x = index ~/ 8;
  // Se calcula la columna usando el resto de la división entre 8
  int y = index % 8;

  // En un tablero de ajedrez, el color de la casilla se determina sumando la fila y la columna:
  // si la suma es par, la casilla es blanca; si es impar, es negra.
  bool isWhite = (x + y) % 2 == 0;

  // Devuelve 'true' si la casilla es blanca, o 'false' en caso contrario
  return isWhite;
}

// Función que verifica si una posición (fila y columna) se encuentra dentro de los límites del tablero (8x8)
bool isInBoard(int row, int col) {
  // Retorna 'true' si:
  // - la fila es mayor o igual a 0 y menor que 8, y
  // - la columna es mayor o igual a 0 y menor que 8.
  // De lo contrario, retorna 'false'.
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}
