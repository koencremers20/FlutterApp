import 'package:flutter/rendering.dart';
import 'package:mqtt_client/fab_with_icons.dart';
import 'package:mqtt_client/fab_bottom_app_bar.dart';
import 'package:mqtt_client/layout.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt/mqtt_client.dart' as mqtt;
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

//test
void main() => runApp(MyApp());

enum FloatingButtonOptions { 
   Shutdown,
   PowerOn
}  

double _value = 0.0;
// String broker = '10.20.31.152';
String broker = '192.168.1.33';
  mqtt.MqttClient client;
  mqtt.ConnectionState connectionState;

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

   String _internetConnectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  PageController _pageController;
  int _page = 0;

  

  StreamSubscription subscription;

  TextEditingController topicController = TextEditingController();
  Set<String> topics = Set<String>();

  List<Message> messages = <Message>[];
  ScrollController messageController = ScrollController();
  bool disconnected;

  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  int _currentScene = -1;

@override
  void initState(){
    super.initState();
    _pageController = PageController();
     initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() {
            _internetConnectionStatus = result.toString();
            if(_internetConnectionStatus != "ConnectivityResult.none"){
              _connect();
            }
          });
        });
  }

   @override
  void dispose() {
    _pageController = PageController();
    _connectivitySubscription.cancel();
    subscription?.cancel();
   
    super.dispose();
  }

  void Ttimer() async {
    do{
      await _connect().catchError((e) async {
        print(e);
        print("not connecting");
        await _connect();
      });
    }while(disconnected);
  }

  void _selectedFab(int index) {
    final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
   setState(() {
     String _option;
      if(index == FloatingButtonOptions.Shutdown.index)
      {
        _option = '0';
      }
      if(index == FloatingButtonOptions.PowerOn.index)
      {
        _option = '1';
      }
       builder.addString(_option);
       print(_option);
       client.publishMessage(
        'power',
        mqtt.MqttQos.values[2],
        builder.payload
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    IconData connectionStateIcon;
    switch (client?.connectionState) {
      case mqtt.ConnectionState.connected:
        connectionStateIcon = Icons.cloud_done;
        break;
      case mqtt.ConnectionState.disconnected:
        connectionStateIcon = Icons.cloud_off;
        break;
      case mqtt.ConnectionState.connecting:
        connectionStateIcon = Icons.cloud_upload;
        break;
      case mqtt.ConnectionState.disconnecting:
        connectionStateIcon = Icons.cloud_download;
        break;
      case mqtt.ConnectionState.faulted:
        connectionStateIcon = Icons.error;
        break;
      default:
        connectionStateIcon = Icons.cloud_off;
    }
     void navigationTapped(int page) {
      _pageController.animateToPage(page,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }

    void onPageChanged(int page) {
      setState(() {
        this._page = page;
      });
    }
    return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            _buildHomePage(),
            _BuildSettingsPage(connectionStateIcon),
          ],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(
          context), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<Null> initConnectivity() async {
    String connectionStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _internetConnectionStatus = connectionStatus;
    });
  }

  Widget _buildFab(BuildContext context) {

  
    final icons = [Icons.power_settings_new, Icons.lightbulb_outline];
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy - icons.length * 35.0),
          child: FabWithIcons(
            icons: icons,
            onIconTapped: _selectedFab,
          ),
        );
      },
      child: FloatingActionButton(
        onPressed: () { },
        tooltip: 'Menu',
        child: Icon(Icons.menu),
        elevation: 5.0,
      ),
    );
  }

List<String> scenes=[
"Solid color", "Goodnight",
"Evening", "Bioscoop",
 "Goodnight","Solid color", 
 "Solid color", "Goodnight",
"Evening", "Bioscoop",
 "Goodnight","Solid color", 
];
    double _value = 50.0;

