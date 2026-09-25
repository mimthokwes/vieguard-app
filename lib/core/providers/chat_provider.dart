import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ConversationModel> _conversations = [];
  List<MessageModel> _activeMessages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get activeMessages => _activeMessages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchConversations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ChatService.fetchConversations();
    _isLoading = false;

    if (response.success && response.data != null) {
      _conversations = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<void> fetchMessages(String conversationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ChatService.fetchMessages(conversationId);
    _isLoading = false;

    if (response.success && response.data != null) {
      _activeMessages = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> sendMessage(String conversationId, String messageText) async {
    final response = await ChatService.sendMessage(conversationId: conversationId, messageText: messageText);
    if (response.success && response.data != null) {
      _activeMessages.add(response.data!);
      notifyListeners();
      return true;
    }
    return false;
  }
}
