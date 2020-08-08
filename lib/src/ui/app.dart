import 'package:eng2yo/src/blocs/translate_bloc.dart';
import 'package:eng2yo/src/ui/dialog_translation.dart';
import 'package:eng2yo/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_audio_stream/url_audio_stream.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "KÁRÀKÁTÀ",
      theme: ThemeData(primaryColor: Colors.green),
      home: DialogTranslation(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _editingController = TextEditingController();
  String _translation = "";
  bool _showSpeaker = false;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text("KÁRÀKÁTÀ"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder(
              stream: bloc.translation,
              builder: (context, AsyncSnapshot<String> snapshot) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() => _translation = snapshot?.data ?? "");
                });

                if (snapshot.hasError) {
                  return Text("An error occurred: " + snapshot.error);
                } else if (snapshot.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() => _showSpeaker = true);
                  });

                  return _buildTranslatedTextView();
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Translate from English to yoruba.",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                );
              }),
          SizedBox(
            height: 16,
          ),
          _buildWordInput(),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 44),
            child: OutlineButton(
              onPressed: () {
                if (_editingController.text.isNotEmpty) {
                  globalKey.currentState.showSnackBar(SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Translating..."),
                        CircularProgressIndicator()
                      ],
                    ),
                  ));
                  bloc.fetchTranslation(_editingController.text);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.translate),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text("Translate", style: TextStyle(fontSize: 16))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildWordInput() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(50)),
        child: TextField(
          keyboardType: TextInputType.text,
          controller: _editingController,
          decoration: InputDecoration(
            hintText: "Type word to translate",
            prefixIcon: Icon(Icons.short_text),
            border: OutlineInputBorder(
                borderSide: BorderSide(style: BorderStyle.none, width: 0.0)),
          ),
        ));
  }

  _buildTranslatedTextView() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(_translation,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16),
          Visibility(
            visible: _showSpeaker,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.green,
              child: IconButton(
                  icon: Icon(
                    Icons.hearing,
                    color: Colors.white,
                  ),
                  onPressed: () => _playTranslation()),
            ),
          )
        ],
      ),
    );
  }

  _playTranslation() async {
    globalKey.currentState.showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("Loading Voice: Please Wait..."),
          CircularProgressIndicator()
        ],
      ),
    ));
    var streamUrl = Utils.getAudioEndpoint(_translation);
    AudioStream stream = AudioStream(streamUrl);
    stream.start();
    print(streamUrl);
  }
}
