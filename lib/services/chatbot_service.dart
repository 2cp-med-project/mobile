import '../config/api_client.dart';
import '../config/api_endpoints.dart';

class ChatbotService {

  // create new discussion
  static Future<Map<String, dynamic>>
  startChat(String prompt) async {
    final res = await ApiClient.post(
      Endpoints.chatbot,
      {
        'prompt': prompt,
      },
    );

    if (res.success) {
      return Map<String, dynamic>.from(
        res.data,
      );
    }

    throw Exception(
      res.error ??
      'Failed to start chat',
    );
  }

  // send message
  static Future<Map<String, dynamic>>
  sendMessage({
    required String threadId,
    required String prompt,
  }) async {
    final res = await ApiClient.post(
      Endpoints.chatbotById(threadId),
      {
        'prompt': prompt,
      },
    );

    if (res.success) {
      return Map<String, dynamic>.from(
        res.data,
      );
    }

    throw Exception(
      res.error ??
      'Failed to send message',
    );
  }

  // load chat
  static Future<Map<String, dynamic>>
  getChat(String threadId) async {
    final res = await ApiClient.get(
      Endpoints.chatbotById(threadId),
    );

    if (res.success) {
      return Map<String, dynamic>.from(
        res.data,
      );
    }

    throw Exception(
      res.error ??
      'Failed to load chat',
    );
  }

  // load all chats
  static Future<List<dynamic>>
  getChats() async {
    final res = await ApiClient.get(
      Endpoints.chatbot,
    );

    if (res.success) {
      return List<dynamic>.from(
        res.data,
      );
    }

    throw Exception(
      res.error ??
      'Failed to load chats',
    );
  }

  // delete
  static Future<void> deleteChat(
    String threadId,
  ) async {
    final res =
        await ApiClient.delete(
      Endpoints.chatbotById(
        threadId,
      ),
    );

    if (!res.success) {
      throw Exception(
        res.error ??
        'Failed to delete chat',
      );
    }
  }
}