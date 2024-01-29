import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hellway/game.dart';

class HomePage extends StatefulWidget{
  final String title;
  const HomePage({super.key,required this.title});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hellway'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hellway',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Image.asset(
              'assets/images/Spaceship.gif',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),

            // Botón para jugar
            ElevatedButton(

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GamePage(title: 'Hellway')),
                );
              },
              child: Text('Jugar',style: TextStyle(fontSize: 32),),
            ),
          ],
        ),
      ),
    );
  }
}