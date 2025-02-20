// Importa el widget GameBoard que contiene la lógica y la interfaz del tablero de ajedrez
import 'package:chess/game_board.dart';
// Importa el paquete de Flutter que proporciona los widgets y herramientas básicas para construir la UI
import 'package:flutter/material.dart';

// Función principal: punto de entrada de la aplicación Flutter
void main() {
  // Inicia la aplicación y coloca el widget MyApp como el widget raíz de la aplicación
  runApp(const MyApp());
}

// MyApp es un widget sin estado que representa la configuración global de la aplicación
class MyApp extends StatelessWidget {
  // Constructor de MyApp, se utiliza la sintaxis 'const' para optimización en tiempo de compilación
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp es un widget de alto nivel que configura aspectos generales de la aplicación
    // como el tema, las rutas y la navegación
    return MaterialApp(
      // Deshabilita la etiqueta de depuración ("DEBUG") que aparece por defecto en la esquina superior derecha
      debugShowCheckedModeBanner: false,
      // Define la pantalla principal de la aplicación estableciéndola como el tablero de ajedrez
      home: GameBoard(),
    );
  }
}
