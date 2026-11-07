import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_config.dart';
import '../../core/storage/image_cache_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/parsing.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../models/order_model.dart';
import '../../models/order_status.dart';
import '../../state/chat_provider.dart';
import '../../state/order_provider.dart';
import '../../widgets/common/tap_scale.dart';
import '../../widgets/common/vg_skeleton.dart';
import '../../widgets/vg/vg_ui.dart';
import '../pesanan/detail_pesanan_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;
  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final ChatProvider _chat;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _chat = context.read<ChatProvider>();
    Future.microtask(() {
      if (!mounted) return;
      _chat.openConversation(widget.conversation.id);
      final orders = context.read<OrderProvider>();
      if (orders.orders.isEmpty) orders.fetchOrders();
    });
  }

  @override
  void dispose() {
    _chat.leaveConversation();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = preset ?? _inputCtrl.text;
    if (text.trim().isEmpty) return;
    _chat.sendMessage(widget.conversation.id, text);
    if (preset == null) _inputCtrl.clear();
  }

  void _scrollToEnd(int count) {
    if (count == _lastCount) return;
    _lastCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    });
  }

  Order? _linkedOrder(OrderProvider provider) {
    final matches = provider.orders.where((o) => o.customer.id == widget.conversation.customerId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches.isEmpty ? null : matches.first;
  }

  List<(String, IconData, String)> _quickReplies(Order? order) => [
        ('Minta Bukti Transfer', Icons.receipt_long_outlined, 'Mohon kirimkan bukti transfer pembayaran${order != null ? ' untuk pesanan #${order.orderNumber}' : ''} agar dapat segera kami verifikasi.'),
        ('Minta Data Ukuran', Icons.straighten_rounded, 'Mohon kirimkan rekap data ukuran (S/M/L/XL) beserta jumlah per ukuran agar produksi dapat dijadwalkan.'),
        ('Konfirmasi Jadwal', Icons.event_available_outlined, 'Kami ingin mengonfirmasi jadwal pengambilan/pengiriman pesanan. Mohon informasikan waktu yang sesuai.'),
        ('Terima Kasih', Icons.favorite_border_rounded, 'Terima kasih atas kepercayaan Anda kepada VIEGUARD. Kami akan segera memproses permintaan Anda.'),
      ];

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final order = _linkedOrder(context.watch<OrderProvider>());
    final messages = chat.messages;
    _scrollToEnd(messages.length);
    final firstName = widget.conversation.customerName.split(' ').first;

    final items = <Widget>[];
    DateTime? lastDay;
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
      if (day != lastDay) {
        items.add(_DateSeparator(date: day));
        lastDay = day;
      }
      final prev = i > 0 ? messages[i - 1] : null;
      final grouped = prev != null && prev.senderType == m.senderType && m.createdAt.difference(prev.createdAt).inMinutes < 5;
      items.add(_MessageBubble(message: m, customerName: widget.conversation.customerName, showHeader: !grouped));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VgBackBar(title: widget.conversation.customerName),
      body: Column(children: [
        if (order != null) _OrderContextCard(order: order),
        Expanded(
          child: chat.isLoadingMessages
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: const [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: VgSkeleton(width: 220, height: 48, radius: 14, margin: EdgeInsets.only(bottom: 12)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: VgSkeleton(width: 180, height: 42, radius: 14, margin: EdgeInsets.only(bottom: 12)),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: VgSkeleton(width: 260, height: 60, radius: 14, margin: EdgeInsets.only(bottom: 12)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: VgSkeleton(width: 140, height: 38, radius: 14, margin: EdgeInsets.only(bottom: 12)),
                    ),
                  ],
                )
              : messages.isEmpty
                  ? const Center(child: Text('Belum ada pesan. Mulai percakapan dengan pelanggan.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)))
                  : ListView(controller: _scrollCtrl, padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), children: items),
        ),
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.only(top: 8),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final q in _quickReplies(order))
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: TapScale(
                          onTap: () => setState(() => _inputCtrl.text = q.$3),
                          child: VgPill(label: q.$1, color: AppColors.primary, background: AppColors.beige, icon: q.$2, fontSize: 12, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(16)),
                      child: TextField(
                        controller: _inputCtrl,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan balasan untuk $firstName',
                          hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.primary),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TapScale(
                    onTap: chat.isSending ? null : _send,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: chat.isSending
                          ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 21),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _OrderContextCard extends StatelessWidget {
  final Order order;
  const _OrderContextCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TapScale(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPesananScreen(orderId: order.id)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              VgThumb(url: order.coverImage, size: 48, radius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.orderType.label} · #${order.orderNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    OrderStatusPill(order: order),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: VgPill(
          label: Formatters.dayDate(date),
          color: AppColors.primary,
          background: AppColors.beige,
          icon: Icons.calendar_today_rounded,
          fontSize: 12,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String customerName;
  final bool showHeader;

  const _MessageBubble({required this.message, required this.customerName, required this.showHeader});

  @override
  Widget build(BuildContext context) {
    final admin = message.isFromAdmin;
    final time = Formatters.timeWithZone(message.createdAt);
    final image = resolveMediaUrl(message.imageAttachment, ApiConfig.origin);
    final maxWidth = MediaQuery.of(context).size.width * 0.74;

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: admin ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(admin ? 14 : 4),
          topRight: Radius.circular(admin ? 4 : 14),
          bottomLeft: const Radius.circular(14),
          bottomRight: const Radius.circular(14),
        ),
        boxShadow: admin ? null : AppColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (image != null)
          Padding(
            padding: EdgeInsets.only(bottom: message.messageText?.isNotEmpty == true ? 8 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: VgImage(url: image, width: 200, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const SizedBox.shrink()),
            ),
          ),
        if (message.messageText != null && message.messageText!.isNotEmpty)
          _FormattedChatMessage(text: message.messageText!, isFromAdmin: admin),
      ]),
    );

    if (admin) {
      return Padding(
        padding: EdgeInsets.only(top: showHeader ? 10 : 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          bubble,
          const SizedBox(height: 4),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(time, style: const TextStyle(fontSize: 11.5, color: AppColors.primary)),
            const SizedBox(width: 4),
            const Icon(Icons.done_all_rounded, size: 14, color: AppColors.primary),
          ]),
        ]),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: showHeader ? 10 : 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 36,
          child: showHeader ? const VgIconBadge(icon: Icons.school_outlined, size: 30, circle: true) : null,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.only(bottom: 6, top: 4),
                child: Row(children: [
                  Flexible(child: Text(customerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                  const SizedBox(width: 8),
                  Text(time, style: const TextStyle(fontSize: 11.5, color: AppColors.primary)),
                ]),
              ),
            bubble,
          ]),
        ),
      ]),
    );
  }
}

