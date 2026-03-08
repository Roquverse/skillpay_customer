import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/services/messages_service.dart';
import 'package:skillpay/models/chat_model.dart';
import 'package:skillpay/screens/chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MessagesService _messagesService = MessagesService();
  late Future<List<ChatModel>> _chatsFuture;

  @override
  void initState() {
    super.initState();
    _chatsFuture = _messagesService.fetchChats();
  }

  // Mock data fallback 
  final List<Map<String, String>> _mockMessages = [
    {
      'id': '1',
      'name': 'James Walker',
      'lastMessage': 'Hi, are you available for a pro...',
      'time': '1m Ago',
      'imagePath': 'assets/images/avatar_james.png',
      'isOnline': 'true',
    },
    {
      'id': '2',
      'name': 'Bluecollar',
      'lastMessage': 'Hi, are you available for a pro...',
      'time': '1m Ago',
      'imagePath': 'assets/images/cat_cleaning.png', // Temporary placeholder for others
      'isOnline': 'true',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Pure white
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Messages',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          
          Expanded(
            child: FutureBuilder<List<ChatModel>>(
              future: _chatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading messages',
                      style: GoogleFonts.outfit(color: AppColors.textMedium),
                    ),
                  );
                }

                final chats = snapshot.data ?? [];

                if (chats.isEmpty) {
                  // Fallback for prototyping if no chats or DB not set up yet
                  if (_mockMessages.isEmpty) return _buildEmptyState();
                  return _buildListState(_mockMessages, true);
                }

                return _buildListState(chats, false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: GoogleFonts.outfit(
                  color: const Color(0xFFB0B0B0),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Icon(
            Icons.search_rounded,
            color: Color(0xFFB0B0B0),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100), // Offset for center
        child: Text(
          'No messages yet',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildListState(List<dynamic> items, bool isMock) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100), // bottom padding for nav bar
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        
        String name = '';
        String lastMsg = '';
        String time = '';
        String imagePath = '';
        bool isOnline = false;
        bool isNetworkImage = false;

        if (isMock) {
          final mockItem = item as Map<String, String>;
          name = mockItem['name'] ?? '';
          lastMsg = mockItem['lastMessage'] ?? '';
          time = mockItem['time'] ?? '';
          imagePath = mockItem['imagePath'] ?? '';
          isOnline = mockItem['isOnline'] == 'true';
        } else {
          final chat = item as ChatModel;
          name = chat.artisanName;
          lastMsg = chat.lastMessage;
          time = chat.timeText;
          imagePath = chat.artisanAvatarUrl;
          isOnline = false; // Add real online status lookup if needed later
          isNetworkImage = imagePath.startsWith('http');
        }
        
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  artisanName: name,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Avatar with indicator
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF5F5F5),
                        image: DecorationImage(
                          image: isNetworkImage
                              ? NetworkImage(imagePath) as ImageProvider
                              : AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        top: 2,
                        left: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50), // Green dot
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Name and Last Message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMsg,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Timestamp
                Text(
                  time,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
