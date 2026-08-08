import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb; // Muhimu kwa ajili ya Web
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';

class ChatRoomScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatRoomScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  
  bool _isSending = false;

  // 1. Kazi ya kutuma ujumbe wa kawaida wa Maandishi
  void _sendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _setSending(true);
    String currentUserId = _auth.currentUser!.uid;
    String chatRoomId = _getChatRoomId(currentUserId, widget.receiverId);

    Map<String, dynamic> messageData = {
      'senderId': currentUserId,
      'receiverId': widget.receiverId,
      'message': text,
      'type': 'text', 
      'timestamp': FieldValue.serverTimestamp(),
    };

    _messageController.clear();

    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);
    } catch (e) {
      _showErrorSnackBar("Ujumbe haujatumwa: $e");
    } finally {
      _setSending(false);
    }
  }

  // 2. Kazi ya Kuchagua na Kutuma Picha au Video (Inafanya kazi Web na Simu)
  Future<void> _pickAndUploadMedia(ImageSource source, bool isVideo) async {
    if (_isSending) return;

    try {
      final XFile? pickedFile = isVideo 
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source, imageQuality: 70); 

      if (pickedFile == null) return; 

      _setSending(true);

      String currentUserId = _auth.currentUser!.uid;
      String chatRoomId = _getChatRoomId(currentUserId, widget.receiverId);
      
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String folder = isVideo ? 'chat_videos' : 'chat_images';
      
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_rooms')
          .child(chatRoomId)
          .child(folder)
          .child(fileName);

      UploadTask uploadTask;

      // Kikaguzi cha Mfumo: Kama ni Web au Kifaa cha Kawaida (Android)
      if (kIsWeb) {
        final Uint8List fileBytes = await pickedFile.readAsBytes();
        SettableMetadata metadata = SettableMetadata(
          contentType: isVideo ? 'video/mp4' : 'image/jpeg',
        );
        uploadTask = storageRef.putData(fileBytes, metadata);
      } else {
        File file = File(pickedFile.path);
        uploadTask = storageRef.putFile(file);
      }

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> messageData = {
        'senderId': currentUserId,
        'receiverId': widget.receiverId,
        'message': downloadUrl, 
        'type': isVideo ? 'video' : 'image', 
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);

    } catch (e) {
      _showErrorSnackBar("Imeshindwa kutuma faili: $e");
    } finally {
      _setSending(false);
    }
  }

  // 3. Menyu ya chini ya kuchagua Media pale "+" inapobonyezwa
  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Ionicons.image, color: Colors.green),
                title: const Text('Tuma Picha kutoka Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadMedia(ImageSource.gallery, false);
                },
              ),
              ListTile(
                leading: const Icon(Ionicons.camera, color: Colors.blue),
                title: const Text('Piga Picha na Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadMedia(ImageSource.camera, false);
                },
              ),
              ListTile(
                leading: const Icon(Ionicons.videocam, color: Colors.orange),
                title: const Text('Tuma Video kutoka Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadMedia(ImageSource.gallery, true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getChatRoomId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort();
    return ids.join("_");
  }

  void _setSending(bool val) {
    if (mounted) {
      setState(() {
        _isSending = val;
      });
    }
  }

  void _showErrorSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "...";
    DateTime dateTime = timestamp.toDate();
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;
    String chatRoomId = _getChatRoomId(currentUserId, widget.receiverId);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text("Muda Halisi (Live)", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Sehemu ya Kuonyesha Ujumbe (Live Stream)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chat_rooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Ionicons.chatbubbles_outline, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text("Anza mazungumzo na ${widget.receiverName}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, 
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    bool isMe = messageData['senderId'] == currentUserId;
                    Timestamp? time = messageData['timestamp'] as Timestamp?;
                    String msgType = messageData['type'] ?? 'text';
                    String content = messageData['message'] ?? '';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: msgType == 'text' 
                            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                            : const EdgeInsets.all(4), 
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF4CAF50) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
                          ],
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.70,
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (msgType == 'image')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  content,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(color: Colors.green),
                                    );
                                  },
                                  fit: BoxFit.cover,
                                ),
                              )
                            else if (msgType == 'video')
                              Container(
                                width: 200,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                child: const Center(
                                  child: Icon(Ionicons.play_circle, color: Colors.white, size: 50),
                                ),
                              )
                            else
                              Text(
                                content,
                                style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14.5),
                              ),
                            
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 2),
                              child: Text(
                                _formatTimestamp(time),
                                style: TextStyle(color: isMe ? Colors.white70 : Colors.black38, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Sehemu ya Chini: Input yenye Kitufe cha "+" na Send
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5, offset: const Offset(0, -2))]
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Ionicons.add_circle_outline, color: Colors.grey, size: 26),
                  onPressed: _isSending ? null : _showAttachmentMenu,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Andika ujumbe...",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF4CAF50),
                  radius: 22,
                  child: IconButton(
                    icon: _isSending 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Ionicons.send, color: Colors.white, size: 18),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}