import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/logger.dart';
import '../../core/utils/amount_utils.dart';
import '../../core/utils/date_utils.dart';
import '../entities/gift_record.dart';

/// 导出格式（设计文档 §12.3：A 阶段支持 JSON/CSV/PDF 三种）
enum ExportFormat { json, csv, pdf }

class ExportResult {
  const ExportResult({required this.file, required this.format});

  final File file;
  final ExportFormat format;
}

/// 设计文档 §12.3：A-2 导出服务
///
/// - JSON：全量备份（含 schema version + 所有记录），可用于跨设备恢复
/// - CSV：礼簿表格，Excel 直接打开
/// - PDF：年度礼簿可读版（首版简化：A4 表格 + 红榜/白榜分区）
class ExportService {
  ExportService();

  Future<ExportResult> exportToJson(List<GiftRecord> records) async {
    try {
      final payload = <String, Object?>{
        'schema': 1,
        'app': 'liwanglai',
        'exportedAt': DateTime.now().toIso8601String(),
        'records': records.map(_recordToMap).toList(),
      };
      final file = await _writeTempFile(
        'liwanglai_records_${_stamp()}.json',
        const JsonEncoder.withIndent('  ').convert(payload),
      );
      return ExportResult(file: file, format: ExportFormat.json);
    } catch (e, st) {
      AppLogger.instance.e('导出 JSON 失败', error: e, stack: st);
      throw ExportException('导出 JSON 失败', cause: e, stackTrace: st);
    }
  }

