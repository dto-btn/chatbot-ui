import 'package:chatbot_ui/messages.dart';
import 'package:flutter/material.dart';

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
                      sendMessage(_controller.text);
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

  sendMessage(String text) {
    bool isUser = true;
    if (isUser){
      setState(() {
        addMessage(text, isUser);
      });

      String response = "I don't understand...";
      isUser = false;
      setState(() {
        addMessage(response, isUser);
      });
    }
  }

  addMessage(String response, bool isUser) {
    messages.add({'msg': response, 'isUser': isUser});
  }
}
