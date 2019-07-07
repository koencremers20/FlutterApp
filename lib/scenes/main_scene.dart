import 'package:flutter/rendering.dart';
import 'package:mqtt_client/mqtt/mqtt.dart';
import 'package:mqtt_client/mqtt/mqtt_client.dart' as mqtt;
import 'package:flutter/material.dart';
import 'package:mqtt_client/scenes/SolidColor.dart';
import 'package:mqtt_client/scenes/GoodNight.dart';
import 'package:mqtt_client/main.dart';

class PostHeader extends StatelessWidget {
  PostHeader({
    Key key,
    this.title,
    this.index,
    this.onTap,
  }) : super(key: key);

  final String title;
  final VoidCallback onTap;
   final int index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 156.0,
              decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new ExactAssetImage('images/pic$index.png'),
                fit: BoxFit.cover,
              ),
            ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class PostScreen extends StatefulWidget {
  PostScreen({
    Key key,
    this.title,
    this.index,
  }) : super(key: key);
  final String title;
  final int index;


  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> height;
  bool display = true;

  Mqtt mqtt;

 


  @override
  void initState() {
    super.initState();
     mqtt = new Mqtt();
     
    controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    height = Tween<double>(
      begin: 0.0,
      end: 80.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    ))
      ..addListener(() {
        setState(() {});
      });
    play();
  }
  
  final List<Widget> widgetList = [ 
    SolidColor(title: "Solid Color"),
    GoodNight(title: "Good night"),
    SolidColor(title: " Evening"),
    GoodNight(title: "Bioscoop"),
    SolidColor(title: "Morning"),
    SolidColor(title: "Effects"),

  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        controller.reverse();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
            
              
            ),
            PostHeader(
              title: widget.title,
              index: widget.index,
            ),
            Container(
              height: 450,
              alignment: Alignment.center,
              child: widgetList[widget.index],
              
        ),
          ]
      ),
    )
    );
  }
  

  void play() {
    if (mounted) setState(() => display = true);
    controller.forward();
  }

  
}
