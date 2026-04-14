import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
    this.quickReplies = const [],
  });

  final Conversation? conversation;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final List<Map<String, dynamic>> lastToolCalls;
  final List<QuickReply> quickReplies;

  ChatState copyWith({
    Conversation? conversation,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    List<Map<String, dynamic>>? lastToolCalls,
    List<QuickReply>? quickReplies,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
      lastToolCalls: lastToolCalls ?? this.lastToolCalls,
      quickReplies: quickReplies ?? this.quickReplies,
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

    state = state.copyWith(isSending: true, error: null, quickReplies: []);

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

      // Sign the image if present.
      String? imageHash;
      String? imageSignature;
      String? imageTimestamp;
      double? imageLat;
      double? imageLon;
      String? deviceId;

      if (imageBase64 != null) {
        try {
          final bytes = base64Decode(imageBase64);
          final timestamp = DateTime.now().toUtc().toIso8601String();
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(const Duration(seconds: 5), onTimeout: () {
            throw Exception('GPS timeout');
          });

          final evidence = await EvidenceSigner.signEvidence(
            imageBytes: Uint8List.fromList(bytes),
            timestamp: timestamp,
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            motionVerified: false,
            imageUri: 'chat_upload',
            captureMethod: 'camera',
          );

          imageHash = evidence.imageHash;
          imageSignature = evidence.signature;
          imageTimestamp = evidence.timestamp;
          imageLat = evidence.latitude;
          imageLon = evidence.longitude;
          deviceId = evidence.deviceId;
        } catch (_) {
          // Signing failed — still send unsigned (backend marks as unverified)
        }
      }

      // Send to API.
      final request = SendMessageRequest(
        content: content,
        imageBase64: imageBase64,
        imageHash: imageHash,
        imageSignature: imageSignature,
        imageTimestamp: imageTimestamp,
        imageLatitude: imageLat,
        imageLongitude: imageLon,
        deviceId: deviceId,
        captureMethod: imageBase64 != null ? 'camera' : null,
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
        quickReplies: response.quickReplies,
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
