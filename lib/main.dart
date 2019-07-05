import 'package:flutter/rendering.dart';
import 'package:mqtt_client/fab_with_icons.dart';
import 'package:mqtt_client/fab_bottom_app_bar.dart';
import 'package:mqtt_client/layout.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;
import 'package:flutter/material.dart';
import 'package:mqtt_client/models/message.dart';
import 'package:mqtt_client/dialogs/send_message.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as Math;
import 'package:collection/collection.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/utils.dart';
import 'package:mqtt_client/flutter_circular_chart.dart';
import 'package:mqtt_client/color_palette.dart';
import 'package:morpheus/morpheus.dart';
import 'package:mqtt_client/scenes/main_scene.dart';
import 'package:mqtt_client/mqtt/mqtt.dart';

//test
void main() => runApp(MyApp());

enum FloatingButtonOptions { 
   Shutdown,
   PowerOn
}  



class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koen''s App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: new MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

 PageController _pageController;
  int _page = 0;

  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  int _currentScene = -1;
  Mqtt mqtt;

@override
  void initState(){
    super.initState();
    _pageController = PageController();
    mqtt = new Mqtt();
    mqtt.connect();
    
  }

   @override
  void dispose() {
    _pageController = PageController();
    super.dispose();
  }

 
  // void _selectedFab(int index) {
  //   String _option = "";
  //   setState(() {
  //     if(index == FloatingButtonOptions.Shutdown.index)
  //     {
  //       _option = '0';
  //     }
  //     if(index == FloatingButtonOptions.PowerOn.index)
  //     {
  //       _option = '1';
  //     }      
  //   });
  //   mqtt.sendMessage('Power', _option);
  // }
  
  @override
  Widget build(BuildContext context) {
    IconData connectionStateIcon = mqtt.getConnectIcon();
    
     void navigationTapped(int page) {
      _pageController.animateToPage(page,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }

    void onPageChanged(int page) {
      setState(() {
        this._page = page;
      });
    }
    List<Widget> testwidgets = [
      _buildHomePage(),
      _BuildSettingsPage(connectionStateIcon)
    ];

    return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: testwidgets,
        ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: navigationTapped,
          currentIndex: _page,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: _buildFab(
      //     context), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // Widget _buildFab(BuildContext context) {

  
  //   final icons = [Icons.power_settings_new, Icons.lightbulb_outline];
  //   return AnchoredOverlay(
  //     showOverlay: true,
  //     overlayBuilder: (context, offset) {
  //       return CenterAbout(
  //         position: Offset(offset.dx, offset.dy - icons.length * 35.0),
  //         child: FabWithIcons(
  //           icons: icons,
  //           // onIconTapped: _selectedFab,
  //         ),
  //       );
  //     },
  //     child: FloatingActionButton(
  //       onPressed: () { },
  //       tooltip: 'Menu',
  //       child: Icon(Icons.menu),
  //       elevation: 5.0,
  //     ),
  //   );
  // }

List<String> scenes=[
"Solid color", "Good night",
"Evening", "Bioscoop",
 "Morning",
];

void _handleTap(BuildContext context, GlobalKey parentKey, int index) async {
if(_currentScene != index && mqtt.isConnected())
  {
    mqtt.sendMessage('scenes', scenes[index]);
   
    _currentScene = index;
  }
  Navigator.of(context).push(MorpheusPageRoute(
    builder: (context) => PostScreen(
            title: scenes[index],
            index: index,
      ),
    parentKey: parentKey,
    transitionToChild: false,
    )
  );
}

Widget _buildHomePage() {
return GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
  itemCount: scenes.length,
  itemBuilder: (context, index) {
    final _parentKey = GlobalKey();
    return ListTile(
      key: _parentKey,
      title: new Container(
        alignment: new FractionalOffset(0.0, 0.5),   
          child: CircleAvatar(
            backgroundImage: ExactAssetImage('images/pic$index.png'),
            minRadius: 60,
            maxRadius: 60,   
          ),
      ),
      subtitle: new Container(
        alignment: new FractionalOffset(0.35, -0.15),   
        child: Text(scenes[index])
      ),
      onTap: () => _handleTap(context, _parentKey, index),
    );
  },
);
}
    
    
Column _BuildSettingsPage(IconData connectionStateIcon) {
     return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              mqtt.mqttAddress(),
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(width: 8.0),
            Icon(connectionStateIcon),
          ],
        ),//test
        SizedBox(height: 8.0),
        RaisedButton(
          child: Text(mqtt.isConnected()
              ? 'Disconnect'
              : 'Connect'),
          onPressed: () {
            if (mqtt.isConnected()) {
              mqtt.disconnect();
            } else {
              mqtt.connect();
            }
          } 
        ),
      ],
    );
    }
}
