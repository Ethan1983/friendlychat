import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(FriendlyChatApp());

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

class FriendlyChatApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Friendlychat',
        theme: defaultTargetPlatform == TargetPlatform.iOS ? kIOSTheme :kDefaultTheme,
        home: ChatScreen());
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _messages.forEach((message) => message.animationController.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friendlychat'),
      elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,),
      body: _buildChatScreen(),
    );
  }

  Widget _buildChatScreen() {
    return Column(
      children: <Widget>[
        Expanded(
          child: _buildChatScreenList(),
        ),
        Divider(height: 1.0),
        _buildThemedTextComposer()
      ],
    );
  }

  Widget _buildChatScreenList() {
    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (_, index) => _messages[index],
    );
  }

  Widget _buildThemedTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: _buildTextComposer(),
    );
  }

  Widget _buildTextComposer() {
    return Container(
        decoration: new BoxDecoration(color: Theme.of(context).cardColor),
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _textController,
                onChanged: _handleTextChange,
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: "Send a message"),
              ),
            )),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Theme.of(context).platform ==TargetPlatform.iOS ? 
              CupertinoButton(
                child: new Text("Send"),
                onPressed: _isComposing ? () => _handleSubmitted(_textController.text) : null,
              ):
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _isComposing ? () => _handleSubmitted(_textController.text) : null,
              )              ,
            )
          ],
        ));
  }

  void _handleTextChange(String text) {
    setState(() {
      _isComposing = text.isNotEmpty;
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    final message = ChatMessage(
        message: text,
        animationController: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
        ));
    setState(() {
      _messages.insert(0, message);
      _isComposing = false;
    });
    message.animationController.forward();
  }
}

const String _name = "Your Name";

class ChatMessage extends StatelessWidget {
  final String message;
  final AnimationController animationController;

  ChatMessage({this.message, this.animationController});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        sizeFactor:
            CurvedAnimation(parent: animationController, curve: Curves.linearToEaseOut),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
          child: Row(children: <Widget>[
            CircleAvatar(
              child: Text(_name[0]),
            ),
            Expanded(
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_name, style: Theme.of(context).textTheme.subhead),
                        Text(message),
                      ],
                    )))
          ]),
        ));
  }
}
