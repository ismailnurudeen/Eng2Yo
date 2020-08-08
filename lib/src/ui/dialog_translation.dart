import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:eng2yo/src/blocs/translate_bloc.dart';
import 'package:eng2yo/src/models/message.dart';
import 'package:eng2yo/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_audio_stream/url_audio_stream.dart';

class DialogTranslation extends StatefulWidget {
  @override
  _DialogTranslationState createState() => _DialogTranslationState();
}

class _DialogTranslationState extends State<DialogTranslation> {
  final TextEditingController _editingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> bubbleTexts = [
    Message(
        text:
            "Hi, I'm Karakata,I can translate whatever you say in English to yoruba.")
  ];
  final globalKey = GlobalKey<ScaffoldState>();
  bool _showProgress = false;
  StreamSubscription<ConnectivityResult> subscription;
  bool _hasInternetConnection;
  @override
  void initState() {
    bloc.translation.listen(
        (data) => setState(() {
              _showProgress = false;
              bubbleTexts.add(Message(text: data));
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
              print(data);
            }), onError: (error) {
      print("Error: " + error);
      _showProgress = false;
    });
    
// var connectivityResult = await (Connectivity().checkConnectivity());
// if (connectivityResult == ConnectivityResult.mobile) {
//   // I am connected to a mobile network.
// } else if (connectivityResult == ConnectivityResult.wifi) {
//   // I am connected to a wifi network.
// }
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        setState(() => _hasInternetConnection = true);
      } else {
        setState(() => _hasInternetConnection = false);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text("KÁRÀKÁTÀ"),
        actions: <Widget>[
          Visibility(
            visible: _showProgress,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: ListView.builder(
                controller: _scrollController,
                itemCount: bubbleTexts.length,
                itemBuilder: (context, index) {
                  return _buildBubble(context, index);
                }),
          ),
          _buildWordInput()
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context, int index) {
    var message = bubbleTexts[index];
    if (message.isTranslation) {
      return Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(4.0, 4.0, 8.0, 0.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green[200],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Text(message.text,
                  style: TextStyle(fontSize: 15, color: Colors.black)),
            ),
            Visibility(
              visible: index != 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.green[200],
                      child: IconButton(
                          icon: Icon(
                            Icons.hearing,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            _playTranslation(message.text);
                          }),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Listen",
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: EdgeInsets.fromLTRB(8.0, 4.0, 4.0, 4.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue[200],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      );
    }
  }

  _buildWordInput() {
    return Container(
        margin: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(50)),
        child: TextField(
          keyboardType: TextInputType.text,
          controller: _editingController,
          decoration: InputDecoration(
            hintText: "Type word to translate",
            prefixIcon: Icon(Icons.short_text),
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (_hasInternetConnection) {
                  var editTextContent = _editingController.text;
                  _editingController.clear();
                  if (editTextContent.isNotEmpty) {
                    bloc.fetchTranslation(editTextContent);
                    setState(() {
                      bubbleTexts.add(
                          Message(text: editTextContent, isTranslation: false));
                      _showProgress = true;
                    });
                  }
                } else {
                  globalKey.currentState.showSnackBar(SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("No internet connection"),
                        Icon(Icons.signal_cellular_connected_no_internet_4_bar,
                            color: Colors.red)
                      ],
                    ),
                  ));
                }
              },
            ),
            border: OutlineInputBorder(
                borderSide: BorderSide(style: BorderStyle.none, width: 0.0)),
          ),
        ));
  }

  _playTranslation(String text) async {
    if (_hasInternetConnection) {
      globalKey.currentState.showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Loading Voice: Please Wait..."),
            CircularProgressIndicator()
          ],
        ),
      ));
      var streamUrl = Utils.getAudioEndpoint(text);
      AudioStream stream = AudioStream(streamUrl);
      stream.start();
      print(streamUrl);
    } else {
      globalKey.currentState.showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("No internet connection"),
            Icon(Icons.signal_cellular_connected_no_internet_4_bar,
                color: Colors.red)
          ],
        ),
      ));
    }
  }
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
