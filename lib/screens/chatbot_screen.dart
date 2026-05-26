import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../config/storage_helper.dart';
import '../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  // ── State
  bool _isPanelOpen = false;
  bool _isDeleteMode = false;
  bool _isLoading = false;
  String _currentChatId = '';
  String _prenom = '';

  @override
  void initState() {
    super.initState();
    _loadPrenom();
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    try {
      final chats = await ChatbotService.getChats();

      setState(() {
        _histories.clear();

        _histories.addAll(
          chats.map(
            (e) => _ChatHistory(
              id: e['_id'].toString(),
              title: e['title'] ?? 'Nouvelle discussion',
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Failed loading chats: $e');
    }
  }

  Future<void> _loadPrenom() async {
    final prenom = await StorageHelper.getPrenom();
    setState(() => _prenom = prenom ?? '');
  }

  final List<_ChatHistory> _histories = [];

  // ── Messages for current chat
  final Map<String, List<_Message>> _chatMessages = {};

  // ── Selected chats for deletion
  final Set<String> _selectedForDelete = {};

  // ── Search
  List<_ChatHistory> get _filteredHistories {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _histories;
    return _histories.where((h) => h.title.toLowerCase().contains(q)).toList();
  }

  List<_Message> get _currentMessages => _chatMessages[_currentChatId] ?? [];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Send message
  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    _inputCtrl.clear();

    setState(() {
      _chatMessages.putIfAbsent(_currentChatId, () => []);

      _chatMessages[_currentChatId]!.add(
        _Message(text: text, isUser: true, time: _nowTime()),
      );

      _isLoading = true;
    });

    _scrollToBottom();

    try {
      Map<String, dynamic> response;

      // first message -> create thread
      if (_currentChatId.isEmpty) {
        response = await ChatbotService.startChat(text);

        final threadId = response['thread_id'].toString();

        _currentChatId = threadId;

        _histories.insert(
          0,
          _ChatHistory(
            id: threadId,
            title: text.length > 20 ? text.substring(0, 20) : text,
          ),
        );
      } else {
        response = await ChatbotService.sendMessage(
          threadId: _currentChatId,
          prompt: text,
        );
      }

      final aiReply =
          response['response'] ?? response['message'] ?? 'Pas de réponse';

      setState(() {
        _chatMessages[_currentChatId]!.add(
          _Message(text: aiReply, isUser: false, time: _nowTime()),
        );

        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;

        _chatMessages[_currentChatId]!.add(
          _Message(
            text: 'Erreur de connexion au chatbot',
            isUser: false,
            time: _nowTime(),
          ),
        );
      });
    }
  }

  // ── Quick chip tapped
  void _sendQuickMessage(String text) {
    _inputCtrl.text = text;
    _sendMessage();
  }

  // ── New discussion
  void _newDiscussion() {
    setState(() {
      _currentChatId = '';

      // clear input text
      _inputCtrl.clear();

      // close panel
      _isPanelOpen = false;

      // stop delete mode
      _isDeleteMode = false;
      _selectedForDelete.clear();

      // stop loading if active
      _isLoading = false;
    });
  }

  // ── Load existing chat
  Future<void> _loadChat(String id) async {
    setState(() {
      _currentChatId = id;
      _isPanelOpen = false;
      _isDeleteMode = false;
      _isLoading = true;
    });

    try {
      final data = await ChatbotService.getChat(id);

      final messages = (data['messages'] ?? []) as List;

      _chatMessages[id] = messages.map((m) {
        return _Message(
          text: m['content'] ?? '',
          isUser: m['role'] == 'user',
          time: _nowTime(),
        );
      }).toList();

      setState(() {
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ── Toggle delete mode
  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _selectedForDelete.clear();
    });
  }

  // ── Confirm delete
  void _confirmDelete() {
    if (_selectedForDelete.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Suppression des conversations',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ces conversations ?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              // delete from backend
              for (final id in _selectedForDelete.toList()) {
                try {
                  await ChatbotService.deleteChat(id);
                } catch (_) {}

                _chatMessages.remove(id);
              }

              setState(() {
                _histories.removeWhere(
                  (h) => _selectedForDelete.contains(h.id),
                );

                // if current chat deleted → reset UI
                if (_selectedForDelete.contains(_currentChatId)) {
                  _currentChatId = '';
                  _inputCtrl.clear();
                }

                _selectedForDelete.clear();
                _isDeleteMode = false;
                _isLoading = false;
              });
            },

            child: const Text(
              'Supprimer',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSOSSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<Map<String, String>> sos = [
          {'name': 'Pompiers / SAMU', 'number': '14'},
          {'name': 'Police', 'number': '17'},
          {'name': 'Gendarmerie Nationale', 'number': '1055'},
          {'name': 'Centre Anti-Poison', 'number': '021979898'},
        ];

        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "🚨 SOS URGENCE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            ...sos.map((e) {
              return ListTile(
                leading: const Icon(Icons.phone, color: Colors.red),

                title: Text(e['name']!),

                trailing: Text(
                  e['number']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // TAP → CALL
                onTap: () async {
                  final Uri phoneUri = Uri(scheme: 'tel', path: e['number']);

                  try {
                    await launchUrl(
                      phoneUri,
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    debugPrint('Call error: $e');
                  }
                },
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _sendEmergencyLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final lat = position.latitude;
    final lng = position.longitude;

    final message =
        "🚨 URGENCE\nJe suis en danger.\nhttps://maps.google.com/?q=$lat,$lng";

    final Uri smsUri = Uri.parse(
      "sms:1055?body=${Uri.encodeComponent(message)}",
    );

    await launchUrl(smsUri);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour}h${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBF8),
      body: Stack(
        children: [
          // ── Main chat area
          Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMessages()),
              _buildInputBar(),
            ],
          ),

          // ── Side panel overlay
          if (_isPanelOpen) ...[
            // Blur background
            GestureDetector(
              onTap: () => setState(() => _isPanelOpen = false),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(color: Colors.black.withValues(alpha: 0.2)),
              ),
            ),
            // Panel
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.72,
              child: _buildSidePanel(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Header
  Widget _buildHeader() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.white,
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1FAF87).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF1FAF87),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            // Name + status
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HealBot AI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF1FAF87), size: 8),
                      SizedBox(width: 4),
                      Text(
                        'En ligne · Toujours là pour vous',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu icon
            GestureDetector(
              onTap: () => setState(() => _isPanelOpen = !_isPanelOpen),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FBF8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF1FAF87),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Messages list
  Widget _buildMessages() {
    final messages = _currentMessages;
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == messages.length && _isLoading) {
          return _buildTypingIndicator();
        }
        return _buildBubble(messages[i]);
      },
    );
  }

  Widget _buildBubble(_Message msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: msg.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: msg.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI avatar
              if (!msg.isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8, bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FAF87).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Color(0xFF1FAF87),
                    size: 14,
                  ),
                ),
              ],

              // Bubble
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isUser ? const Color(0xFF1FAF87) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: msg.isUser
                          ? Colors.white
                          : const Color(0xFF1A1A2E),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Time
          Padding(
            padding: EdgeInsets.only(
              left: msg.isUser ? 0 : 36,
              top: 2,
              bottom: 8,
            ),
            child: Text(
              msg.time,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1FAF87).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF1FAF87),
              size: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 400 + i * 150),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FAF87).withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // 🚨 SOS ICON (NEW)
          GestureDetector(
            onTap: _openSOSSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.emergency, color: Colors.red, size: 20),
            ),
          ),

          const SizedBox(width: 8),

          // Text Field with green border when focused
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                // rebuild to update border color
                // optional: you can use a StatefulBuilder if needed
              },
              child: TextField(
                controller: _inputCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Demander n\'importe quoi...',
                  hintStyle: TextStyle(
                    color: const Color(0xFFBDBDBD),
                    fontSize: 13,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: const Color(0xFF5FCFAA),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: Color(0xFF1FAF87), // primary color when focused
                      width: 0.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          //  Send Button (changes color on tap)
          GestureDetector(
            onTap: _inputCtrl.text.trim().isEmpty ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _inputCtrl.text.trim().isEmpty
                    ? const Color(0xFFF0FBF8) // disabled
                    : const Color(0xFF1FAF87), // active green
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.send_rounded,
                color: _inputCtrl.text.trim().isEmpty
                    ? const Color(0xFF1FAF87) // disabled
                    : const Color(0xFFF0FBF8), // active green
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Side panel
  Widget _buildSidePanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FBF8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Recherche',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey.shade400,
                      size: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Nouvelle discussion button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onTap: _newDiscussion,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FBF8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1FAF87).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF1FAF87),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Nouvelle discussion',
                        style: TextStyle(
                          color: Color(0xFF1FAF87),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── DISCUSSIONS label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'DISCUSSIONS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade400,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Chat list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filteredHistories.length,
                itemBuilder: (context, i) {
                  final chat = _filteredHistories[i];
                  final isSelected = _selectedForDelete.contains(chat.id);
                  final isActive = chat.id == _currentChatId;

                  return GestureDetector(
                    onTap: () {
                      if (_isDeleteMode) {
                        setState(() {
                          if (isSelected) {
                            _selectedForDelete.remove(chat.id);
                          } else {
                            _selectedForDelete.add(chat.id);
                          }
                        });
                      } else {
                        _loadChat(chat.id);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive && !_isDeleteMode
                            ? const Color(0xFF1FAF87).withValues(alpha: 0.12)
                            : isSelected
                            ? const Color(0xFFE53935).withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Checkbox in delete mode
                          if (_isDeleteMode) ...[
                            Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE53935)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFE53935)
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    )
                                  : null,
                            ),
                          ],
                          Expanded(
                            child: Text(
                              chat.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive && !_isDeleteMode
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFF1A1A2E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Supprimer button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: GestureDetector(
                onTap: _isDeleteMode
                    ? (_selectedForDelete.isNotEmpty
                          ? _confirmDelete
                          : _toggleDeleteMode)
                    : _toggleDeleteMode,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE53935).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE53935),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isDeleteMode && _selectedForDelete.isNotEmpty
                            ? 'Supprimer (${_selectedForDelete.length})'
                            : 'Supprimer',
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Models
class _Message {
  final String text;
  final bool isUser;
  final String time;

  const _Message({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class _ChatHistory {
  final String id;
  final String title;

  const _ChatHistory({required this.id, required this.title});
}

// BACKEND TODO
// - _sendMessage()     → POST /chatbot/message {text, chatId} → get LLM response
// - _pickImage()       → POST /chatbot/image {image, chatId}  → get LLM response
// - _newDiscussion()   → POST /chatbot/chats  → get new chatId from backend
// - _loadChat()        → GET  /chatbot/chats/{id}/messages    → load real messages
// - _confirmDelete()   → DELETE /chatbot/chats {ids: [...]}   → delete from backend
// - _filteredHistories → GET  /chatbot/chats?search=query     → search from backend
// - Quick chips        → backend handles: rapports, médicaments, rendez-vous queries
// - FCM token          → already handled in notification_service.dart
