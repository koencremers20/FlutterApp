/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 10/07/2017
 * Copyright :  S.Hamblett
 */

part of mqtt_client;

/// The client disconnect callback type
typedef DisconnectCallback = void Function();

/// A client class for interacting with MQTT Data Packets
class MqttClient {
  /// Initializes a new instance of the MqttClient class using the default Mqtt Port.
  /// The server hostname to connect to
  /// The client identifier to use to connect with
  MqttClient(this.server, this.clientIdentifier) {
    this.port = Constants.defaultMqttPort;
  }

  /// Initializes a new instance of the MqttClient class using the supplied Mqtt Port.
  /// The server hostname to connect to
  /// The client identifier to use to connect with
  /// The port to use
  MqttClient.withPort(this.server, this.clientIdentifier, this.port);

  String server;
  int port;
  String clientIdentifier;

  /// If set use a websocket connection, otherwise use the default TCP one
  bool useWebSocket = false;

  /// If set use a secure connection, note TCP only, do not use for
  /// secure websockets(wss).
  bool secure = false;

  /// Trusted certificate file path for use in secure working
  String trustedCertPath;

  /// The certificate chain path for secure working.
  String certificateChainPath;

  /// Private key file path
  String privateKeyFilePath;

  /// Private key file pass phrase
  String privateKeyFilePassphrase;

  /// The Handler that is managing the connection to the remote server.
  MqttConnectionHandler _connectionHandler;

  /// The subscriptions manager responsible for tracking subscriptions.
  SubscriptionsManager _subscriptionsManager;

  /// Handles the connection management while idle.
  MqttConnectionKeepAlive _keepAlive;

  /// Keep alive period, seconds
  int keepAlivePeriod = Constants.defaultKeepAlive;

  /// Handles everything to do with publication management.
  PublishingManager _publishingManager;

  /// Gets the current connection state of the Mqtt Client.
  ConnectionState get connectionState => _connectionHandler != null
      ? _connectionHandler.connectionState
      : ConnectionState.disconnected;

  /// The connection message to use to override the default
  MqttConnectMessage connectionMessage;

  /// Client disconnect callback, called on unsolicited disconnect.
  DisconnectCallback onDisconnected;

  /// Subscribed callback, function returns a void and takes a
  /// string parameter, the topic that has been subscribed to.
  SubscribeCallback _onSubscribed;

  SubscribeCallback get onSubscribed => _onSubscribed;

  set onSubscribed(SubscribeCallback cb) {
    _onSubscribed = cb;
    _subscriptionsManager?.onSubscribed = cb;
  }

  /// Unsubscribed callback, function returns a void and takes a
  /// string parameter, the topic that has been unsubscribed.
  UnsubscribeCallback _onUnsubscribed;

  UnsubscribeCallback get onUnsubscribed => _onUnsubscribed;

  set onUnsubscribed(UnsubscribeCallback cb) {
    _onUnsubscribed = cb;
    _subscriptionsManager?.onUnsubscribed = cb;
  }

  /// The event bus
  events.EventBus _clientEventBus = new events.EventBus();

  /// The change notifier on which all subscribed topic updates are published to
  Stream<List<MqttReceivedMessage>> updates;