  Future<ExportResult> exportToCsv(List<GiftRecord> records) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln(
        '日期,姓名,关系,事项,收/回,调性,记录方式,金额,备注',
      );
      for (final r in records) {
        buffer.writeln(
          [
            AppDateUtils.slash(r.eventDate),
            _csv(r.name),
            _csv(r.relation),
            _csv(r.event),
            r.direction.label,
            r.tone == EventTone.white ? '白事' : '喜事',
            r.method,
            r.amount.toString(),
            _csv(r.note),
          ].join(','),
        );
      }
      final file = await _writeTempFile(
        'liwanglai_records_${_stamp()}.csv',
        // BOM 让 Excel 直接识别 UTF-8
        '\uFEFF${buffer.toString()}',
      );
      return ExportResult(file: file, format: ExportFormat.csv);
    } catch (e, st) {
      AppLogger.instance.e('导出 CSV 失败', error: e, stack: st);
      throw ExportException('导出 CSV 失败', cause: e, stackTrace: st);
    }
  }

  Future<ExportResult> exportToPdf(List<GiftRecord> records) async {
    try {
      final doc = pw.Document(
        title: '礼往来 · 年度礼簿',
        author: '礼往来',
      );
      final grouped = _groupByMonth(records);
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(36, 48, 36, 48),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                '礼往来 · 礼簿',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '导出时间 ${AppDateUtils.chinese(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 16),
            ...grouped.entries.map(
              (e) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(
                    level: 1,
                    child: pw.Text(
                      e.key,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.TableHelper.fromTextArray(
                    border: pw.TableBorder.all(
                      color: PdfColors.grey400,
                      width: 0.5,
                    ),
                    headerStyle:
                        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    cellStyle: const pw.TextStyle(fontSize: 10),
                    cellAlignment: pw.Alignment.centerLeft,
                    headerAlignment: pw.Alignment.centerLeft,
                    headers: const ['日期', '姓名', '事项', '收/回', '金额'],
                    data: e.value
                        .map(
                          (r) => [
                            AppDateUtils.slash(r.eventDate),
                            r.name,
                            r.eventType,
                            r.direction.label,
                            AmountUtils.format(r.amount),
                          ],
                        )
                        .toList(),
                  ),
                  pw.SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      );
      final file = await _writeTempFileBytes(
        'liwanglai_ledger_${_stamp()}.pdf',
        await doc.save(),
      );
      return ExportResult(file: file, format: ExportFormat.pdf);
    } catch (e, st) {
      AppLogger.instance.e('导出 PDF 失败', error: e, stack: st);
      throw ExportException('导出 PDF 失败', cause: e, stackTrace: st);
    }
  }

  Future<void> share(ExportResult result, {String? subject}) async {
    try {
      await Share.shareXFiles(
        [XFile(result.file.path)],
        subject: subject ?? '礼往来礼簿',
      );
    } catch (e, st) {
      AppLogger.instance.e('分享导出文件失败', error: e, stack: st);
      throw ExportException('分享导出文件失败', cause: e, stackTrace: st);
    }
  }

  String _csv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Map<String, Object?> _recordToMap(GiftRecord r) => {
        'id': r.id,
        'book': r.book,
        'name': r.name,
        'relation': r.relation,
        'event': r.event,
        'direction': r.direction.wire,
        'tone': r.tone.wire,
        'method': r.method,
        'amount': r.amount,
        'date': r.date.millisecondsSinceEpoch,
        'note': r.note,
        'itemDescription': r.itemDescription,
        'partial': r.partial,
        'needReturn': r.needReturn,
      };

  Map<String, List<GiftRecord>> _groupByMonth(List<GiftRecord> records) {
    final sorted = [...records]
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
    final map = <String, List<GiftRecord>>{};
    for (final r in sorted) {
      final key = '${r.eventDate.year}年${r.eventDate.month}月';
      map.putIfAbsent(key, () => []).add(r);
    }
    return map;
  }

  String _stamp() {
    final n = DateTime.now();
    final ymd =
        '${n.year}${n.month.toString().padLeft(2, '0')}${n.day.toString().padLeft(2, '0')}';
    final hms =
        '${n.hour.toString().padLeft(2, '0')}${n.minute.toString().padLeft(2, '0')}${n.second.toString().padLeft(2, '0')}';
    return '${ymd}_$hms';
  }

  Future<File> _writeTempFile(String name, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    return file.writeAsString(content, flush: true);
  }

  Future<File> _writeTempFileBytes(String name, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    return file.writeAsBytes(bytes, flush: true);
  }

  // ===== JSON 导入恢复 =====

  /// 通过文件选择器选取 JSON 备份文件，返回解析后的记录列表。
  /// 如果文件格式不正确会抛出 [ImportException]。
  Future<List<GiftRecord>> pickAndImportJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) {
        return const [];
      }
      final file = File(result.files.single.path!);
      return importFromJsonFile(file);
    } catch (e, st) {
      if (e is ImportException) rethrow;
      AppLogger.instance.e('选取导入文件失败', error: e, stack: st);
      throw ImportException('选取导入文件失败', cause: e, stackTrace: st);
    }
  }

  /// 从指定文件导入 JSON 备份。
  Future<List<GiftRecord>> importFromJsonFile(File file) async {
    try {
      final content = await file.readAsString();
      return importFromJsonString(content);
    } catch (e, st) {
      if (e is ImportException) rethrow;
      AppLogger.instance.e('读取导入文件失败', error: e, stack: st);
      throw ImportException('读取导入文件失败', cause: e, stackTrace: st);
    }
  }

  /// 从 JSON 字符串解析记录列表。
  List<GiftRecord> importFromJsonString(String jsonString) {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw ImportException('JSON 格式错误：根节点必须是对象');
      }
      final schema = decoded['schema'] as int?;
      if (schema == null || schema < 1) {
        throw ImportException('JSON 格式错误：缺少有效的 schema 版本');
      }
      final app = decoded['app'] as String?;
      if (app != 'liwanglai') {
        throw ImportException('JSON 格式错误：不是礼往来的备份文件');
      }
      final recordsJson = decoded['records'];
      if (recordsJson is! List) {
        throw ImportException('JSON 格式错误：缺少 records 数组');
      }
      return recordsJson
          .map((e) => _recordFromMap(e as Map<String, dynamic>))
          .toList();
    } on ImportException {
      rethrow;
    } catch (e, st) {
      throw ImportException('JSON 解析失败：$e', cause: e, stackTrace: st);
    }
  }

  GiftRecord _recordFromMap(Map<String, dynamic> m) {
    return GiftRecord(
      id: m['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: m['name'] as String? ?? '',
      relation: m['relation'] as String? ?? '',
      event: m['event'] as String? ?? '',
      direction: GiftDirection.fromWire(m['direction'] as String?),
      tone: EventTone.fromWire(m['tone'] as String?),
      method: m['method'] as String? ?? '现金',
      amount: (m['amount'] as num?)?.toInt() ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(
        (m['date'] as num?)?.toInt() ?? 0,
      ),
      book: m['book'] as String? ?? '我家',
      note: m['note'] as String? ?? '',
      itemDescription: m['itemDescription'] as String? ?? '',
      partial: m['partial'] as bool? ?? false,
      needReturn: m['needReturn'] as bool? ?? false,
    );
  }
}