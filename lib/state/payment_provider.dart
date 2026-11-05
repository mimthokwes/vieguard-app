import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/storage/cache_storage.dart';
import '../core/storage/image_cache_service.dart';
import '../models/order_status.dart';
import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  final ApiClient apiClient;
  PaymentProvider({required this.apiClient});

  List<Payment> _payments = [];
  bool isLoading = false;
  String? errorMessage;
  DateTime? _lastFetched;
  PaymentStatus? _currentStatus;

  bool get isFresh =>
      _lastFetched != null && DateTime.now().difference(_lastFetched!) < const Duration(minutes: 3);

  List<Payment> get payments => List.unmodifiable(_payments);

  int countByStatus(PaymentStatus status) => _payments.where((p) => p.status == status).length;

  /// Muat data dari penyimpanan lokal saat inisialisasi awal
  Future<void> initFromCache() async {
    final cached = await CacheStorage.load('payments_list_menunggu') ?? await CacheStorage.load('payments_list');
    if (cached != null && cached is List && _payments.isEmpty) {
      try {
        _payments = cached.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
        _currentStatus = PaymentStatus.menunggu;
        notifyListeners();
        final proofs = _payments.map((p) => p.proofImage).whereType<String>().toList();
        ImageCacheService.prefetchAll(proofs);
      } catch (e) {
        debugPrint('PaymentProvider.initFromCache error: $e');
      }
    }
  }

  Future<void> fetchPayments({PaymentStatus? status, bool force = false}) async {
    // In-flight guard: jika sedang memuat status yang sama dan tidak di-force, lewati
    if (isLoading && !force && _currentStatus == status) {
      return;
    }

    // Cache freshness guard: jika data masih fresh, ada di memori, dan status sama, lewati
    if (!force && isFresh && _payments.isNotEmpty && _currentStatus == status) {
      return;
    }

    if (_payments.isEmpty || _currentStatus != status) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final query = <String, dynamic>{};
      if (status != null) query['status'] = paymentStatusToApi(status);
      final data = await apiClient.get('/payments', query: query);
      _payments = (data as List<dynamic>).map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
      _lastFetched = DateTime.now();
      _currentStatus = status;

      final cacheKey = status == null ? 'payments_list' : 'payments_list_${status.name}';
      CacheStorage.save(cacheKey, data);
      final proofs = _payments.map((p) => p.proofImage).whereType<String>().toList();
      ImageCacheService.prefetchAll(proofs);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyPayment(String id, {required bool approve, String? refundReason}) async {
    try {
      await apiClient.patch('/payments/$id/verify', data: {
        'status': approve ? 'terverifikasi' : 'ditolak',
        if (!approve && refundReason != null) 'refundReason': refundReason,
      });
      await fetchPayments();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
