import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt/mqtt.dart';

import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
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
const String MIN_DATETIME = '2010-05-12 00:00';
const String MAX_DATETIME = '2021-11-25 23:59';
DateTime INIT_DATETIME = new DateTime.now();

class _GoodNightState extends State<GoodNight>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> height;
  bool display = true;
  Mqtt mqtt;
  Duration timer = const Duration();
  DateTime _dateTime;
  String _format = 'HH:mm';
  TextEditingController _formatCtrl = TextEditingController();

//    Color color =Colors.blue;
// void onChanged(Color value) => this.color=value;
  // int value =0;
  // void onChanged(int value) => this.value=value;

@override
  void initState() {
    super.initState();
     mqtt = new Mqtt();
      _dateTime = INIT_DATETIME;

  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Text('Selected time : ${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.title
              ),
            new RaisedButton(
              elevation: 4.0,
              onPressed: () => _showTimePicker(),
              textColor: Colors.white,
              color: Colors.grey,
              padding: const EdgeInsets.all(15.0),
              child: new Text(
                "Set time",
              ),
            ),
            
           new Divider(),
           new RaisedButton(
              elevation: 4.0,
              onPressed: () => _turnAllLightsOff(),
              textColor: Colors.white,
              color: Colors.grey,
              padding: const EdgeInsets.all(15.0),
              child: new Text(
                "Turn all off",
              ),
            ),
          ],
        ),     
    );
  }
  
  void _turnAllLightsOff()
  {
    mqtt.sendMessage('lights/test', 'Off');
  }

  void play() {
    if (mounted) setState(() => display = true);
    controller.forward();
  }

   void _showTimePicker() {
    DatePicker.showDatePicker(
      context,
      minDateTime: DateTime.parse(MIN_DATETIME),
      maxDateTime: DateTime.parse(MAX_DATETIME),
      initialDateTime: INIT_DATETIME,
      dateFormat: _format,
      pickerMode: DateTimePickerMode.time, // show TimePicker
      pickerTheme: DateTimePickerTheme(
        title: Container(
          decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
          width: double.infinity,
          height: 56.0,
          alignment: Alignment.center,
          child: Text(
            'Choose a time',
            style: TextStyle(color: Colors.grey, fontSize: 24.0),
          ),
        ),
        titleHeight: 56.0,
      ),
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
          mqtt.sendMessage('time/off', _dateTime.toString());
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
        
      },
    );
}
}
