import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt/mqtt.dart';

import 'flutter_hsvcolor_picker.dart';


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
//    Color color =Colors.blue;
// void onChanged(Color value) => this.color=value;
  // int value =0;
  // void onChanged(int value) => this.value=value;
double brightness = 50;
Color color = Colors.black;
void sliderChanged(double value)
{
  brightness = value;
  mqtt.sendMessage('brigtness', brightness.toString());
}
void onChanged(Color color) {
    this.color = color;
    print(color);
    
    mqtt.sendMessage('Color', color.red.toString() + " " + color.green.toString() +" " + color.blue.toString());
}

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
                 
                   new RGBPicker(
                  color: this.color,
                  onChanged: (value)=>super.setState(()=>this.onChanged(value)),
                  ),
                  //                   new PaletteValuePicker(
                  //                   color: this.color,
                  //                   onChanged: (value)=>super.setState(()=>this.onChanged(value)),
                  // ),
                  new Divider(),
                  new Slider(value: brightness, onChanged: sliderChanged,),
                  // new WheelPicker(
                  //               color: this.color,
                  //               onChanged: (value) =>
                  //                   super.setState(() => this.onChanged(value)),
                  // ),
                  // // new RGBPicker(
                  //     color: this.color,
                  //     onChanged: (value)=>super.setState(()=>this.onChanged(value)),
                  // ),
                  new Divider(),
                 
          

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
