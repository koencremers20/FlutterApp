import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt/mqtt.dart';
import 'package:mqtt_client/scenes/Effects/Rainbow.dart';


class EffectsPage extends StatefulWidget {
  EffectsPage({
    Key key,
    this.title,
    this.index,
  }) : super(key: key);
  final String title;
  final int index;

  @override
  _EffectsState createState() => _EffectsState();
}

class _EffectsState extends State<EffectsPage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> height;
  bool display = true;
  Mqtt mqtt;
  final List<Widget> effectList = [ 
    Rainbow(title: 'Rainbow', description: 'Rainbow'),
     Rainbow(title: 'test2', description: 'Rainbow'),
  ];

@override
  void initState() {
    super.initState();
     mqtt = new Mqtt();
  }
 
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        child: new ListView.builder(
          padding: new EdgeInsets.all(2.0),
          itemCount: effectList.length,
          itemBuilder: (BuildContext context, int index) {
            return effectList[index];
          }
        )          
      ),
    );
  }
    

  

  void play() {
    if (mounted) setState(() => display = true);
    controller.forward();
  }

  
}
