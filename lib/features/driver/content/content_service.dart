import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class ContentFaqItem {
  final int id;
  final String questionAr;
  final String questionEn;
  final String answerAr;
  final String answerEn;
  final int sortOrder;

  ContentFaqItem({
    required this.id,
    required this.questionAr,
    required this.questionEn,
    required this.answerAr,
    required this.answerEn,
    required this.sortOrder,
  });

  factory ContentFaqItem.fromJson(Map<String, dynamic> j) => ContentFaqItem(
        id: j['id'] as int? ?? 0,
        questionAr: j['questionAr']?.toString() ?? '',
        questionEn: j['questionEn']?.toString() ?? '',
        answerAr: j['answerAr']?.toString() ?? '',
        answerEn: j['answerEn']?.toString() ?? '',
        sortOrder: j['sortOrder'] as int? ?? 0,
      );

  String question(bool isAr) => isAr ? questionAr : questionEn;
  String answer(bool isAr) => isAr ? answerAr : answerEn;
}

class ContentService {
  ContentService._();
  static final instance = ContentService._();

  Future<List<ContentFaqItem>> fetchFaq({String audience = 'driver'}) async {
    final uri = Uri.parse('${Api.base}${Api.contentFaq}?audience=$audience');
    final res = await http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return [];
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    final list = body is List ? body : (body['items'] as List? ?? []);
    return list
        .map((e) => ContentFaqItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
