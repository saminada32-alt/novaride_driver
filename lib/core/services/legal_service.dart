import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class LegalDocumentView {
  final String slug;
  final String version;
  final String title;
  final String summary;
  final List<LegalSectionView> sections;

  LegalDocumentView({
    required this.slug,
    required this.version,
    required this.title,
    required this.summary,
    required this.sections,
  });

  factory LegalDocumentView.fromJson(Map<String, dynamic> j) => LegalDocumentView(
        slug: j['slug']?.toString() ?? '',
        version: j['version']?.toString() ?? '1.0',
        title: j['title']?.toString() ?? '',
        summary: j['summary']?.toString() ?? '',
        sections: (j['sections'] as List<dynamic>? ?? [])
            .map((s) => LegalSectionView.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class LegalSectionView {
  final String id;
  final String title;
  final List<String> paragraphs;

  LegalSectionView({
    required this.id,
    required this.title,
    required this.paragraphs,
  });

  factory LegalSectionView.fromJson(Map<String, dynamic> j) => LegalSectionView(
        id: j['id']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        paragraphs: (j['paragraphs'] as List<dynamic>? ?? [])
            .map((p) => p.toString())
            .toList(),
      );
}

class LegalService {
  LegalService._();
  static final instance = LegalService._();

  static const _h = {'Accept': 'application/json'};

  Future<List<LegalDocumentView>> fetchDriverBundle({required bool isAr}) async {
    final lang = isAr ? 'ar' : 'en';
    final privacy = await _fetch('driver-privacy', lang);
    final terms = await _fetch('driver-terms', lang);
    return [privacy, terms];
  }

  Future<LegalDocumentView> _fetch(String slug, String lang) async {
    final uri = Uri.parse(
      '${Api.base}${Api.legalDocument(slug)}?lang=$lang',
    );
    final res = await http.get(uri, headers: _h).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Failed to load legal document');
    return LegalDocumentView.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }

  List<Map<String, String>> driverConsents() => const [
        {'slug': 'driver-privacy', 'version': '1.0'},
        {'slug': 'driver-terms', 'version': '1.0'},
      ];
}
