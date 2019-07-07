import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt/mqtt.dart';

class Template extends StatefulWidget {
  Template({
    Key key,
    this.title,
    this.index,
  }) : super(key: key);
  final String title;
  final int index;

  @override
  _TemplateState createState() => _TemplateState();
}

class _TemplateState extends State<Template>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> height;
  bool display = true;
  Mqtt mqtt;
//    Color color =Colors.blue;
// void onChanged(Color value) => this.color=value;
  // int value =0;
  // void onChanged(int value) => this.value=value;

@override
  void initState() {
    super.initState();
     mqtt = new Mqtt();

  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
             
             
              // child: Text('test'),
              child: new Flex(
                direction: Axis.vertical,
                children: <Widget>[
                 
                   
                 
          

                ],
              ),
        ),
          ]
      ),
    );
  }
  

  void play() {
    if (mounted) setState(() => display = true);
    controller.forward();
  }

  
}
