import '../../../core/network/api_client.dart';

class FaqRepository {
  FaqRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<FaqCategory>> fetchCategories() async {
    final response = await _apiClient.get('/faq-categories');
    final items = response['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => FaqCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FaqListResult> fetchFaqs({String? categoryId, String? keyword}) async {
    final response = await _apiClient.get(
      '/faqs',
      queryParameters: {
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
    );
    final items = response['items'] as List<dynamic>? ?? [];
    final pagination = response['pagination'] as Map<String, dynamic>? ?? {};
    return FaqListResult(
      items: items
          .map((item) => FaqSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: pagination['total'] as int? ?? items.length,
    );
  }

  Future<FaqDetail> fetchFaqDetail(String id) async {
    final response = await _apiClient.get('/faqs/$id');
    return FaqDetail.fromJson(response);
  }
}

class FaqCategory {
  const FaqCategory({required this.id, required this.name});

  factory FaqCategory.fromJson(Map<String, dynamic> json) {
    return FaqCategory(id: json['id'] as String, name: json['name'] as String);
  }

  final String id;
  final String name;
}

class FaqSummary {
  const FaqSummary({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.answerPreview,
    required this.viewCount,
  });

  factory FaqSummary.fromJson(Map<String, dynamic> json) {
    return FaqSummary(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      question: json['question'] as String,
      answerPreview: json['answerPreview'] as String,
      viewCount: json['viewCount'] as int? ?? 0,
    );
  }

  final String id;
  final String categoryId;
  final String question;
  final String answerPreview;
  final int viewCount;
}

class FaqDetail {
  const FaqDetail({
    required this.id,
    required this.question,
    required this.answer,
    required this.keywords,
  });

  factory FaqDetail.fromJson(Map<String, dynamic> json) {
    return FaqDetail(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      keywords: (json['keywords'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  final String id;
  final String question;
  final String answer;
  final List<String> keywords;
}

class FaqListResult {
  const FaqListResult({required this.items, required this.total});

  final List<FaqSummary> items;
  final int total;
}
