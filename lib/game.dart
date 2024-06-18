import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';

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
  Rect get rect=>Rect.fromLTWH(position.dx, position.dy, size.width-.2, size.height-.2);
}
class Ship extends GameObject{
  double speed=10;
  int life=3;
  bool goLeft=false;
  bool goRight=false;
  Ship(Offset position): super(position,const Size(1,1));
  @override
  Widget render(Size size){
    return const Image(image: AssetImage('assets/images/Spaceship.gif'));
  }
}
class EnemyShip extends GameObject{
  double speed=3;
  EnemyShip(Offset position):super(position,const Size(1,1));

  @override
  Widget render(Size size) {
    return const Image(image: AssetImage('assets/images/EnemySpaceship.gif'));
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.title});
  final String title;
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  int punt=0;
  late Size worldSize;
  late Ship ship;
  int prevTime=0;
  int time0=0;
  static const int waves=30;
  static const int enemiesNum=3;
  static const double spaceBetweenWaves=3.0;
  math.Random random=math.Random();
  late List<EnemyShip> enemyShips;
  late String dialog;
  @override
  void initState(){
    super.initState();
    controller =AnimationController(vsync: this,duration: const Duration(days: 30));
    controller.addListener(update);
    worldSize= const Size(6,9);
    ship=Ship(Offset(3-.5,8));
    prevTime=DateTime.now().millisecondsSinceEpoch;
    time0=DateTime.now().millisecondsSinceEpoch;
    enemyShips=[
      EnemyShip( Offset(3-.5,1.0))
    ];
    for(int i=0;i<waves;i++){
      for(int j=0;j<enemiesNum;j++){
        enemyShips.add(EnemyShip(Offset(random.nextInt(worldSize.width.toInt())*1.0,-i*spaceBetweenWaves)));
      }
    }
    controller.forward();
  }

  void update(){
    int currentTime=DateTime.now().millisecondsSinceEpoch;
    double deltaTime = (currentTime-prevTime)/1000.0;
    Rect shipRect = ship.rect;
    List<EnemyShip> destroyedEnemyShips=[];
    if(ship.goLeft && ship.position.dx>0){
      ship.position = Offset(ship.position.dx-ship.speed*deltaTime,ship.position.dy);
    }
    if(ship.goRight && ship.position.dx<worldSize.width-1){
      ship.position = Offset(ship.position.dx+ship.speed*deltaTime,ship.position.dy);
    }
    for(EnemyShip enemyShip in enemyShips){
      Rect enemyShipRect=enemyShip.rect;
      enemyShip.position=(Offset(enemyShip.position.dx,enemyShip.position.dy+enemyShip.speed*deltaTime));
      if(shipRect.overlaps(enemyShipRect)){
        punt-=500;
        ship.life--;
        destroyedEnemyShips.add(enemyShip);
      }
      if(enemyShip.position.dy>=worldSize.height){
        punt+=100;
        destroyedEnemyShips.add(enemyShip);
      }
    }
    for(EnemyShip enemyShip in destroyedEnemyShips){
      setState(() {
        enemyShips.remove(enemyShip);
      });
    }
    if(ship.life<=0){
      controller.dispose();
      dialog="DERROTA";
      endDialog();
    }//se acaba el juego con derrota

    if(enemyShips.isEmpty){
      controller.dispose();
      dialog="VICTORIA";
      endDialog();
    }//se acaba el juego con victoria

        prevTime=currentTime;
  }
  Future endDialog()=>showDialog(context: context,
      builder: (context)=>AlertDialog(
        title: Text(dialog,textAlign: TextAlign.center,),
        content: Column(
          children:[
            Text("Puntuación: $punt"),
          ],
        ),
        actions: [
          Expanded(child: ElevatedButton(
            child: Text("Volver al inicio"),
            onPressed: ()=>{
              Navigator.of(context).pop(),
              Navigator.of(context).pop()},
          )),

        ],
      )
  );
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
              Row(
                children:[

                  const Image(image: AssetImage('assets/images/Spaceship.gif'),
                      width:32,height: 32,alignment: Alignment.centerLeft),
                  Text("x ${ship.life}",style: const TextStyle(color: Colors.black,fontSize: 32)
                      ,textAlign: TextAlign.left),
                  Expanded(child: Text("Puntuación: $punt",style: const TextStyle(color: Colors.pinkAccent,fontSize: 32)
                      ,textAlign: TextAlign.right))
              ]),
              Container(
                color: Colors.black87,
                child: AspectRatio(
                  aspectRatio: worldSize.aspectRatio,
                  child: LayoutBuilder(
                      builder: (context,constraints){
                        Size unit= Size(
                            constraints.maxWidth/worldSize.width,
                            constraints.maxHeight/worldSize.height);
                        List<Widget> gameObjects=[];
                        gameObjects.add(ship.renderAnim(controller,unit));
                        gameObjects.addAll(
                            enemyShips.map((e) => e.renderAnim(controller, unit))
                        );
                        return Stack(children: gameObjects);
                      }
                  ),
                ),
              ),
              Row(children: [
                Expanded(child: MoveButton(key: const Key("arrow left"),
                    down: () =>{ship.goLeft=true,log("left down ${ship.goLeft}")},
                    up: () => {ship.goLeft=false,log("left up ${ship.goLeft}") },
                    icon: Icons.arrow_circle_left_sharp),
                ),
                Expanded(child: MoveButton(key : const Key("arrow right"),
                    down: () =>{ship.goRight=true,log("right down ${ship.goRight}")},
                    up: () =>{ship.goRight=false,log("right up ${ship.goRight}") },
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
  final void Function() down;
  final void Function() up;
  final IconData icon;

  const MoveButton({required Key key,required this.down,required this.up,required this.icon}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details)=>{ down()},
      onTapUp: (details)=> {up()},
      onTapCancel: up,
      child: Container(
        color: Colors.teal,
        child:Icon(
        icon,
        color: Colors.black,
        size: 64,
      ),
    ),
    );
  }
}