import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/models/message.dart';
import 'package:mqtt_client/mqtt/mqtt_client.dart' as mqtt;
import 'dart:async';
import 'dart:io';


  class Mqtt extends State{
    static final Mqtt _singleton = new Mqtt._internal();

    factory Mqtt() {
    return _singleton;
  }

    Mqtt._internal();
    static String broker = '10.20.31.152';
    // String broker = '192.168.1.33';
    static mqtt.MqttClient client;
    static   mqtt.ConnectionState connectionState;

    static  String _internetConnectionStatus = 'Unknown';
    static final Connectivity _connectivity = Connectivity();

    static List<Message> messages = <Message>[];
    static ScrollController messageController = ScrollController();
    static bool disconnected;

    void initMqtt() {
      initConnectivity();
      _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
        _internetConnectionStatus = result.toString();
        if(_internetConnectionStatus != "ConnectivityResult.none"){
          connect();
        }
      });
    }

    Future<Null> initConnectivity() async {
      String connectionStatus;
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        connectionStatus = (await _connectivity.checkConnectivity()).toString();
      } on Exception catch (e) {
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

    String getConnectionState(){
       return _connectivity.checkConnectivity().toString();
    }

    void Ttimer() async {
    do{
      await connect().catchError((e) async {
        print(e);
        print("not connecting");
        await connect();
      });
    }while(disconnected);
  }

    Future connect() async {
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
      client.onDisconnected = onDisconnected;

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
      } on Exception catch(_) {
        throw _;
      }

      /// Check if we are connected
      if (client.connectionState == mqtt.ConnectionState.connected) {
        print('MQTT client connected');
        
          connectionState = client.connectionState;
          disconnected = false;
       
      } else {
        print('ERROR: MQTT client connection failed - '
            'disconnecting, state is ${client.connectionState}');
        disconnect();
      }
    }

    void disconnect() {
      client.disconnect();
      onDisconnected();
    }

    void onDisconnected() {
      setState(() {
        try{
          connectionState = client.connectionState;
          client = null;
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

    void onMessage(List<mqtt.MqttReceivedMessage> event) {
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

    IconData getConnectIcon(){
      IconData connectionStateIcon = Icons.cloud_off;
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
      return connectionStateIcon;
    }

    bool isConnected() {
      if(connectionState == mqtt.ConnectionState.connected) return true;
      else return false;
    }

    String mqttAddress(){
      return broker;
    }

    Future sendMessage(String _topicContent, String _messageContent) async {
      final mqtt.MqttClientPayloadBuilder builder =
          mqtt.MqttClientPayloadBuilder();
     
      builder.addString(_messageContent);
      if(isConnected()) {
        client.publishMessage(
          _topicContent,
          mqtt.MqttQos.values[2],
          builder.payload,
          false,
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return null;
    }

}