  /// Performs a synchronous connect to the message broker with an optional username and password
  /// for the purposes of authentication.
  Future connect([String username, String password]) async {
    if (username != null) {
      MqttLogger.log(
          "Authenticating with username '{$username}' and password '{$password}'");
      if (username.trim().length >
          Constants.recommendedMaxUsernamePasswordLength) {
        MqttLogger.log(
            "Username length (${username.trim().length}) exceeds the max recommended in the MQTT spec. ");
      }
    }
    if (password != null &&
        password.trim().length >
            Constants.recommendedMaxUsernamePasswordLength) {
      MqttLogger.log(
          "Password length (${password.trim().length}) exceeds the max recommended in the MQTT spec. ");
    }
    _connectionHandler = SynchronousMqttConnectionHandler(_clientEventBus);
    if (useWebSocket) {
      _connectionHandler.secure = false;
      _connectionHandler.useWebSocket = true;
    }
    if (secure) {
      _connectionHandler.secure = true;
      _connectionHandler.useWebSocket = false;
      _connectionHandler.trustedCertPath = trustedCertPath;
      _connectionHandler.certificateChainPath = certificateChainPath;
      _connectionHandler.privateKeyFilePath = privateKeyFilePath;
      _connectionHandler.privateKeyFilePassphrase = privateKeyFilePassphrase;
    }
    _connectionHandler.onDisconnected = onDisconnected;
    _publishingManager = PublishingManager(_connectionHandler, _clientEventBus);
    _subscriptionsManager = SubscriptionsManager(
        _connectionHandler, _publishingManager, _clientEventBus);
    _subscriptionsManager.onSubscribed = onSubscribed;
    _subscriptionsManager.onUnsubscribed = onUnsubscribed;
    updates = _subscriptionsManager.subscriptionNotifier.changes;
    _keepAlive = MqttConnectionKeepAlive(_connectionHandler, keepAlivePeriod);
    final connectMessage = _getConnectMessage(username, password);
    return await _connectionHandler.connect(
        this.server, this.port, connectMessage);
  }

  ///  Gets a pre-configured connect message if one has not been supplied by the user.
  ///  Returns an MqttConnectMessage that can be used to connect to a message broker
  MqttConnectMessage _getConnectMessage(String username, String password) {
    if (connectionMessage == null) {
      connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientIdentifier)
          // Explicitly set the will flag
          .withWillQos(MqttQos.atMostOnce)
          .keepAliveFor(Constants.defaultKeepAlive)
          .authenticateAs(username, password)
          .startClean();
    }
    return connectionMessage;
  }

  /// Initiates a topic subscription request to the connected broker with a strongly typed data processor callback.
  /// The topic to subscribe to.
  /// The qos level the message was published at.
  /// Returns the subscription.
  /// Raises InvalidTopicException If a topic that does not meet the MQTT topic spec rules is provided.
  Subscription subscribe(String topic, MqttQos qosLevel) {
    if (connectionState != ConnectionState.connected) {
      throw ConnectionException(_connectionHandler.connectionState);
    }
    return _subscriptionsManager.registerSubscription(topic, qosLevel);
  }

  /// Publishes a message to the message broker.
  /// Returns The message identifer assigned to the message.
  /// Raises InvalidTopicException if the topic supplied violates the MQTT topic format rules.
  int publishMessage(
      String topic, MqttQos qualityOfService, typed.Uint8Buffer data,
      [bool retain = false]) {
    if (_connectionHandler.connectionState != ConnectionState.connected) {
      throw ConnectionException(_connectionHandler.connectionState);
    }
    try {
      final PublicationTopic pubTopic = PublicationTopic(topic);
      return _publishingManager.publish(
          pubTopic, qualityOfService, data, retain);
    } catch (Exception) {
      throw InvalidTopicException(Exception.toString(), topic);
    }
  }

  /// Unsubscribe from a topic
  void unsubscribe(String topic) {
    _subscriptionsManager.unsubscribe(topic);
  }

  /// Gets the current status of a subscription.
  SubscriptionStatus getSubscriptionsStatus(String topic) {
    return _subscriptionsManager.getSubscriptionsStatus(topic);
  }

  /// Disconnect from the broker
  void disconnect() {
    _connectionHandler?.disconnect();
    _publishingManager = null;
    _subscriptionsManager = null;
    _keepAlive?.stop();
    _keepAlive = null;
    _connectionHandler = null;
    _clientEventBus.destroy();
  }

  /// Turn on logging, true to start, false to stop
  void logging(bool on) {
    MqttLogger.loggingOn = false;
    if (on) {
      MqttLogger.loggingOn = true;
    }
  }

  /// Set the protocol version to V3.1 - default
  void setProtocolV31() {
    Protocol.version = Constants.mqttV31ProtocolVersion;
    Protocol.name = Constants.mqttV31ProtocolName;
  }

  /// Set the protocol version to V3.1.1
  void setProtocolV311() {
    Protocol.version = Constants.mqttV311ProtocolVersion;
    Protocol.name = Constants.mqttV311ProtocolName;
  }
}