void _handleTap(BuildContext context, GlobalKey parentKey, int index) async {
if(_currentScene != index && connectionState == mqtt.ConnectionState.connected)
  {
    final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();

    builder.addString(scenes[index]);
    client.publishMessage(
      'scenes',
      mqtt.MqttQos.values[2],
      builder.payload
    );
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
              backgroundImage: ExactAssetImage('images/pic$index.jpg'),
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
              broker,
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(width: 8.0),
            Icon(connectionStateIcon),
          ],
        ),//test
        SizedBox(height: 8.0),
        RaisedButton(
          child: Text(client?.connectionState == mqtt.ConnectionState.connected
              ? 'Disconnect'
              : 'Connect'),
          onPressed: _internetConnectionStatus != "ConnectivityResult.none" ? () {
            if (client?.connectionState == mqtt.ConnectionState.connected) {
              _disconnect();
            } else {
              _connect();
            }
          } : null,
        ),
      ],
    );
    }

Future _connect() async {
    /// First create a client, the client is constructed with a broker name, client identifier
    /// and port if needed. The client identifier (short ClientId) is an identifier of each MQTT
    /// client connecting to a MQTT broker. As the word identifier already suggests, it should be unique per broker.
    /// The broker uses it for identifying the client and the current state of the client. If you don’t need a state
    /// to be hold by the broker, in MQTT 3.1.1 you can set an empty ClientId, which results in a connection without any state.
    /// A condition is that clean session connect flag is true, otherwise the connection will be rejected.
    /// The client identifier can be a maximum length of 23 characters. If a port is not specified the standard port
    /// of 1883 is used.
    /// If you want to use websockets rather than TCP see below.
    client = mqtt.MqttClient(broker, '');
    client.port = 1883;

    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    /// client.useWebSocket = true;
    /// client.port = 80;  ( or whatever your WS port is)
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.

    /// Set logging on if needed, defaults to off
    //client.logging(true);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 30;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = _onDisconnected;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId2')
        // Must agree with the keep alive set above or not set
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        // If you set this you must set a will message
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(mqtt.MqttQos.exactlyOnce);
    print('MQTT client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect();
    } on SocketException catch(_) {
      throw _;
    }

    /// Check if we are connected
    if (client.connectionState == mqtt.ConnectionState.connected) {
      print('MQTT client connected');
      setState(() {
        connectionState = client.connectionState;
        disconnected = false;
      });
    } else {
      print('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionState}');
      _disconnect();
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    subscription = client.updates.listen(_onMessage);
  }

  void _disconnect() {
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    setState(() {
       try{
        topics.clear();
        connectionState = client.connectionState;
        client = null;
        subscription.cancel();
        subscription = null;
      }
      on Exception catch(_)
      {

      }
    });
    print('MQTT client disconnected');
    setState(() {
      disconnected = true;
    });
    Ttimer();
  }

  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
        event[0].payload as mqtt.MqttPublishMessage;
    final String message =
        mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print('MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print(client.connectionState);
    setState(() {
      messages.add(Message(
        topic: event[0].topic,
        message: message,
        qos: recMess.payload.header.qos,
      ));
      try {
        messageController.animateTo(
          0.0,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } catch (_) {
        // ScrollController not attached to any scroll views.
      }
    });
  }

  void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.ConnectionState.connected) {
      setState(() {
        if (topics.add(topic.trim())) {
          print('Subscribing to ${topic.trim()}');
          client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
        }
      });
    }
  }

  void _unsubscribeFromTopic(String topic) {
    if (connectionState == mqtt.ConnectionState.connected) {
      setState(() {
        if (topics.remove(topic.trim())) {
          print('Unsubscribing from ${topic.trim()}');
          client.unsubscribe(topic);
        }
      });
    }
  }

}

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
                image: new ExactAssetImage('images/pic$index.jpg'),
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

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> height;
  bool display = true;

  @override
  void initState() {
    super.initState();
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
    
  void _setvalue(double value)
  {
     setState(() => _value = value);
    
    final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
    double _tempValue = _value * 100;
    builder.addString(_tempValue.round().toString());
    client.publishMessage(
      'scenes',
      mqtt.MqttQos.values[2],
      builder.payload
    );
  } 
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
              height: height.value,
              padding: const EdgeInsets.only(left: 8.0),
            ),
            PostHeader(
              title: widget.title,
              index: widget.index,
            ),
            Container(
              height: 256.0,
              alignment: Alignment.center,
              child: new Column(
                children: <Widget>[
                  new Text('Brightness: ${(_value * 100).round()}'),
                  new Slider(value: _value, onChanged: _setvalue),
                   
              ],
            ),
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

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
