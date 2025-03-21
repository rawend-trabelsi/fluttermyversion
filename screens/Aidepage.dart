import 'dart:convert'; // Pour utiliser jsonEncode et jsonDecode
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ThemeProvider.dart';
import 'Footer.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Aide Aghsalni App',
          theme: ThemeData(
            brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            primaryColor: Color(0xFF00BCD0),
            hintColor: Colors.tealAccent,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
            ),
          ),
          home: Aidepage(),
        );
      },
    );
  }
}

class Aidepage extends StatefulWidget {
  const Aidepage({Key? key}) : super(key: key);

  @override
  _AidepageState createState() => _AidepageState();
}

class _AidepageState extends State<Aidepage> {
  late Future<DialogFlowtter> _dialogFlowtterFuture;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> messages = [];
  bool _isTextFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _dialogFlowtterFuture = DialogFlowtter.fromFile(path: 'assets/chatbotapplavage-jmaa-b48342bd5f33.json');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isTextFieldFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Aide Aghsalni App",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.cyan,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 30,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.wb_sunny,
                size: 30,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<DialogFlowtter>(
        future: _dialogFlowtterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF00BCD0),
                  ),
                  SizedBox(height: 16),
                  Text("Chargement du chatbot..."),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text('Erreur d\'initialisation'),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text('Aucune donnée disponible'),
                ],
              ),
            );
          }

          final dialogFlowtter = snapshot.data!;

          return Column(
            children: [
              // Header banner with icons when no messages and text field is not focused
              if (messages.isEmpty && !_isTextFieldFocused)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  color: themeProvider.isDarkMode
                      ? Color(0xFF222222)
                      : Color(0xFFE8F5F8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFF00BCD0),
                        radius: 25,
                        child: Icon(
                          Icons.support_agent,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Assistant Aghsalni",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Comment puis-je vous aider aujourd'hui?",
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Message list and suggestions grid
              Expanded(
                child: Column(
                  children: [
                    // Afficher la grille d'icônes même s'il y a des messages
                    _buildSuggestionsGrid(dialogFlowtter, themeProvider.isDarkMode),
                    // Afficher la liste des messages
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var message = messages[index]['message'] as Message;
                          bool isUserMessage = messages[index]['isUserMessage'] as bool;
                          return EnhancedChatBubble(
                            message: message,
                            isUserMessage: isUserMessage,
                            isDarkMode: themeProvider.isDarkMode,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Message input bar
              Container(
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? Color(0xFF333333) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: "Écrivez votre message...",
                          hintStyle: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white60 : Colors.black38,
                          ),
                          filled: true,
                          fillColor: themeProvider.isDarkMode ? Color(0xFF444444) : Color(0xFFEEEEEE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendMessage(dialogFlowtter, _controller.text);
                        _controller.clear();
                      },
                      icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF00BCD0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Footer(
        currentIndex: 1,
        isDarkMode: themeProvider.isDarkMode,
        toggleTheme: themeProvider.toggleTheme,
        onTap: (index) {
          if (index != 1) {
            _navigateToScreen(context, index);
          }
        },
      ),
    );
  }

  Widget _buildSuggestionsGrid(DialogFlowtter dialogFlowtter, bool isDarkMode) {
    final suggestions = [
      {'icon': Icons.car_crash, 'text': 'Services de lavage'},
      {'icon': Icons.paid, 'text': 'Tarifs'},
      {'icon': Icons.access_time, 'text': 'Horaires'},
      {'icon': Icons.calendar_month, 'text': 'Rendez-vous'},
    ];

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: 80,
            color: Color(0xFF00BCD0).withOpacity(0.5),
          ),
          SizedBox(height: 20),
          Text(
            "Comment puis-je vous aider?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  sendMessage(dialogFlowtter, suggestions[index]['text'] as String);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF333333) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        suggestions[index]['icon'] as IconData,
                        color: Color(0xFF00BCD0),
                        size: 28,
                      ),
                      SizedBox(height: 8),
                      Text(
                        suggestions[index]['text'] as String,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/help');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  sendMessage(DialogFlowtter dialogFlowtter, String text) async {
    if (text.isEmpty) {
      print('Message is empty');
    } else {
      setState(() {
        addMessage(Message(text: DialogText(text: [text])), true);
      });

      DetectIntentResponse response = await dialogFlowtter.detectIntent(
          queryInput: QueryInput(text: TextInput(text: text)));
      if (response.message == null) return;
      setState(() {
        addMessage(response.message!);
      });
    }
  }

  addMessage(Message message, [bool isUserMessage = false]) {
    setState(() {
      messages.add({'message': message, 'isUserMessage': isUserMessage});
    });
  }
}

class EnhancedChatBubble extends StatelessWidget {
  final Message message;
  final bool isUserMessage;
  final bool isDarkMode;

  const EnhancedChatBubble({
    Key? key,
    required this.message,
    required this.isUserMessage,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String messageText = message.text!.text![0];

    // Define icon and content based on message content
    IconData? messageIcon;
    Color iconColor = isUserMessage ? Colors.white : Colors.blue;
    Widget content;

    // Message specific icons
    if (messageText.toLowerCase().contains("help") ||
        messageText.toLowerCase().contains("aide")) {
      messageIcon = Icons.help_outline;
      iconColor = Colors.orange;
    } else if (messageText.toLowerCase().contains("image")) {
      messageIcon = Icons.image;
      iconColor = Colors.green;
    } else if (messageText.toLowerCase().contains("prix") ||
        messageText.toLowerCase().contains("tarif")) {
      messageIcon = Icons.attach_money;
      iconColor = Colors.green;
    } else if (messageText.toLowerCase().contains("location") ||
        messageText.toLowerCase().contains("adresse")) {
      messageIcon = Icons.location_on;
      iconColor = Colors.red;
    } else if (messageText.toLowerCase().contains("rendez-vous") ||
        messageText.toLowerCase().contains("horaire")) {
      messageIcon = Icons.calendar_today;
      iconColor = Colors.blue;
    } else if (messageText.toLowerCase().contains("service") ||
        messageText.toLowerCase().contains("lavage")) {
      messageIcon = Icons.car_crash;
      iconColor = Colors.purple;
    } else if (isUserMessage) {
      messageIcon = Icons.person;
    } else {
      messageIcon = Icons.support_agent;
    }

    // Create the content with icon
    content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          messageIcon,
          size: 20,
          color: isUserMessage ? Colors.white : iconColor,
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            messageText,
            style: TextStyle(
              color: isUserMessage
                  ? Colors.white
                  : (isDarkMode ? Colors.white : Colors.black87),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUserMessage)
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF00BCD0),
              child: Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 18,
              ),
            ),

          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: isUserMessage ? 50 : 10,
                right: isUserMessage ? 10 : 50,
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? Color(0xFF00BCD0)
                    : (isDarkMode ? Color(0xFF2A2A2A) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: isUserMessage ? Radius.circular(18) : Radius.circular(0),
                  bottomRight: isUserMessage ? Radius.circular(0) : Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}