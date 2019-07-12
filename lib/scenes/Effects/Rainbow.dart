import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt/mqtt.dart';
import 'package:flutter/cupertino.dart';

class Rainbow extends StatefulWidget {
  Rainbow({
    Key key,
    @required this.title,
    this.description,
  }) : super(key: key);
  final String title;
  final String description;

  @override
  _RainbowState createState() => _RainbowState(title, description);
}

class _RainbowState extends State<Rainbow>
    with SingleTickerProviderStateMixin {
  Mqtt mqtt;
  String title;
  String description;

  _RainbowState(String title, String description)
  {
    this.title = title;
    this.description = description;
  }
@override
  void initState() {
    super.initState();
     mqtt = new Mqtt();
    
  } 

  void onTap() {
    mqtt.sendMessage('Effect', title);
    showDialog(
      barrierDismissible: true,
      context: context,
      child: new AlertDialog(
        title: new Column(
          children: <Widget>[
            new Text(title),
          ],
        ),
        content: new Template(),
        actions: <Widget>[
          new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: new Text("OK")
          ),
          
        ],
      ));
  }

  @override
  Widget build(BuildContext context) {
    return new ListTile(
          title: new Card(
            elevation: 5.0,
            child: new Container(
              alignment: Alignment.centerLeft + Alignment(0,0),
              margin: new EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: new Text(title),
            ),
          ),
           onTap: () => onTap(),
    );
  }
  
}


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
  double brightness = 50;
//    Color color =Colors.blue;
// void onChanged(Color value) => this.color=value;
  // int value =0;
  // void onChanged(int value) => this.value=value;

@override
  void initState() {
    super.initState();
     mqtt = new Mqtt();

  }

  void sliderChanged(double value)
{
  setState(() => brightness = value);
  mqtt.sendMessage('brightness', brightness.round().toString());
}
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Container(
         child: Column(
            children: <Widget>[
        new Slider( 
          min: 0.0,
          max: 100.0,
          value: brightness, 
          onChanged: sliderChanged,
        ),
        ],
         )
        ),
    );
  }
  

  void play() {
    if (mounted) setState(() => display = true);
    controller.forward();
  }

  
}


