import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String _currentChatId = '1';

  // ── Chat histories 
  // Each chat has an id, a title, and a list of messages
  final List<_ChatHistory> _histories = [
    _ChatHistory(id: '1', title: 'Consultation cardiologue'),
    _ChatHistory(id: '2', title: 'Douleur poitrine'),
    _ChatHistory(id: '3', title: 'Analyse sanguine'),
    _ChatHistory(id: '4', title: 'Allergie'),
    _ChatHistory(id: '5', title: 'Discussion 05'),
  ];

  // ── Messages for current chat 
  final Map<String, List<_Message>> _chatMessages = {
    '1': [
      _Message(
        text:
            'Bonjour Sarah ! 👋 Je suis votre assistante santé personnelle. Comment puis-je vous aider aujourd\'hui ?',
        isUser: false,
        time: '8h00',
      ),
      _Message(
        text: 'Quand est mon prochain rendez-vous ?',
        isUser: true,
        time: '8h35',
      ),
      _Message(
        text:
            'Votre prochain rendez-vous avec le Dr.Merazi (cardiologie) est demain, le 12 mars, à 10h30. N\'oubliez pas d\'être à jeun pendant 4 heures avant ! 🥛',
        isUser: false,
        time: '8h38',
      ),
      _Message(
        text: 'Puis-je consulter les résultats de ma dernière analyse sanguine ?',
        isUser: true,
        time: '8h40',
      ),
      _Message(
        text:
            'Votre bilan sanguin du 22 février présente des valeurs normales. Hémoglobine : 13,8 g/dL, cholestérol : 178 mg/dL, glucose :',
        isUser: false,
        time: '8h41',
      ),
    ],
  };

  // ── Selected chats for deletion 
  final Set<String> _selectedForDelete = {};

  // ── Search 
  List<_ChatHistory> get _filteredHistories {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _histories;
    return _histories
        .where((h) => h.title.toLowerCase().contains(q))
        .toList();
  }

  List<_Message> get _currentMessages =>
      _chatMessages[_currentChatId] ?? [];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Send message 
  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.putIfAbsent(_currentChatId, () => []);
      _chatMessages[_currentChatId]!.add(
        _Message(text: text, isUser: true, time: _nowTime()),
      );
      _inputCtrl.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    // TODO: call LLM API from backend
    // final response = await ChatbotService.sendMessage(text, _currentChatId);
    // setState(() {
    //   _chatMessages[_currentChatId]!.add(
    //     _Message(text: response, isUser: false, time: _nowTime()),
    //   );
    //   _isLoading = false;
    // });

    // Simulated response delay (remove when backend ready)
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _scrollToBottom();
    });
  }

  // ── Quick chip tapped 
  void _sendQuickMessage(String text) {
    _inputCtrl.text = text;
    _sendMessage();
  }

  // ── Pick image from gallery 
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    // TODO: send image to backend chatbot
    // await ChatbotService.sendImage(file.path, _currentChatId);
  }

  // ── New discussion 
  void _newDiscussion() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _histories.insert(
        0,
        _ChatHistory(id: newId, title: 'Nouvelle discussion'),
      );
      _chatMessages[newId] = [
        _Message(
          text:
              'Bonjour ! Je suis votre assistante santé personnelle. Comment puis-je vous aider aujourd\'hui ?',
          isUser: false,
          time: _nowTime(),
        ),
      ];
      _currentChatId = newId;
      _isPanelOpen = false;
      _isDeleteMode = false;
    });
    // TODO: await ChatbotService.createNewChat() → get real id from backend
  }

  // ── Load existing chat 
  void _loadChat(String id) {
    setState(() {
      _currentChatId = id;
      _isPanelOpen = false;
      _isDeleteMode = false;
    });
    // TODO: load messages from backend
    // final messages = await ChatbotService.getChatMessages(id);
    _scrollToBottom();
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
            child: const Text('Annuler',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _histories.removeWhere(
                    (h) => _selectedForDelete.contains(h.id));
                for (final id in _selectedForDelete) {
                  _chatMessages.remove(id);
                }
                if (_selectedForDelete.contains(_currentChatId)) {
                  _currentChatId =
                      _histories.isNotEmpty ? _histories.first.id : '';
                }
                _selectedForDelete.clear();
                _isDeleteMode = false;
              });
              // TODO: await ChatbotService.deleteChats(_selectedForDelete);
            },
            child: const Text('Supprimer',
                style: TextStyle(
                    color: Color(0xFFE53935), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
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
              _buildQuickChips(),
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
                child: Container(
                  color: Colors.black.withValues(alpha: 0.2),
                ),
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
                      Icon(Icons.circle,
                          color: Color(0xFF1FAF87), size: 8),
                      SizedBox(width: 4),
                      Text(
                        'En ligne · Toujours là pour vous',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Search icon
            GestureDetector(
              onTap: () => setState(() {
                _isPanelOpen = true;
                _isDeleteMode = false;
              }),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FBF8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF1FAF87),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
        crossAxisAlignment:
            msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                  child: const Icon(Icons.smart_toy_rounded,
                      color: Color(0xFF1FAF87), size: 14),
                ),
              ],

              // Bubble
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? const Color(0xFF1FAF87)
                        : Colors.white,
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
                      color: msg.isUser ? Colors.white : const Color(0xFF1A1A2E),
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
            child: const Icon(Icons.smart_toy_rounded,
                color: Color(0xFF1FAF87), size: 14),
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

  // ── Quick chips 
  Widget _buildQuickChips() {
    final chips = [
      ('📋 Mes rapports', 'Affiche mes rapports médicaux'),
      ('💊 Mes médicaments', 'Affiche mes médicaments'),
      ('📅 Les rendez-vous d\'auj', 'Affiche mes rendez-vous d\'aujourd\'hui'),
    ];
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: chips.map((chip) {
            return GestureDetector(
              onTap: () => _sendQuickMessage(chip.$2),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FBF8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1FAF87).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  chip.$1,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1FAF87),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Input bar 
  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          // Gallery button
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FBF8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.photo_outlined,
                color: Color(0xFF1FAF87),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0FBF8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Demander n\'importe quoi...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1FAF87),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
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
                        color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.grey.shade400, size: 18),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
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
                      Icon(Icons.edit_outlined,
                          color: Color(0xFF1FAF87), size: 16),
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
                          horizontal: 12, vertical: 10),
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
                                  ? const Icon(Icons.close,
                                      color: Colors.white, size: 12)
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
                      const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFE53935), size: 16),
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