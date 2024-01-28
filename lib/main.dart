import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  Rect get rect=>Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
}
class Ship extends GameObject{
  double speed=10;
  bool goLeft=false;
  bool goRight=false;
  Ship(Offset position): super(position,const Size(1,1));
  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/config.json');
  }
  @override
  Widget render(Size size){
    return const Image(image: AssetImage());
  }
}
class EnemyShip extends GameObject{
  double speed=10;
  EnemyShip(Offset position):super(position,const Size(1,1));

  @override
  Widget render(Size size) {
    return Container(color:Colors.purple);
  }
}
class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  int score=0;
  late Size worldSize;
  late Ship ship;
  int prevTime=0;
  @override
  void initState(){
    super.initState();
    controller =AnimationController(vsync: this,duration: const Duration(days: 30));
    log("controller");
    controller.addListener(update);
    worldSize= const Size(8,12);
    ship=Ship(Offset(4-.5,11));
    prevTime=DateTime.now().millisecondsSinceEpoch;
    controller.forward();

  }

  void update(){
    int currentTime=DateTime.now().millisecondsSinceEpoch;
    double deltaTime = (currentTime-prevTime)/1000.0;

    if(ship.goLeft && ship.position.dx>0){
      ship.position = Offset(ship.position.dx-ship.speed*deltaTime,ship.position.dy);
    }
    if(ship.goRight && ship.position.dx<worldSize.width-1){
      ship.position = Offset(ship.position.dx+ship.speed*deltaTime,ship.position.dy);
    }

    prevTime=currentTime;
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
              ),
              Row(children: [
                Expanded(child: MoveButton(key: const Key("arrow left"),
                        down: () =>{ship.goLeft=true,log("left down "+ship.goLeft.toString())},
                        up: () => {ship.goLeft=false,log("left up "+ship.goLeft.toString()) },
                    icon: Icons.arrow_circle_left_sharp),
                ),
                Expanded(child: MoveButton(key : const Key("arrow right"),
                        down: () =>{ship.goRight=true,log("right down "+ship.goRight.toString())},
                        up: () =>{ship.goRight=false,log("right up "+ship.goRight.toString()) },
                    icon: Icons.arrow_circle_right_sharp),
                ),
              ],)
            ],
          ),
        ),
      ),
    );
  }
}
class MoveButton extends StatelessWidget{
  void Function() down;
  void Function() up;
  IconData icon;
  Color iconColor=Colors.black;

  MoveButton({required Key key,required this.down,required this.up,required this.icon}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(
        icon,
        color: iconColor,
        size: 64,
      ),
      onTapDown: (details)=>{ down(),iconColor=Colors.deepOrange},
      onTapUp: (details)=> {up(),iconColor=Colors.black}
    );
  }
  
}



