import 'dart:convert';

import 'package:chatbot_ui/messages.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/link.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azure Open AI Chatbot',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Azure Open AI Chatbot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final url = "http://localhost:5000/query";
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool? pretty = false;
  bool isFr = false;
  String isFrTxt = "French";
  String lang = "en";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          ElevatedButton(
            child: Text(isFrTxt),
            onPressed: (){
              setState(() {
                isFr = !isFr;
                if(isFr){
                  lang = "fr";
                  isFrTxt = "English";
                } else {
                  lang = "en";
                  isFrTxt = "French";
                }
              });
            }, 
          ),
          Text("Chat History"),
          Checkbox(
            value: pretty, 
            onChanged: (bool? newValue){
              setState(() {
                pretty = newValue;
              });
            }
          ),
          Link(
            target: LinkTarget.blank,
            uri: Uri.parse('https://forms.office.com/r/dPvsZykMSy'),
            builder: (context, followLink) => ElevatedButton(
              onPressed: followLink, 
              child: Text('Feedback')
            )
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
                Colors.blue.shade100.withOpacity(0.4),
                Colors.purple.shade100.withOpacity(0.4)
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: MessagesScreen(messages: messages)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: Colors.deepPurple,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration.collapsed(
                          hintText: "Ask a question...", 
                          hintStyle: TextStyle(color: Colors.white), 
                      ),
                    )
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage(_controller.text, url);
                      _controller.clear();
                    }, 
                    icon: Icon(Icons.send),
                    color: Colors.white
                  )
                ],
              )
            )
          ],
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work),
            label: "Channels",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  sendMessage(String text, String url) async {
    bool isUser = true;
    setState(() {
      addMessage(text, isUser);
    });
    debugPrint(text);
    final postRequest = await http.post(Uri.parse(url), 
      body: jsonEncode(
        {
          "query": text,
          "temp": 0.7,
          "k": 3,
          "debug": 1, 
          "lang": lang,
          "pretty": pretty
        }
      ), 
      encoding: Encoding.getByName("utf-8"),
      headers: {
        "Content-Type": "application/json"
      }
    );
    
    isUser = false;
    String str_sources = "";
    if (postRequest.statusCode == 200){
      var data = await jsonDecode(postRequest.body);
      for (var i in data['metadata'].keys){
        str_sources += data['metadata'][i]['url'] + "\n"; 
      }
      setState(() {
        addMessage(data['answer'], isUser);
      });
      setState(() {
        addMessage("Sources:\n" + str_sources, isUser);
      });
    } else {
      setState(() {
        addMessage("API is currently down...", false);
      });
    }
  }

  addMessage(String response, bool isUser) {
    messages.add({'msg': response, 'isUser': isUser});
  }
}
