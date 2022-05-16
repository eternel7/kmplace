import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeApp extends StatelessWidget {
  const HomeApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('fr', ''), // French, no country code
      ],
      home: SocketObject(),
    );
  }
}

class SocketObject extends StatefulWidget {
  const SocketObject({Key key}) : super(key: key);
  @override
  SocketObjectState createState() => SocketObjectState();
}

class SocketObjectState extends State<SocketObject> with WidgetsBindingObserver {
  String _status;
  SocketUtil _socketUtil;
  List _messages;
  TextEditingController _textEditingController;
  int userSelected = 1;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _status = "";
    _messages = [];
    _socketUtil = SocketUtil();
    _socketUtil.initSocket(connectListener, messageListener);
  }

  @override
  void dispose() {
    if(_socketUtil is SocketUtil && _socketUtil._socket is Socket) {
      print('dispose / disconnect');
      _socketUtil._socket.emit('left',{'msg': 'bye'});
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(
                      5.0,
                    ),
                  ),
                ),
                filled: true,
                fillColor: Colors.white60,
                contentPadding: EdgeInsets.all(15.0),
                hintText: AppLocalizations.of(context).enterMessage,
              ),
            ),
            OutlinedButton(
              child: Text(AppLocalizations.of(context).sendMessage),
              onPressed: () {
                if (_textEditingController.text.isEmpty) {
                  return;
                }
                _socketUtil.sendMessage(_textEditingController.text).then(
                      (bool messageSent) {
                    if (messageSent) {
                      _textEditingController.text = "";
                    }
                  },
                );
              },
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(_status),
            SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: null == _messages ? 0 : _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text(
                    utf8.decode(_messages[index].cast<int>()),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void messageListener(List<dynamic> message) {
    print('Adding message');
    setState(() {
      _messages.add(message);
    });
  }

  void connectListener(bool connected) {
    setState(() {
      _status = "Status: " + (connected ? "Connected" : "Failed to Connect");
    });
  }
}

class SocketUtil {
  Socket _socket;
  bool socketInit = false;
  static const String SERVER_ADR = "http://localhost:5000/chat";
  String _currentRoom = "room";

  String getCurrentRoom() {
    return _currentRoom;
  }

  Future<bool> sendMessage(String message) async {
    try {
      _socket.emit('msg', {'msg': utf8.encode(message)});
    } catch (e) {
      print(e.toString());
      return false;
    }
    return true;
  }

  Future<bool> initSocket(
      Function connectListener, Function messageListener) async {
    try {
      print('Connecting to socket');
      _socket = io(SERVER_ADR,
          OptionBuilder()
              .setTransports(['websocket']).build());
      _socket.connect();
      _socket.onConnect((_) {
        print('connect');
        _socket.emit('joined', {});
        connectListener(true);
      });
      _socket.on('event', (data) {
        print('event');
        print(data);
      });
      _socket.on('connected', (data) {
        print('connected');
        print(data);
      });
      _socket.on('status', (_) {
        print('status');
        print(_);
      });
      _socket.on('message', (_) {
        print('message');
        print(_);
        messageListener(_['msg']);
      });
      _socket.onDisconnect((_) {
        print('disconnect');
        _socket.emit('left',{'msg': 'bye'});
      });
      socketInit = true;
    } catch (e) {
      print(e.toString());
      connectListener(false);
      return false;
    }
    return true;
  }
}

void main() {
  runApp(
    const HomeApp(),
  );
}