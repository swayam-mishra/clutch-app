import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/expenses/providers/expense_provider.dart';

Future<void> exportExpensesCsv(List<Expense> expenses) async {
  final buffer = StringBuffer();
  buffer.writeln('date,time,tag,category,amount');
  for (final e in expenses) {
    buffer.writeln(
        '${e.date},${e.time},${e.tag},${e.category},${e.amount.toStringAsFixed(2)}');
  }

  final dir = await getTemporaryDirectory();
  final shareDir = Directory('${dir.path}/share_plus');
  if (!await shareDir.exists()) await shareDir.create();
  final file = File('${shareDir.path}/clutch_expenses.csv');
  await file.writeAsString(buffer.toString());

  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/csv')],
    subject: 'Clutch Expenses',
  );
}
