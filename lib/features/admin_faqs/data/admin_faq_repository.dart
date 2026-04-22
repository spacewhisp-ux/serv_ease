import '../../../core/network/api_client.dart';

class AdminFaqRepository {
  AdminFaqRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<AdminFaqCategory>> fetchCategories({bool? isActive}) async {
    final response = await _apiClient.get(
      '/admin/faq-categories',
      queryParameters: {'isActive': ?isActive},
    );
    final items = response['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => AdminFaqCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AdminFaqCategory> createCategory({
    required String name,
    required int sortOrder,
    required bool isActive,
  }) async {
    final response = await _apiClient.post(
      '/admin/faq-categories',
      data: {'name': name, 'sortOrder': sortOrder, 'isActive': isActive},
    );
    return AdminFaqCategory.fromJson(response);
  }

  Future<AdminFaqCategory> updateCategory(
    String id, {
    required String name,
    required int sortOrder,
    required bool isActive,
  }) async {
    final response = await _apiClient.patch(
      '/admin/faq-categories/$id',
      data: {'name': name, 'sortOrder': sortOrder, 'isActive': isActive},
    );
    return AdminFaqCategory.fromJson(response);
  }

  Future<void> deactivateCategory(String id) async {
    await _apiClient.delete('/admin/faq-categories/$id');
  }

  Future<AdminFaqListResult> fetchFaqs({
    String? categoryId,
    String? keyword,
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/admin/faqs',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        'isActive': ?isActive,
      },
    );
    final items = response['items'] as List<dynamic>? ?? [];
    final pagination = response['pagination'] as Map<String, dynamic>? ?? {};
    return AdminFaqListResult(
      items: items
          .map((item) => AdminFaqItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int? ?? page,
      pageSize: pagination['pageSize'] as int? ?? pageSize,
      total: pagination['total'] as int? ?? items.length,
      totalPages: pagination['totalPages'] as int? ?? 1,
    );
  }

  Future<AdminFaqItem> fetchFaq(String id) async {
    final response = await _apiClient.get('/admin/faqs/$id');
    return AdminFaqItem.fromJson(response);
  }

  Future<AdminFaqItem> createFaq({
    required String categoryId,
    required String question,
    required String answer,
    required List<String> keywords,
    required int sortOrder,
    required bool isActive,
  }) async {
    final response = await _apiClient.post(
      '/admin/faqs',
      data: {
        'categoryId': categoryId,
        'question': question,
        'answer': answer,
        'keywords': keywords,
        'sortOrder': sortOrder,
        'isActive': isActive,
      },
    );
    return AdminFaqItem.fromJson(response);
  }

  Future<AdminFaqItem> updateFaq(
    String id, {
    required String categoryId,
    required String question,
    required String answer,
    required List<String> keywords,
    required int sortOrder,
    required bool isActive,
  }) async {
    final response = await _apiClient.patch(
      '/admin/faqs/$id',
      data: {
        'categoryId': categoryId,
        'question': question,
        'answer': answer,
        'keywords': keywords,
        'sortOrder': sortOrder,
        'isActive': isActive,
      },
    );
    return AdminFaqItem.fromJson(response);
  }

  Future<void> deactivateFaq(String id) async {
    await _apiClient.delete('/admin/faqs/$id');
  }
}

class AdminFaqCategory {
  const AdminFaqCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  factory AdminFaqCategory.fromJson(Map<String, dynamic> json) {
    return AdminFaqCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String id;
  final String name;
  final int sortOrder;
  final bool isActive;
}

class AdminFaqItem {
  const AdminFaqItem({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.answer,
    required this.keywords,
    required this.viewCount,
    required this.sortOrder,
    required this.isActive,
    this.category,
  });

  factory AdminFaqItem.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    return AdminFaqItem(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      keywords: (json['keywords'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      viewCount: json['viewCount'] as int? ?? 0,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      category: categoryJson is Map<String, dynamic>
          ? AdminFaqCategory.fromJson(categoryJson)
          : null,
    );
  }

  final String id;
  final String categoryId;
  final String question;
  final String answer;
  final List<String> keywords;
  final int viewCount;
  final int sortOrder;
  final bool isActive;
  final AdminFaqCategory? category;
}

class AdminFaqListResult {
  const AdminFaqListResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  final List<AdminFaqItem> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
}
