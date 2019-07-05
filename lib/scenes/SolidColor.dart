import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt/mqtt.dart';


double _value = 0.0;

class SolidColor extends StatefulWidget {
  SolidColor({
    Key key,
    this.title,
    this.index,
  }) : super(key: key);
  final String title;
  final int index;

  @override
  _SolidColorState createState() => _SolidColorState();
}

class _SolidColorState extends State<SolidColor>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> height;
  bool display = true;
  Mqtt mqtt;

@override
  void initState() {
    super.initState();
     mqtt = new Mqtt();

  }
  void _setBrightnessValue(double value)
  {
     setState(() => _value = value);
     double _tempValue = _value * 100;
     mqtt.sendMessage('slider',_tempValue.round().toString());
    
  } 
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 256.0,
              alignment: Alignment.center,
              // child: Text('test'),
              child: new Column(
                children: <Widget>[
                  new Text(widget.title),
                  new Text('Brightness: ${(_value * 100).round()}'),
                  new Slider(value: _value, onChanged: _setBrightnessValue),
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
