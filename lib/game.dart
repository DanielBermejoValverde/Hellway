import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hellway/ship.dart';

class MyGameScreen extends StatefulWidget {
  @override
  _MyGameScreenState createState() => _MyGameScreenState();
}

class _MyGameScreenState extends State<MyGameScreen> {
  double spaceshipPosition = 0.0; // Posición inicial de la nave espacial
  double spaceshipMovement = 0.0;
  Timer? timer; // Timer para mover la nave continuamente
  bool isPressed = false; // Bandera para verificar si se mantiene presionado

  @override
  void dispose() {
    timer?.cancel(); // Cancelar el timer al salir de la pantalla
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    // Obtener el ancho de la pantalla y establecer la posición inicial de la nave en la mitad

  }

  void startMoving() {
    timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        // Actualizar la posición de la nave continuamente mientras se mantiene presionado
        if (isPressed) {
          spaceshipPosition += spaceshipMovement;
          (context.findRenderObject() as RenderObject).markNeedsPaint();
        } else {
          timer.cancel(); // Detener el movimiento si se levanta el dedo
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    spaceshipPosition = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text('Juego de Naves'),
      ),
      body: GestureDetector(
        onHorizontalDragDown: (_) {
          double xPos = _.localPosition.dx;
          // Determinar la dirección del movimiento de la nave espacial basándose en la posición X del gesto
          if (xPos > MediaQuery.of(context).size.width / 2) {
            // Si se toca la parte derecha de la pantalla, mueve la nave hacia la derecha
            spaceshipMovement += 2; // Puedes ajustar el valor de desplazamiento según tu preferencia
          } else {
            // Si se toca la parte izquierda de la pantalla, mueve la nave hacia la izquierda
            spaceshipMovement -= 2; // Puedes ajustar el valor de desplazamiento según tu preferencia
          }
          isPressed = true; // Bandera cuando se presiona el dedo
          startMoving(); // Comenzar el movimiento continuo de la nave
        },
        onHorizontalDragEnd: (_) {
          isPressed = false; // Bandera cuando se levanta el dedo
        },
          child: Container(
            color: Colors.black, // Fondo negro para representar el espacio
            height: MediaQuery.of(context).size.height,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 50), // Tamaño del dibujo de la nave
              painter: ShipPainter(spaceshipPosition-25), // Llama al CustomPainter con la posición de la nave
              ),
                // Otros elementos podrían ir encima de la nave si es necesario
            ),
        ),
      );
  }
}
