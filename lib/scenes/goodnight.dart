import 'package:flutter/rendering.dart';
import 'package:mqtt_client/mqtt/mqtt_client.dart' as mqtt;
import 'package:flutter/material.dart';


double _value = 0.0;

class GoodNight extends StatefulWidget {
  GoodNight({
    Key key,
    this.title,
    this.index,
  }) : super(key: key);
  final String title;
  final int index;

  @override
  _GoodNightState createState() => _GoodNightState();
}

class _GoodNightState extends State<GoodNight>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> height;
  bool display = true;
  

  void _setvalue(double value)
  {
     setState(() => _value = value);
    
    // final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
    // double _tempValue = _value * 100;
    // builder.addString(_tempValue.round().toString());
    // client.publishMessage(
    //   'scenes',
    //   mqtt.MqttQos.values[2],
    //   builder.payload
    // );
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

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  
}
