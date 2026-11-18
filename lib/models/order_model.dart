import 'dart:convert';

import '../core/utils/parsing.dart';
import 'custom_order_detail_model.dart';
import 'customer_model.dart';
import 'order_item_model.dart';
import 'order_status.dart';
import 'order_status_history_model.dart';
import 'operations_models.dart';
import 'payment_model.dart';
import 'rental_model.dart';

class Order {
  final String id;
  final String orderNumber;
  final OrderType orderType;
  final bool requiresProduction;
  final OrderStatus status;
  final double totalPrice;
  final double? dpAmount;
  final bool isLunas;
  final DateTime? deadlineDate;
  final String? notes;
  final DateTime createdAt;
  final Customer customer;
  final List<OrderItem> items;
  final CustomOrderDetail? customOrderDetail;
  final Rental? rental;
  final List<Payment> payments;
  final List<OrderStatusHistoryEntry> statusHistory;
  final String? courier;
  final String? trackingNumber;
  final double? shippingCost;
  final DateTime? shippedAt;
  final DateTime? etaDate;
  final List<SizeEntry> sizeEntries;
  final List<OrderPhoto> photos;
  final List<String>? customerRawHeaders;
  final List<List<String>>? customerRawRows;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.requiresProduction,
    required this.status,
    required this.totalPrice,
    this.dpAmount,
    required this.isLunas,
    this.deadlineDate,
    this.notes,
    required this.createdAt,
    required this.customer,
    required this.items,
    this.customOrderDetail,
    this.rental,
    required this.payments,
    required this.statusHistory,
    this.courier,
    this.trackingNumber,
    this.shippingCost,
    this.shippedAt,
    this.etaDate,
    this.sizeEntries = const [],
    this.photos = const [],
    this.customerRawHeaders,
    this.customerRawRows,
  });

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  double get amountPaid => payments.where((p) => p.status == PaymentStatus.terverifikasi).fold(0, (sum, p) => sum + p.amount);

  double get sisaTagihan => (totalPrice - amountPaid).clamp(0, double.infinity);

  int get latestProgress => statusHistory.isEmpty ? 0 : statusHistory.last.progressPercentage;

  Payment? get pendingPayment => payments.where((p) => p.status == PaymentStatus.menunggu).firstOrNull;

  bool get awaitingSettlement =>
      totalPrice > 0 && sisaTagihan > 0 && (status == OrderStatus.diproses || status == OrderStatus.siapDiambil) && (!requiresProduction || latestProgress >= 100);

  bool get butuhTindakan => status == OrderStatus.pending;

  bool get isCustom => orderType == OrderType.custom;

  bool get isBeli => orderType == OrderType.beli;

  String? get customerFileName {
    final note = customOrderDetail?.consultationNote;
    if (note != null && note.isNotEmpty) {
      if (note.contains('"fileName"')) {
        final matchJson = RegExp(r'"fileName"\s*:\s*"([^"]+)"').firstMatch(note);
        if (matchJson != null) return matchJson.group(1)?.trim();
      }
      final match = RegExp(r'(?:rosterFile|Berkas Ukuran):\s*([^\r\n]+)', caseSensitive: false).firstMatch(note);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    if (notes != null && notes!.isNotEmpty) {
      final match = RegExp(r'Berkas Ukuran:\s*([^\r\n—]+)', caseSensitive: false).firstMatch(notes!);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    final ref = customOrderDetail?.designReference;
    if (ref != null && ref.isNotEmpty) {
      final lower = ref.toLowerCase();
      if (lower.endsWith('.xlsx') || lower.endsWith('.csv') || lower.endsWith('.xls') || lower.endsWith('.pdf')) {
        return ref.split('/').last;
      }
    }
    return null;
  }

  bool get hasCustomerFile => customerFileName != null;

  bool get isCustomerFilePdf {
    final fn = (customerFileName ?? '').toLowerCase();
    return fn.endsWith('.pdf') || (notes?.toLowerCase().contains('(pdf)') ?? false);
  }

  bool get isCustomerFileExcel {
    final fn = (customerFileName ?? '').toLowerCase();
    return fn.endsWith('.xlsx') || fn.endsWith('.xls') || fn.endsWith('.csv') || (notes?.toLowerCase().contains('(excel)') ?? false);
  }

  bool get needsQuote => isCustom && status == OrderStatus.pending && totalPrice <= 0;

  String get headline => items.isNotEmpty ? items.first.name : (customOrderDetail?.jenisJenjang ?? 'Pesanan ${orderType.label}');

  String? get coverImage {
    for (final item in items) {
      if (item.imageUrl != null) return item.imageUrl;
    }
    return customOrderDetail?.designReference;
  }

  String? get latestStatusLabel => statusHistory.isEmpty ? null : statusHistory.last.statusLabel;

  bool get hasStudentSizes => sizeEntries.isNotEmpty;

  bool get isShipped => shippedAt != null;

  List<OrderPhoto> photosIn(String category) => photos.where((p) => p.category == category).toList();

  Map<String, int> get sizeBreakdown {
    final map = <String, int>{};
    if (sizeEntries.isNotEmpty) {
      for (final e in sizeEntries) {
        map[e.size] = (map[e.size] ?? 0) + 1;
      }
      return map;
    }
    for (final item in items) {
      if (item.size == null || item.size!.isEmpty) continue;
      map[item.size!] = (map[item.size!] ?? 0) + item.quantity;
    }
    return map;
  }

  int get sizedQuantity => sizeBreakdown.values.fold(0, (sum, q) => sum + q);

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawSizeEntries = (json['orderSizeEntries'] as List<dynamic>? ?? [])
        .map((e) => SizeEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    // Integrasi otomatis jika metadata roster JSON ada di consultationNote
    final consultNote = json['customOrderDetail'] is Map<String, dynamic>
        ? json['customOrderDetail']['consultationNote'] as String?
        : null;

    List<SizeEntry> finalSizeEntries = rawSizeEntries;
    List<String>? rawHeaders;
    List<List<String>>? rawRows;

    if (consultNote != null && consultNote.contains('===ROSTER_JSON_START===')) {
      try {
        const startTag = '===ROSTER_JSON_START===';
        const endTag = '===ROSTER_JSON_END===';
        final startIdx = consultNote.indexOf(startTag) + startTag.length;
        final endIdx = consultNote.indexOf(endTag, startIdx);
        if (endIdx > startIdx) {
          final jsonStr = consultNote.substring(startIdx, endIdx).trim();
          final decoded = jsonDecode(jsonStr);

          List<dynamic> rowsList = [];
          if (decoded is Map<String, dynamic>) {
            if (decoded['rawHeaders'] is List) {
              rawHeaders = (decoded['rawHeaders'] as List)
                  .map((e) => e?.toString() ?? '')
                  .toList();
            }
            if (decoded['rawRows'] is List) {
              rawRows = (decoded['rawRows'] as List).map((row) {
                if (row is List) {
                  return row.map((c) => c?.toString() ?? '').toList();
                }
                return <String>[];
              }).toList();
            }
            if (decoded['rows'] is List) {
              rowsList = decoded['rows'] as List<dynamic>;
            }
          } else if (decoded is List) {
            rowsList = decoded;
          }

          final parsedJsonEntries = rowsList
              .map((e) => SizeEntry.fromJson(e as Map<String, dynamic>))
              .toList();

          if (rawSizeEntries.isNotEmpty && parsedJsonEntries.isNotEmpty) {
            finalSizeEntries = [
              for (var i = 0; i < rawSizeEntries.length; i++)
                i < parsedJsonEntries.length
                    ? rawSizeEntries[i].copyWith(
                        chestCm: parsedJsonEntries[i].chestCm ?? rawSizeEntries[i].chestCm,
                        waistCm: parsedJsonEntries[i].waistCm ?? rawSizeEntries[i].waistCm,
                        shoulderCm: parsedJsonEntries[i].shoulderCm ?? rawSizeEntries[i].shoulderCm,
                        armCm: parsedJsonEntries[i].armCm ?? rawSizeEntries[i].armCm,
                        pantsCm: parsedJsonEntries[i].pantsCm ?? rawSizeEntries[i].pantsCm,
                        headCm: parsedJsonEntries[i].headCm ?? rawSizeEntries[i].headCm,
                      )
                    : rawSizeEntries[i],
            ];
          } else if (rawSizeEntries.isEmpty && parsedJsonEntries.isNotEmpty) {
            finalSizeEntries = parsedJsonEntries;
          }
        }
      } catch (_) {
        // Fallback ke raw entries
      }
    }

    return Order(
        id: json['id'].toString(),
        orderNumber: json['orderNumber'] as String,
        orderType: orderTypeFromApi(json['orderType'] as String),
        requiresProduction: json['requiresProduction'] as bool? ?? false,
        status: orderStatusFromApi(json['status'] as String),
        totalPrice: parseDecimal(json['totalPrice']),
        dpAmount: parseDecimalOrNull(json['dpAmount']),
        isLunas: json['isLunas'] as bool? ?? false,
        deadlineDate: parseDateOrNull(json['deadlineDate']),
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        customer: Customer.fromJson(json['user'] as Map<String, dynamic>? ?? {'id': '0', 'name': 'Pelanggan'}),
        items: (json['items'] as List<dynamic>? ?? []).map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList(),
        customOrderDetail: json['customOrderDetail'] != null
            ? CustomOrderDetail.fromJson(json['customOrderDetail'] as Map<String, dynamic>)
            : null,
        rental: json['rental'] != null ? Rental.fromJson(json['rental'] as Map<String, dynamic>) : null,
        payments: (json['payments'] as List<dynamic>? ?? []).map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList(),
        statusHistory: (json['statusHistory'] as List<dynamic>? ?? [])
            .map((e) => OrderStatusHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        courier: json['courier'] as String?,
        trackingNumber: json['trackingNumber'] as String?,
        shippingCost: parseDecimalOrNull(json['shippingCost']),
        shippedAt: parseDateOrNull(json['shippedAt'])?.toLocal(),
        etaDate: parseDateOrNull(json['etaDate']),
        sizeEntries: finalSizeEntries,
        photos: (json['orderPhotos'] as List<dynamic>? ?? []).map((e) => OrderPhoto.fromJson(e as Map<String, dynamic>)).toList(),
        customerRawHeaders: rawHeaders,
        customerRawRows: rawRows,
      );
  }
}
