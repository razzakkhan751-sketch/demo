import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';

class AITutorScreen extends StatefulWidget {
  final String? courseContext;
  const AITutorScreen({super.key, this.courseContext});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  // Unified Access via OpenRouter (OpenAI Compatible)
  static const String _apiKey =
      "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";
  static const String _modelUrl =
      "https://openrouter.ai/api/v1/chat/completions";
  // Free tier model
  static const String _modelName = "mistralai/mistral-7b-instruct:free";

  @override
  void initState() {
    super.initState();
    String greeting =
        "Hello! I am your AI Coding Mentor. I can help debug code, explain concepts, and suggest improvements. Ask me anything!";

    if (widget.courseContext != null) {
      greeting =
          "Hello! I am your AI Mentor for **${widget.courseContext}**. Ask me any questions about this course!";
    }

    _addMessage(greeting, "system", "AI Tutor");
  }

  void _addMessage(String text, String senderId, String senderName) {
    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          senderId: senderId,
          senderName: senderName,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _addMessage(text, "user", "You");

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_modelUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://elearning.app",
          "X-Title": "E-Learning App",
        },
        body: jsonEncode({
          "model": _modelName,
          "messages": [
            {
              "role": "system",
              "content": widget.courseContext != null
                  ? "You are an expert Coding Tutor for the course: ${widget.courseContext}. Answer clearly and concisely."
                  : "You are an expert Coding Tutor. Answer clearly and concisely.",
            },
            {"role": "user", "content": text},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        if (result['choices'] != null && result['choices'].isNotEmpty) {
          final content = result['choices'][0]['message']['content'];
          _addMessage(content ?? "No response content.", "ai", "AI Tutor");
        } else {
          _addMessage("Empty response from AI.", "ai", "AI Tutor");
        }
      } else {
        _addMessage(
          "Error: ${response.statusCode}. Please try again later.",
          "ai",
          "AI Tutor",
        );
        debugPrint("AI Error: ${response.body}");
      }
    } catch (e) {
      _addMessage("Connection Error: $e", "ai", "AI Tutor");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Mentor (Unified Access)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addMessage(
                  "Hello! I am your AI Coding Mentor. Ask me anything!",
                  "system",
                  "AI Tutor",
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.senderId == 'user';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser)
                        CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.smart_toy,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isUser ? 20 : 0),
                              bottomRight: Radius.circular(isUser ? 0 : 20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isUser
                              ? Text(
                                  msg.text,
                                  style: const TextStyle(color: Colors.white),
                                )
                              : MarkdownBody(
                                  data: msg.text,
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(color: Colors.black87),
                                    code: TextStyle(
                                      color: Colors.red[800],
                                      backgroundColor: Colors.red[50],
                                      fontFamily: 'monospace',
                                    ),
                                    codeblockDecoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isUser)
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  offset: const Offset(0, -5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Ask a coding question...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
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
