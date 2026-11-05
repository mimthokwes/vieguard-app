import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/storage/cache_storage.dart';
import '../models/report_summary_model.dart';

class ReportProvider extends ChangeNotifier {
  final ApiClient apiClient;
  ReportProvider({required this.apiClient});

  ReportSummary? summary;
  ReportSummary? previous;
  bool isLoading = false;
  String? errorMessage;
  DateTime? _lastFetched;
  DateTime rangeStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime rangeEnd = DateTime.now();

  bool get isFresh =>
      _lastFetched != null && DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5);

  DateTime get previousStart => rangeStart.subtract(rangeEnd.difference(rangeStart) + const Duration(days: 1));

  DateTime get previousEnd => rangeStart.subtract(const Duration(seconds: 1));

  Future<void> initFromCache() async {
    final cached = await CacheStorage.load('report_summary');
    if (cached != null && cached is Map<String, dynamic> && summary == null) {
      try {
        summary = ReportSummary.fromJson(cached['summary'] as Map<String, dynamic>);
        if (cached['previous'] != null) {
          previous = ReportSummary.fromJson(cached['previous'] as Map<String, dynamic>);
        }
        notifyListeners();
      } catch (e) {
        debugPrint('ReportProvider.initFromCache error: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _fetchRaw(DateTime start, DateTime end) async {
    final data = await apiClient.get('/reports/summary', query: {
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
    });
    return data as Map<String, dynamic>;
  }

  Future<void> fetchSummary({bool force = false}) async {
    // In-flight guard: jika sedang memuat dan tidak di-force, lewati
    if (isLoading && !force) {
      return;
    }

    if (!force && isFresh && summary != null) {
      return;
    }

    if (summary == null) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([_fetchRaw(rangeStart, rangeEnd), _fetchRaw(previousStart, previousEnd)]);
      summary = ReportSummary.fromJson(results[0]);
      previous = ReportSummary.fromJson(results[1]);
      _lastFetched = DateTime.now();
      CacheStorage.save('report_summary', {'summary': results[0], 'previous': results[1]});
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setRange(DateTime start, DateTime end) {
    if (rangeStart == start && rangeEnd == end && isFresh && summary != null) {
      return;
    }
    rangeStart = start;
    rangeEnd = end;
    fetchSummary(force: true);
  }
}
