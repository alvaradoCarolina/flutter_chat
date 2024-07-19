import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class UsernameScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('INGRESA TU NOMBRE '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Ingresa tu Usuario',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String username = _usernameController.text;
                if (username.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(username: username),
                    ),
                  );
                }
              },
              child: Text('Ingresar al Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String username;
  const ChatPage({Key? key, required this.username}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con Flutter'),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false, // Remove the back button if needed
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('messages').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var messageData = message.data() as Map<String, dynamic>;
                  var messageText = messageData['text'] ?? '';
                  var messageSender = messageData['sender'] ?? 'Unknown';
                  var messageLocation = messageData.containsKey('location')
                      ? '(${messageData['location']['latitude']}, ${messageData['location']['longitude']})'
                      : null;

                  var isCurrentUser = messageSender == widget.username;

                  var messageWidget = messageLocation != null
                      ? Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Card(
                            color: isCurrentUser ? Colors.blue[100] : Color.fromARGB(255, 241, 176, 225),
                            child: ListTile(
                              leading: Icon(Icons.location_on, color: Color.fromARGB(255, 14, 16, 155)),
                              title: Text('Location shared by $messageSender'),
                              subtitle: Text(messageLocation),
                            ),
                          ),
                        )
                      : Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Card(
                            color: isCurrentUser ? Colors.blue[100] : Color.fromARGB(255, 241, 176, 225),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('$messageSender: $messageText'),
                            ),
                          ),
                        );

                  messageWidgets.add(messageWidget);
                }
                return ListView(
                  reverse: true, // Show the latest message at the bottom
                  children: messageWidgets,
                );
              },
            ),
          ),
          Container(
            color: Color.fromARGB(255, 255, 255, 255), // Light grey background for the message input area
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.location_on),
                    onPressed: _sendLocation,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu Mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onSubmitted: (text) {
                        _sendMessage();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _firestore.collection('messages').add({
        'text': _controller.text,
        'sender': widget.username, // Use the username from the widget
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  void _sendLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _firestore.collection('messages').add({
        'text': 'Location shared',
        'sender': widget.username, // Use the username from the widget
        'timestamp': FieldValue.serverTimestamp(),
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      });
    } catch (e) {
      print('Failed to get location: $e');
    }
  }
}
