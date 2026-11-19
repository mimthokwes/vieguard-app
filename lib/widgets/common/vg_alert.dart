import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum VgAlertType {
  confirm,
  success,
  error,
  info,
}

/// Sesi data alert yang independen dari siklus hidup widget / route navigasi.
class _VgAlertSession {
  final String id;
  final String message;
  final String? title;
  final VgAlertType type;
  final DateTime createdAt;
  DateTime expiresAt;
  final Duration totalDuration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  DateTime? pauseStartedAt;

  _VgAlertSession({
    required this.id,
    required this.message,
    this.title,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    required this.totalDuration,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  void pause() {
    pauseStartedAt ??= DateTime.now();
  }

  void resume() {
    if (pauseStartedAt != null) {
      final pausedMs = DateTime.now().difference(pauseStartedAt!).inMilliseconds;
      expiresAt = expiresAt.add(Duration(milliseconds: pausedMs));
      pauseStartedAt = null;
    }
  }

  Duration get remaining {
    if (pauseStartedAt != null) {
      final rem = expiresAt.difference(pauseStartedAt!);
      return rem.isNegative ? Duration.zero : rem;
    }
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  int get remainingSeconds {
    final rem = remaining.inMilliseconds;
    if (rem <= 0) return 0;
    return (rem / 1000).ceil();
  }

  double get progress {
    final totalMs = totalDuration.inMilliseconds;
    if (totalMs <= 0) return 0.0;
    return (remaining.inMilliseconds / totalMs).clamp(0.0, 1.0);
  }
}

class VgAlert {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static OverlayEntry? _currentEntry;
  static GlobalKey<_VgAlertWidgetState>? _activeKey;
  static _VgAlertSession? _activeSession;

  /// Hapus entry overlay dari root navigator secara tuntas
  static void _removeEntry() {
    _activeSession?.onDismiss?.call();
    try {
      _currentEntry?.remove();
    } catch (_) {}
    _currentEntry = null;
    _activeSession = null;
    _activeKey = null;
  }

  /// Tampilkan Top Alert dengan animasi meluncur dari kanan ke kiri
  /// dan timer 15 detik yang tetap berjalan konsisten meskipun pindah halaman / tab.
  static void show({
    BuildContext? context,
    required String message,
    String? title,
    VgAlertType type = VgAlertType.info,
    Duration duration = const Duration(seconds: 15),
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) {
    final navContext = context ?? navigatorKey.currentContext;
    if (navContext == null) return;

    final navigator = Navigator.of(navContext, rootNavigator: true);
    final overlay = navigator.overlay ?? Overlay.of(navContext, rootOverlay: true);

    // Bersihkan alert sebelumnya jika ada
    dismiss(immediate: true);

    final now = DateTime.now();
    final session = _VgAlertSession(
      id: now.microsecondsSinceEpoch.toString(),
      message: message,
      title: title,
      type: type,
      createdAt: now,
      expiresAt: now.add(duration),
      totalDuration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: onDismiss,
    );
    _activeSession = session;

    final key = GlobalKey<_VgAlertWidgetState>();
    _activeKey = key;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _VgAlertWidget(
        key: key,
        session: session,
        onDismiss: () {
          _removeEntry();
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// Khusus Konfirmasi dengan ikon Jempol Mantap (thumb_up)
  static void confirm({
    BuildContext? context,
    required String message,
    String title = 'Konfirmasi',
    String confirmLabel = 'Konfirmasi',
    required VoidCallback onConfirm,
    String cancelLabel = 'Batal',
    VoidCallback? onCancel,
    Duration duration = const Duration(seconds: 15),
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: VgAlertType.confirm,
      duration: duration,
      actionLabel: confirmLabel,
      onAction: onConfirm,
      onDismiss: onCancel,
    );
  }

  /// Alert Sukses
  static void success({
    BuildContext? context,
    required String message,
    String title = 'Berhasil',
    Duration duration = const Duration(seconds: 15),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: VgAlertType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Alert Error / Gagal
  static void error({
    BuildContext? context,
    required String message,
    String title = 'Peringatan',
    Duration duration = const Duration(seconds: 15),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: VgAlertType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Alert Info
  static void info({
    BuildContext? context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 15),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: title ?? 'Informasi',
      message: message,
      type: VgAlertType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Tutup alert yang sedang aktif
  static void dismiss({bool immediate = false}) {
    if (immediate) {
      _removeEntry();
      return;
    }
    final state = _activeKey?.currentState;
    if (state != null && state.mounted) {
      state.hide();
    } else {
      _removeEntry();
    }
  }
}

/// Extension helper pada BuildContext untuk pemanggilan instan
extension VgAlertContext on BuildContext {
  void showTopAlert({
    required String message,
    String? title,
    VgAlertType type = VgAlertType.info,
    Duration duration = const Duration(seconds: 15),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    VgAlert.show(
      context: this,
      message: message,
      title: title,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showConfirmAlert({
    required String message,
    String title = 'Konfirmasi',
    String confirmLabel = 'Konfirmasi',
    required VoidCallback onConfirm,
    String cancelLabel = 'Batal',
    VoidCallback? onCancel,
    Duration duration = const Duration(seconds: 15),
  }) {
    VgAlert.confirm(
      context: this,
      message: message,
      title: title,
      confirmLabel: confirmLabel,
      onConfirm: onConfirm,
      cancelLabel: cancelLabel,
      onCancel: onCancel,
      duration: duration,
    );
  }

  void showSuccessAlert(String message, {String title = 'Berhasil', Duration duration = const Duration(seconds: 15)}) {
    VgAlert.success(context: this, message: message, title: title, duration: duration);
  }

  void showErrorAlert(String message, {String title = 'Gagal', Duration duration = const Duration(seconds: 15)}) {
    VgAlert.error(context: this, message: message, title: title, duration: duration);
  }
}

class _VgAlertWidget extends StatefulWidget {
  final _VgAlertSession session;
  final VoidCallback onDismiss;

  const _VgAlertWidget({
    super.key,
    required this.session,
    required this.onDismiss,
  });

  @override
  State<_VgAlertWidget> createState() => _VgAlertWidgetState();
}

class _VgAlertWidgetState extends State<_VgAlertWidget> with TickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<Offset> _enterAnimation;
  late Animation<double> _fadeAnimation;

  AnimationController? _exitController;
  Animation<Offset>? _exitAnimation;

  Timer? _tickTimer;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    // Animasi masuk: meluncur dari kanan ke kiri
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _enterAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0), // Sisi kanan luar layar
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOut,
    );

    _enterController.forward();

    // Loop interval halus (50ms) untuk mengupdate progress bar & sisa detik
    _tickTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (widget.session.remaining <= Duration.zero) {
        timer.cancel();
        hide();
      } else {
        setState(() {});
      }
    });
  }

  void hide() {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    _tickTimer?.cancel();

    // Animasi keluar: meluncur hilang dari kiri ke kanan
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _exitAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.2, 0.0), // Meluncur keluar ke kanan
    ).animate(CurvedAnimation(
      parent: _exitController!,
      curve: Curves.easeInCubic,
    ));

    _exitController!.forward().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _enterController.dispose();
    _exitController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + 10.0;

    return Positioned(
      top: topPadding,
      left: 14.0,
      right: 14.0,
      child: IgnorePointer(
        ignoring: _isExiting,
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            onPanDown: (_) => widget.session.pause(),
            onPanCancel: () => widget.session.resume(),
            onPanEnd: (details) {
              widget.session.resume();
              // Swipe ke kanan untuk dismiss seketika
              if (details.velocity.pixelsPerSecond.dx > 60) {
                hide();
              }
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _enterController,
                _exitController ?? _enterController,
              ]),
              builder: (context, child) {
                final offset = _isExiting && _exitAnimation != null
                    ? _exitAnimation!.value
                    : _enterAnimation.value;
                final opacity = _isExiting && _exitController != null
                    ? (1.0 - _exitController!.value).clamp(0.0, 1.0)
                    : _fadeAnimation.value;
                return FractionalTranslation(
                  translation: offset,
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                );
              },
              child: _buildCardContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    final session = widget.session;
    final isConfirm = session.type == VgAlertType.confirm;
    final isError = session.type == VgAlertType.error;
    final isSuccess = session.type == VgAlertType.success;

    Color cardBg;
    Color borderColor;
    Color textColor;
    Color subTextColor;
    Color badgeBg;
    Color badgeColor;
    Color progressBarColor;
    IconData iconData;

    switch (session.type) {
      case VgAlertType.confirm:
        // Konfirmasi: Maroon mewah + stroke emas + IKON JEMPOL MANTAP
        cardBg = AppColors.primary;
        borderColor = AppColors.goldLight;
        textColor = Colors.white;
        subTextColor = Colors.white.withOpacity(0.85);
        badgeBg = Colors.white.withOpacity(0.18);
        badgeColor = AppColors.goldLight;
        progressBarColor = AppColors.goldLight;
        iconData = Icons.thumb_up_rounded; // Jempol Mantap!
        break;
      case VgAlertType.success:
        cardBg = Colors.white;
        borderColor = AppColors.success;
        textColor = AppColors.textPrimary;
        subTextColor = AppColors.textSecondary;
        badgeBg = AppColors.successBg;
        badgeColor = AppColors.success;
        progressBarColor = AppColors.success;
        iconData = Icons.check_circle_rounded;
        break;
      case VgAlertType.error:
        cardBg = Colors.white;
        borderColor = AppColors.danger;
        textColor = AppColors.textPrimary;
        subTextColor = AppColors.textSecondary;
        badgeBg = AppColors.dangerBg;
        badgeColor = AppColors.danger;
        progressBarColor = AppColors.danger;
        iconData = Icons.error_rounded;
        break;
      case VgAlertType.info:
        cardBg = const Color(0xFF1C2030);
        borderColor = const Color(0xFF4A72E8);
        textColor = Colors.white;
        subTextColor = Colors.white.withOpacity(0.82);
        badgeBg = Colors.white.withOpacity(0.12);
        badgeColor = const Color(0xFF8BA6FF);
        progressBarColor = const Color(0xFF4A72E8);
        iconData = Icons.info_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (isConfirm ? AppColors.gold : Colors.black).withOpacity(0.18),
            blurRadius: 22.0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: badgeColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: badgeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.title ?? (isConfirm ? 'Konfirmasi' : (isSuccess ? 'Berhasil' : (isError ? 'Peringatan' : 'Informasi'))),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Countdown Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isConfirm || session.type == VgAlertType.info ? Colors.black.withOpacity(0.25) : const Color(0xFFF2ECE4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${session.remainingSeconds}s',
                              style: TextStyle(
                                color: isConfirm || session.type == VgAlertType.info ? Colors.white70 : AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        session.message,
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),

                      // Optional Actions
                      if (session.actionLabel != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                session.onAction?.call();
                                hide();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isConfirm ? AppColors.goldLight : AppColors.primary,
                                foregroundColor: isConfirm ? const Color(0xFF4A2A00) : Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                session.actionLabel!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: hide,
                              style: TextButton.styleFrom(
                                foregroundColor: subTextColor,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Tutup',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Close Button (✕)
                IconButton(
                  onPressed: hide,
                  icon: Icon(Icons.close_rounded, size: 18, color: subTextColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  splashRadius: 16,
                ),
              ],
            ),
          ),

          // Micro Countdown Progress Bar at Bottom
          Container(
            height: 3.0,
            width: double.infinity,
            color: Colors.black.withOpacity(0.1),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: session.progress,
              child: Container(
                color: progressBarColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