class _FormattedChatMessage extends StatelessWidget {
  final String text;
  final bool isFromAdmin;

  const _FormattedChatMessage({
    required this.text,
    required this.isFromAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isFromAdmin ? Colors.white : AppColors.textPrimary;
    final baseStyle = TextStyle(
      fontSize: 14.5,
      height: 1.45,
      color: baseColor,
    );
    final boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w700,
      color: baseColor,
    );
    final italicStyle = baseStyle.copyWith(
      fontStyle: FontStyle.italic,
      color: baseColor,
    );
    final boldItalicStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: baseColor,
    );

    final lines = text.split('\n');
    final bulletRegex = RegExp(r'^(\s*)([-*])\s+(.*)$');
    final numberedRegex = RegExp(r'^(\s*)(\d+)\.\s+(.*)$');
    final headingRegex = RegExp(r'^(#{1,3})\s+(.*)$');

    final children = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      final headingMatch = headingRegex.firstMatch(line);
      if (headingMatch != null) {
        final headingText = headingMatch.group(2) ?? '';
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: Text.rich(
              TextSpan(
                children: _parseInlineSpans(
                  headingText,
                  baseStyle: boldStyle.copyWith(fontSize: 15),
                  boldStyle: boldStyle.copyWith(fontSize: 15),
                  italicStyle: boldItalicStyle.copyWith(fontSize: 15),
                  boldItalicStyle: boldItalicStyle.copyWith(fontSize: 15),
                ),
              ),
            ),
          ),
        );
        continue;
      }

      final bulletMatch = bulletRegex.firstMatch(line);
      if (bulletMatch != null) {
        final itemText = bulletMatch.group(3) ?? '';
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7, right: 8),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isFromAdmin ? Colors.white : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _parseInlineSpans(
                        itemText,
                        baseStyle: baseStyle,
                        boldStyle: boldStyle,
                        italicStyle: italicStyle,
                        boldItalicStyle: boldItalicStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      final numMatch = numberedRegex.firstMatch(line);
      if (numMatch != null) {
        final num = numMatch.group(2) ?? '1';
        final itemText = numMatch.group(3) ?? '';
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    '$num.',
                    style: baseStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isFromAdmin ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _parseInlineSpans(
                        itemText,
                        baseStyle: baseStyle,
                        boldStyle: boldStyle,
                        italicStyle: italicStyle,
                        boldItalicStyle: boldItalicStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Normal line
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text.rich(
            TextSpan(
              children: _parseInlineSpans(
                line,
                baseStyle: baseStyle,
                boldStyle: boldStyle,
                italicStyle: italicStyle,
                boldItalicStyle: boldItalicStyle,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  static List<InlineSpan> _parseInlineSpans(
    String text, {
    required TextStyle baseStyle,
    required TextStyle boldStyle,
    required TextStyle italicStyle,
    required TextStyle boldItalicStyle,
  }) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'(\*\*\*[^*]+?\*\*\*|\*\*[^*]+?\*\*|\*(?!\s)[^*]+?(?<!\s)\*)');
    final matches = pattern.allMatches(text);

    int lastEnd = 0;
    for (final m in matches) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, m.start), style: baseStyle));
      }
      final matchText = m.group(0)!;
      if (matchText.startsWith('***') && matchText.endsWith('***') && matchText.length > 6) {
        spans.add(TextSpan(
          text: matchText.substring(3, matchText.length - 3),
          style: boldItalicStyle,
        ));
      } else if (matchText.startsWith('**') && matchText.endsWith('**') && matchText.length > 4) {
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: boldStyle,
        ));
      } else if (matchText.startsWith('*') && matchText.endsWith('*') && matchText.length > 2) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: italicStyle,
        ));
      }
      lastEnd = m.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }

    return spans;
  }
}
