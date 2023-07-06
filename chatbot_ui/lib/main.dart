import 'dart:convert';

import 'package:chatbot_ui/messages.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSC Chatbot',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'SSC Chatbot'),
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
  final url = "http://127.0.0.1:5000/query";
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
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
      )
    );
  }

  sendMessage(String text, String url) async {
    bool isUser = true;
    setState(() {
      addMessage(text, isUser);
    });

    final postRequest = await http.post(Uri.parse(url), 
      body: jsonEncode(
        {
          "query": text,
          "temp": 0.7,
          "k": 3,
          "debug": 1 
        }
      ), 
      headers: {
        "Content-Type": "application/json"
      }
    );

    isUser = false;
    String sources = "";
    if (postRequest.statusCode == 200){
      var data = await jsonDecode(postRequest.body);
      for (var i in data['metadata'].keys){
         sources += data['metadata'][i]['url'] + "\n"; 
      }
      setState(() {
        addMessage(data['answer'], isUser);
      });
      setState(() {
        addMessage("Sources:\n" + sources, isUser);
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
