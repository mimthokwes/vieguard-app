import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/operations_models.dart';
import '../../models/order_model.dart';

/// Mengekspor dan mengunduh berkas ukuran yang telah dikirim oleh pelanggan (.xlsx)
Future<void> downloadCustomerSizeExcel({
  required BuildContext context,
  required Order order,
  List<SizeEntry>? customEntries,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final entries = customEntries ?? order.sizeEntries;

  if (kIsWeb) {
    final lines = [
      'No\tNama Siswa\tL/P\tTinggi Badan (cm)\tUkuran\tPeran\tLingkar Dada (cm)\tLingkar Pinggang (cm)\tLebar Bahu (cm)\tPanjang Lengan (cm)\tPanjang Celana/Rok (cm)\tLingkar Kepala Shako (cm)',
      for (var i = 0; i < entries.length; i++)
        '${i + 1}\t${entries[i].studentName}\t${entries[i].gender ?? '-'}\t${entries[i].heightCm ?? '-'}\t${entries[i].size}\t${entries[i].cleanRole}\t${entries[i].chestCm ?? '-'}\t${entries[i].waistCm ?? '-'}\t${entries[i].shoulderCm ?? '-'}\t${entries[i].armCm ?? '-'}\t${entries[i].pantsCm ?? '-'}\t${entries[i].headCm ?? '-'}',
    ];
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    messenger.showSnackBar(
      const SnackBar(content: Text('Data ukuran disalin ke clipboard.')),
    );
    return;
  }

  try {
    final book = xl.Excel.createExcel();
    final sheet = book[book.getDefaultSheet()!];

    // Jika pesanan memiliki tabel data mentah asli yang diunggah oleh pelanggan
    if (customEntries == null &&
        order.customerRawHeaders != null &&
        order.customerRawHeaders!.isNotEmpty &&
        order.customerRawRows != null &&
        order.customerRawRows!.isNotEmpty) {
      // Gunakan header asli persis dari berkas pelanggan
      sheet.appendRow(order.customerRawHeaders!
          .map((h) => xl.TextCellValue(h))
          .toList());

      for (final row in order.customerRawRows!) {
        final cells = <xl.CellValue>[];
        for (var c = 0; c < row.length; c++) {
          final val = row[c].trim();
          final intVal = int.tryParse(val);
          if (intVal != null && val == intVal.toString()) {
            cells.add(xl.IntCellValue(intVal));
          } else {
            cells.add(xl.TextCellValue(val.isEmpty ? '-' : val));
          }
        }
        sheet.appendRow(cells);
      }
    } else {
      // Susun kolom dinamis sesuai data yang terisi agar tidak ada kolom kosong
      final hasWaist = entries.any((e) => e.waistCm != null);
      final hasShoulder = entries.any((e) => e.shoulderCm != null);

      final headers = [
        'No',
        'Nama Siswa',
        'Jenis Kelamin (L/P)',
        'Tinggi Badan (cm)',
        'Ukuran (XS/S/M/L/XL/XXL)',
        'Peran / Posisi',
        'Lingkar Dada (cm)',
        if (hasWaist) 'Lingkar Pinggang (cm)',
        if (hasShoulder) 'Lebar Bahu (cm)',
        'Panjang Lengan (cm)',
        'Panjang Celana/Rok (cm)',
        'Lingkar Kepala Shako (cm)',
      ];
      sheet.appendRow(headers.map((h) => xl.TextCellValue(h)).toList());

      xl.CellValue intOrDash(int? val) =>
          val != null ? xl.IntCellValue(val) : xl.TextCellValue('-');

      if (entries.isNotEmpty) {
        for (var i = 0; i < entries.length; i++) {
          final e = entries[i];
          sheet.appendRow([
            xl.IntCellValue(i + 1),
            xl.TextCellValue(e.studentName),
            xl.TextCellValue(e.gender ?? '-'),
            intOrDash(e.heightCm),
            xl.TextCellValue(e.size),
            xl.TextCellValue(e.cleanRole),
            intOrDash(e.chestCm),
            if (hasWaist) intOrDash(e.waistCm),
            if (hasShoulder) intOrDash(e.shoulderCm),
            intOrDash(e.armCm),
            intOrDash(e.pantsCm),
            intOrDash(e.headCm),
          ]);
        }
      } else if (order.sizeBreakdown.isNotEmpty) {
        var counter = 1;
        order.sizeBreakdown.forEach((size, qty) {
          for (var q = 0; q < qty; q++) {
            sheet.appendRow([
              xl.IntCellValue(counter++),
              xl.TextCellValue('Siswa $counter'),
              xl.TextCellValue('-'),
              xl.TextCellValue('-'),
              xl.TextCellValue(size),
              xl.TextCellValue('-'),
              xl.TextCellValue('-'),
              if (hasWaist) xl.TextCellValue('-'),
              if (hasShoulder) xl.TextCellValue('-'),
              xl.TextCellValue('-'),
              xl.TextCellValue('-'),
              xl.TextCellValue('-'),
            ]);
          }
        });
      }
    }

    final bytes = book.encode();
    if (bytes == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Gagal membuat berkas Excel.')));
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final rawName = order.customerFileName ?? 'Ukuran_Pesanan_${order.orderNumber}.xlsx';
    final safeName = rawName.replaceAll(RegExp(r'[^\w\.-]'), '_');
    final finalFileName = safeName.endsWith('.xlsx') ? safeName : '$safeName.xlsx';
    final path = '${dir.path}/$finalFileName';

    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    messenger.showSnackBar(
      SnackBar(
        content: Text('Berkas berhasil diunduh: $finalFileName'),
        action: SnackBarAction(
          label: 'Buka',
          textColor: AppColors.goldLight,
          onPressed: () => OpenFilex.open(path),
        ),
      ),
    );

    await OpenFilex.open(path);
  } catch (e) {
    debugPrint('Gagal unduh berkas ukuran pelanggan: $e');
    messenger.showSnackBar(
      SnackBar(content: Text('Gagal mengunduh berkas ukuran: $e')),
    );
  }
}
