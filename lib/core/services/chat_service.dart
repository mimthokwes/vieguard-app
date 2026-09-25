import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/chat_model.dart';

class ChatService {
  static Future<ApiResponse<List<ConversationModel>>> fetchConversations() async {
    final response = await ApiClient.get(ApiEndpoints.chatConversations);

    if (response.success && response.data != null && response.data is List) {
      final list = (response.data as List).map((i) => ConversationModel.fromJson(i)).toList();
      return ApiResponse<List<ConversationModel>>(
        success: true,
        message: response.message,
        data: list,
      );
    }

    return ApiResponse<List<ConversationModel>>(
      success: response.success,
      message: response.message,
      data: <ConversationModel>[],
    );
  }

  static Future<ApiResponse<List<MessageModel>>> fetchMessages(String conversationId) async {
    final response = await ApiClient.get(ApiEndpoints.chatMessages(conversationId));

    if (response.success && response.data != null && response.data is List) {
      final list = (response.data as List).map((i) => MessageModel.fromJson(i)).toList();
      return ApiResponse<List<MessageModel>>(
        success: true,
        message: response.message,
        data: list,
      );
    }

    return ApiResponse<List<MessageModel>>(
      success: response.success,
      message: response.message,
      data: <MessageModel>[],
    );
  }

  static Future<ApiResponse<MessageModel>> sendMessage({
    required String conversationId,
    required String messageText,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.sendMessage(conversationId),
      {'messageText': messageText},
    );

    if (response.success && response.data != null) {
      return ApiResponse<MessageModel>(
        success: true,
        message: response.message,
        data: MessageModel.fromJson(response.data),
      );
    }

    return ApiResponse<MessageModel>(
      success: response.success,
      message: response.message,
      data: null,
    );
  }
}
