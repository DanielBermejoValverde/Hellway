import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hellway',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Hellway'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
abstract class GameObject{
  Offset position;
  Size size;
  GameObject(this.position,this.size);
  Widget renderAnim(Animation<double> animation,Size unit)=>
      AnimatedBuilder(
          animation: animation,
          builder: (context,child)=>Positioned(
            top: position.dy*unit.height,
            left: position.dx*unit.width,
            width: size.width*unit.width,
            height: size.height*unit.height,
            child: render(unit)
          ));
  Widget render(Size size);
}
class Ship extends GameObject{
  double speed=2;

  Ship(Offset position): super(position,const Size(1,1));

  @override
  Widget render(Size size){
    return Container(color:Colors.orange);
  }

}
class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  int score=0;
  late Size worldSize;
  late Ship ship;
  @override
  void initState(){
    super.initState();
    controller =AnimationController(vsync: this,duration: const Duration(days: 30));
    worldSize= const Size(20,30);
    ship=Ship(Offset(10-.5,28));
    controller.forward();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0,0,8,0),
          child: Column(
            children: [
              Text("$score",style: const TextStyle(color: Colors.pinkAccent,fontSize: 32)),
              Container(
                color: Colors.blue[900],
                child: AspectRatio(
                  aspectRatio: worldSize.aspectRatio,
                  child: LayoutBuilder(
                    builder: (context,constraints){
                     Size unit= Size(constraints.maxWidth/worldSize.width, constraints.maxHeight/worldSize.height);
                     List<Widget> gameObjects=[];
                     gameObjects.add(ship.renderAnim(controller,unit));
                     return Stack(children: gameObjects);
                    }
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



