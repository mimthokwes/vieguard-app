import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io_client;

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/api/api_exception.dart';
import '../core/services/local_notification_service.dart';
import '../core/storage/token_storage.dart';
import '../models/conversation_model.dart';
import '../models/operations_models.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  ChatProvider({required this.apiClient, required this.tokenStorage});

  List<Conversation> _conversations = [];
  List<ChatMessage> _messages = [];
  String? _activeConversationId;
  bool isLoadingList = false;
  bool isLoadingMessages = false;
  bool isSending = false;
  String? errorMessage;

  io_client.Socket? _socket;
  VoidCallback? onNotificationReceived;

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool get isConnected => _socket?.connected ?? false;

  Future<void> fetchConversations() async {
    isLoadingList = true;
    errorMessage = null;
    notifyListeners();
    try {
      final data = await apiClient.get('/chat/conversations');
      _conversations = (data as List<dynamic>).map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoadingList = false;
      notifyListeners();
    }
  }

  Future<void> openConversation(String conversationId) async {
    _activeConversationId = conversationId;
    isLoadingMessages = true;
    _messages = [];
    notifyListeners();
    try {
      final data = await apiClient.get('/chat/conversations/$conversationId/messages');
      _messages = (data as List<dynamic>).map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final old = _conversations[index];
        _conversations[index] = Conversation(
          id: old.id,
          customerId: old.customerId,
          customerName: old.customerName,
          customerPhoto: old.customerPhoto,
          lastMessageText: old.lastMessageText,
          lastMessageAt: old.lastMessageAt,
          unreadCount: 0,
          lastFromAdmin: old.lastFromAdmin,
          isBotActive: old.isBotActive,
        );
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoadingMessages = false;
      notifyListeners();
    }
    await _ensureSocketConnected();
    _socket?.emit('conversation:join', conversationId);
  }

  /// Sinkronisasi pesan aktif secara senyap (tanpa menampilkan skeleton loading)
  Future<void> syncActiveConversation() async {
    final activeId = _activeConversationId;
    if (activeId == null) return;
    try {
      final data = await apiClient.get('/chat/conversations/$activeId/messages');
      final newMessages = (data as List<dynamic>).map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
      _messages = newMessages;
      notifyListeners();
    } catch (_) {
      // Abaikan error saat sinkronisasi senyap
    }
  }

  Future<void> connectRealtime({bool force = false}) => _ensureSocketConnected(force: force);

  void disconnectRealtime() {
    _socket?.dispose();
    _socket = null;
  }

  bool _isConnecting = false;

  Future<void> _ensureSocketConnected({bool force = false}) async {
    if (!force && _socket != null && _socket!.connected) return;
    if (_isConnecting && !force) return;
    _isConnecting = true;

    try {
      // Selalu gunakan access token valid (otomatis me-refresh jika sudah expired)
      final token = await apiClient.getValidAccessToken();
      if (token == null) {
        _isConnecting = false;
        return;
      }

      _socket?.dispose();
      _socket = io_client.io(
        '${ApiConfig.origin}/ws/mobile',
        io_client.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1500)
            .setReconnectionAttempts(999)
            .build(),
      );

      _socket!.onConnect((_) {
        debugPrint('[ChatProvider] WebSocket Mobile TERHUBUNG ke ${ApiConfig.origin}/ws/mobile');
        errorMessage = null;
        final active = _activeConversationId;
        if (active != null) {
          _socket?.emit('conversation:join', active);
          syncActiveConversation();
        }
        notifyListeners();
      });

      _socket!.onDisconnect((reason) {
        debugPrint('[ChatProvider] WebSocket Mobile terputus: $reason');
        notifyListeners();
      });

      _socket!.onConnectError((err) async {
        debugPrint('[ChatProvider] WebSocket Mobile GAGAL terhubung: $err');
        final errStr = err.toString().toLowerCase();
        if (errStr.contains('auth') || errStr.contains('token') || errStr.contains('jwt')) {
          // Token bermasalah / expired, coba perbarui token dan sambungkan ulang
          final newToken = await apiClient.refreshToken();
          if (newToken != null && _socket != null) {
            _ensureSocketConnected(force: true);
            return;
          }
        }
        errorMessage = 'Gagal terhubung ke server chat real-time.';
        notifyListeners();
      });

      _socket!.on('message:new', (data) {
        debugPrint('[ChatProvider] Event message:new diterima: $data');
        try {
          final message = ChatMessage.fromJson(Map<String, dynamic>.from(data as Map));
          final isActiveChat = message.conversationId == _activeConversationId;

          if (isActiveChat) {
            if (!_messages.any((m) => m.id == message.id)) {
              _messages.add(message);
            }
            if (!message.isFromAdmin) {
              apiClient.get('/chat/conversations/${message.conversationId}/messages').ignore();
            }
          }

          final convIndex = _conversations.indexWhere((c) => c.id == message.conversationId);
          String customerName = 'Pelanggan';

          if (convIndex == -1) {
            fetchConversations();
          } else {
            final old = _conversations.removeAt(convIndex);
            customerName = old.customerName;
            _conversations.insert(
              0,
              Conversation(
                id: old.id,
                customerId: old.customerId,
                customerName: old.customerName,
                customerPhoto: old.customerPhoto,
                lastMessageText: message.messageText,
                lastMessageAt: message.createdAt,
                unreadCount: isActiveChat || message.isFromAdmin ? old.unreadCount : old.unreadCount + 1,
                lastFromAdmin: message.isFromAdmin,
                isBotActive: old.isBotActive,
              ),
            );
          }
          notifyListeners();

          // Tampilkan notifikasi jika pesan berasal dari pelanggan dan pengguna tidak sedang di layar percakapan tersebut
          if (!message.isFromAdmin && !isActiveChat) {
            LocalNotificationService.showChatNotification(
              customerName: customerName,
              messageText: message.messageText?.isNotEmpty == true
                  ? message.messageText!
                  : (message.imageAttachment != null ? 'Mengirim gambar lampiran' : 'Pesan baru masuk'),
              conversationId: message.conversationId,
            );
          }
        } catch (e, stack) {
          debugPrint('[ChatProvider] Error parsing message:new: $e\n$stack');
        }
      });

      _socket!.on('notification:new', (data) {
        debugPrint('[ChatProvider] Event notification:new diterima: $data');
        try {
          final map = Map<String, dynamic>.from(data as Map);
          final title = map['title']?.toString() ?? 'Pemberitahuan Baru';
          final body = map['message']?.toString() ?? '';
          final orderId = map['relatedOrderId']?.toString();

          LocalNotificationService.showOrderNotification(
            title: title,
            message: body,
            orderId: orderId,
          );

          onNotificationReceived?.call();
        } catch (e) {
          debugPrint('Error socket notification:new: $e');
        }
      });

      _socket!.connect();
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> sendMessage(String conversationId, String text) async {
    if (text.trim().isEmpty) return;
    isSending = true;
    notifyListeners();
    await _ensureSocketConnected();
    _socket?.emit('message:send', {'conversationId': conversationId, 'messageText': text.trim()});
    isSending = false;
    notifyListeners();
  }

  void leaveConversation() {
    _activeConversationId = null;
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }

  List<CustomerSummary> customers = [];

  Future<void> fetchCustomers() async {
    try {
      final data = await apiClient.get('/customers');
      customers = (data as List<dynamic>).map((e) => CustomerSummary.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<Conversation?> startConversation(String userId, String message) async {
    try {
      await apiClient.post('/chat/conversations', data: {'userId': userId, 'messageText': message});
      await fetchConversations();
      final matches = _conversations.where((c) => c.customerId == userId);
      return matches.isEmpty ? null : matches.first;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }
}
