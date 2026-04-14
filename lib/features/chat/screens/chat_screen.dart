import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/multando_app_bar.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  String? _pendingImageBase64;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage([ImageSource source = ImageSource.camera]) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      _pendingImageBase64 = base64Encode(bytes);
    });
  }

  Future<void> _sendLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final locationText =
          'My current location: ${position.latitude.toStringAsFixed(6)}, '
          '${position.longitude.toStringAsFixed(6)}';
      ref.read(chatProvider.notifier).sendMessage(locationText);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location')),
        );
      }
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingImageBase64 == null) return;

    ref.read(chatProvider.notifier).sendMessage(
          text.isNotEmpty ? text : '📷',
          imageBase64: _pendingImageBase64,
        );
    _controller.clear();
    setState(() {
      _pendingImageBase64 = null;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);

    // Auto-scroll when new messages arrive.
    ref.listen(chatProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) < next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: MultandoAppBar(
        title: 'Multando',
        showLogo: true,
        actions: [
          if (chat.conversation != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'New conversation',
              onPressed: () =>
                  ref.read(chatProvider.notifier).resetConversation(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: chat.messages.isEmpty
                ? _WelcomeView()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: chat.messages.length +
                        (chat.isSending ? 1 : 0) +
                        (chat.lastToolCalls.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Tool calls card (shown after last AI message)
                      if (chat.lastToolCalls.isNotEmpty &&
                          index ==
                              chat.messages.length +
                                  (chat.isSending ? 1 : 0)) {
                        return _ToolCallsCard(
                            toolCalls: chat.lastToolCalls);
                      }
                      // Typing indicator
                      if (chat.isSending && index == chat.messages.length) {
                        return const _TypingIndicator();
                      }
                      final message = chat.messages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
          ),

          // Error banner
          if (chat.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: MultandoColors.dangerLight.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: MultandoColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chat.error!,
                      style: const TextStyle(
                          fontSize: 12, color: MultandoColors.danger),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () =>
                        ref.read(chatProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),

          // Image preview
          if (_pendingImageBase64 != null)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              alignment: Alignment.centerLeft,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(_pendingImageBase64!),
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _pendingImageBase64 = null),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: MultandoColors.danger,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Quick reply chips
          if (chat.quickReplies.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chat.quickReplies.map((reply) {
                  return ActionChip(
                    label: Text(reply.label),
                    labelStyle: const TextStyle(
                      color: MultandoColors.brandRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    backgroundColor: MultandoColors.brandRed.withAlpha(20),
                    side: BorderSide(color: MultandoColors.brandRed.withAlpha(80)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: chat.isSending
                        ? null
                        : () {
                            ref.read(chatProvider.notifier).sendMessage(reply.value);
                            _scrollToBottom();
                          },
                  );
                }).toList(),
              ),
            ),

          // Input bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            child: Row(
              children: [
                // Camera button
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  color: MultandoColors.surface500,
                  onPressed: () => _pickImage(ImageSource.camera),
                  tooltip: 'Take photo',
                ),
                // Gallery button (dev only)
                if (const bool.fromEnvironment('dart.vm.product') == false)
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined),
                    color: MultandoColors.surface500,
                    onPressed: () => _pickImage(ImageSource.gallery),
                    tooltip: 'Pick from gallery (dev)',
                  ),
                // Location button
                IconButton(
                  icon: const Icon(Icons.location_on_outlined),
                  color: MultandoColors.surface500,
                  onPressed: _sendLocation,
                  tooltip: 'Share location',
                ),
                // Text field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: MultandoColors.surface100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Ask Multa anything...',
                        hintStyle: TextStyle(color: MultandoColors.surface400),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Send button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    icon: chat.isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MultandoColors.brandRed,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    color: MultandoColors.brandRed,
                    onPressed: chat.isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MultandoBottomNavBar(currentIndex: 2),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome view shown when no messages exist yet
// ---------------------------------------------------------------------------

class _WelcomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: MultandoColors.brandRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 40,
                color: MultandoColors.brandRed,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Multa AI',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: MultandoColors.surface800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'I can help you report traffic infractions, check your rewards, '
              'answer questions about infractions, and analyze photos. '
              'Just type a message or snap a photo to get started!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: MultandoColors.surface500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(label: 'Report an infraction'),
                _SuggestionChip(label: 'Check my rewards'),
                _SuggestionChip(label: 'What infractions exist?'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends ConsumerWidget {
  const _SuggestionChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(
        color: MultandoColors.brandRed,
        fontSize: 13,
      ),
      backgroundColor: MultandoColors.brandRed.withOpacity(0.08),
      side: BorderSide(color: MultandoColors.brandRed.withOpacity(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        ref.read(chatProvider.notifier).sendMessage(label);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Chat bubble
// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessage message;

  bool get _isUser => message.direction == 'inbound';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: MultandoColors.brandRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    _isUser ? MultandoColors.brandRed : MultandoColors.surface100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(_isUser ? 18 : 4),
                  bottomRight: Radius.circular(_isUser ? 4 : 18),
                ),
              ),
              child: _isUser
                  ? Text(
                      message.content ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.content ?? '',
                      shrinkWrap: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: MultandoColors.surface800,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        strong: const TextStyle(
                          color: MultandoColors.surface900,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        listBullet: const TextStyle(
                          color: MultandoColors.surface600,
                          fontSize: 15,
                        ),
                        h1: const TextStyle(
                          color: MultandoColors.surface900,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        h2: const TextStyle(
                          color: MultandoColors.surface900,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        h3: const TextStyle(
                          color: MultandoColors.surface900,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        code: TextStyle(
                          color: MultandoColors.brandRed,
                          backgroundColor: MultandoColors.surface200,
                          fontSize: 14,
                        ),
                        blockSpacing: 8,
                      ),
                    ),
            ),
          ),
          if (_isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Typing indicator (three dots animation)
// ---------------------------------------------------------------------------

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: MultandoColors.brandRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: MultandoColors.surface100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.2;
                    final value =
                        ((_animController.value - delay) % 1.0).clamp(0.0, 1.0);
                    final opacity = 0.3 + 0.7 * (1 - (2 * value - 1).abs());
                    return Padding(
                      padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: MultandoColors.surface400,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tool calls info card
// ---------------------------------------------------------------------------

class _ToolCallsCard extends StatelessWidget {
  const _ToolCallsCard({required this.toolCalls});
  final List<Map<String, dynamic>> toolCalls;

  String _toolLabel(Map<String, dynamic> tc) {
    final name = tc['name'] as String? ?? tc['tool'] as String? ?? 'action';
    final input = tc['input'] as Map<String, dynamic>? ?? {};

    switch (name) {
      case 'create_report':
        return 'Created report #${input['id'] ?? ''}';
      case 'search_infractions':
        return 'Searched infractions';
      case 'get_balance':
        return 'Checked token balance';
      case 'get_report':
        return 'Retrieved report details';
      default:
        return name.replaceAll('_', ' ');
    }
  }

  IconData _toolIcon(Map<String, dynamic> tc) {
    final name = tc['name'] as String? ?? tc['tool'] as String? ?? '';
    if (name.contains('report')) return Icons.description;
    if (name.contains('balance') || name.contains('token')) {
      return Icons.account_balance_wallet;
    }
    if (name.contains('infraction')) return Icons.gavel;
    return Icons.build_circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: toolCalls.map((tc) {
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: MultandoColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: MultandoColors.info.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_toolIcon(tc),
                    size: 14, color: MultandoColors.info),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _toolLabel(tc),
                    style: const TextStyle(
                      fontSize: 12,
                      color: MultandoColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
