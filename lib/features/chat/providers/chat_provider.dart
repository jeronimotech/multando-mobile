import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/api_client.dart';

/// State for the chat feature.
class ChatState {
  const ChatState({
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.lastToolCalls = const [],
  });

  final Conversation? conversation;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final List<Map<String, dynamic>> lastToolCalls;

  ChatState copyWith({
    Conversation? conversation,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    List<Map<String, dynamic>>? lastToolCalls,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
      lastToolCalls: lastToolCalls ?? this.lastToolCalls,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return const ChatState();
  }

  MultandoClient get _client => ref.read(apiClientProvider);

  /// Send a text message, creating a conversation first if needed.
  Future<void> sendMessage(String content, {String? imageBase64}) async {
    if (content.trim().isEmpty && imageBase64 == null) return;

    state = state.copyWith(isSending: true, error: null);

    try {
      // Create conversation on first message.
      var conversation = state.conversation;
      if (conversation == null) {
        state = state.copyWith(isLoading: true);
        conversation = await _client.chat.createConversation();
        state = state.copyWith(conversation: conversation, isLoading: false);
      }

      // Add an optimistic user message to the list.
      final userMessage = ChatMessage(
        id: -DateTime.now().millisecondsSinceEpoch,
        conversationId: conversation.id,
        direction: 'inbound',
        content: content,
        messageType: imageBase64 != null ? 'image' : 'text',
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, userMessage],
      );

      // Send to API.
      final request = SendMessageRequest(
        content: content,
        imageBase64: imageBase64,
      );
      final response =
          await _client.chat.sendMessage(conversation.id, request);

      // Replace optimistic user message with the real messages from the
      // server response, adding the AI reply.
      final updatedMessages = [
        ...state.messages.where((m) => m.id != userMessage.id),
        // The server echoes the user message inside the conversation;
        // we just keep our optimistic one and add the AI reply.
        userMessage.id < 0 ? userMessage : userMessage,
        response.message,
      ];

      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
        lastToolCalls: response.toolCalls,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load an existing conversation and its messages.
  Future<void> loadConversation(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final conversation = await _client.chat.getConversation(id);
      state = state.copyWith(
        conversation: conversation,
        messages: conversation.messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Start a fresh conversation.
  void resetConversation() {
    state = const ChatState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final chatProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
