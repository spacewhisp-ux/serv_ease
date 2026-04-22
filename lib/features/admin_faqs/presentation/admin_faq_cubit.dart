import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/admin_faq_repository.dart';

enum AdminFaqStatus { initial, loading, success, failure }

enum AdminFaqFilter { active, inactive, all }

class AdminFaqState extends Equatable {
  const AdminFaqState({
    this.status = AdminFaqStatus.initial,
    this.categories = const [],
    this.items = const [],
    this.selectedCategoryId,
    this.keyword = '',
    this.filter = AdminFaqFilter.active,
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.errorMessage,
    this.isMutating = false,
  });

  final AdminFaqStatus status;
  final List<AdminFaqCategory> categories;
  final List<AdminFaqItem> items;
  final String? selectedCategoryId;
  final String keyword;
  final AdminFaqFilter filter;
  final int page;
  final int pageSize;
  final int total;
  final String? errorMessage;
  final bool isMutating;

  bool get hasLoaded => status == AdminFaqStatus.success;

  AdminFaqState copyWith({
    AdminFaqStatus? status,
    List<AdminFaqCategory>? categories,
    List<AdminFaqItem>? items,
    String? selectedCategoryId,
    String? keyword,
    AdminFaqFilter? filter,
    int? page,
    int? pageSize,
    int? total,
    String? errorMessage,
    bool? isMutating,
    bool clearSelectedCategory = false,
  }) {
    return AdminFaqState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      selectedCategoryId: clearSelectedCategory
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      keyword: keyword ?? this.keyword,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      errorMessage: errorMessage,
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    items,
    selectedCategoryId,
    keyword,
    filter,
    page,
    pageSize,
    total,
    errorMessage,
    isMutating,
  ];
}

class AdminFaqCubit extends Cubit<AdminFaqState> {
  AdminFaqCubit({required AdminFaqRepository adminFaqRepository})
    : _adminFaqRepository = adminFaqRepository,
      super(const AdminFaqState());

  final AdminFaqRepository _adminFaqRepository;

  Future<void> load({
    String? categoryId,
    String? keyword,
    AdminFaqFilter? filter,
    bool refreshCategories = false,
  }) async {
    final nextCategoryId = categoryId ?? state.selectedCategoryId;
    final nextKeyword = keyword ?? state.keyword;
    final nextFilter = filter ?? state.filter;

    emit(
      state.copyWith(
        status: AdminFaqStatus.loading,
        selectedCategoryId: nextCategoryId,
        keyword: nextKeyword,
        filter: nextFilter,
        errorMessage: null,
      ),
    );

    try {
      final categories = refreshCategories || state.categories.isEmpty
          ? await _adminFaqRepository.fetchCategories()
          : state.categories;
      final result = await _adminFaqRepository.fetchFaqs(
        categoryId: nextCategoryId,
        keyword: nextKeyword,
        isActive: _mapFilter(nextFilter),
        page: state.page,
        pageSize: state.pageSize,
      );
      emit(
        state.copyWith(
          status: AdminFaqStatus.success,
          categories: categories,
          items: result.items,
          selectedCategoryId: nextCategoryId,
          keyword: nextKeyword,
          filter: nextFilter,
          page: result.page,
          pageSize: result.pageSize,
          total: result.total,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminFaqStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> createCategory({
    required String name,
    required int sortOrder,
    required bool isActive,
  }) async {
    await _runMutation(() async {
      await _adminFaqRepository.createCategory(
        name: name,
        sortOrder: sortOrder,
        isActive: isActive,
      );
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required int sortOrder,
    required bool isActive,
  }) async {
    await _runMutation(() async {
      await _adminFaqRepository.updateCategory(
        id,
        name: name,
        sortOrder: sortOrder,
        isActive: isActive,
      );
    });
  }

  Future<void> deactivateCategory(String id) async {
    await _runMutation(() async {
      await _adminFaqRepository.deactivateCategory(id);
    });
  }

  Future<void> createFaq({
    required String categoryId,
    required String question,
    required String answer,
    required List<String> keywords,
    required int sortOrder,
    required bool isActive,
  }) async {
    await _runMutation(() async {
      await _adminFaqRepository.createFaq(
        categoryId: categoryId,
        question: question,
        answer: answer,
        keywords: keywords,
        sortOrder: sortOrder,
        isActive: isActive,
      );
    });
  }

  Future<void> updateFaq({
    required String id,
    required String categoryId,
    required String question,
    required String answer,
    required List<String> keywords,
    required int sortOrder,
    required bool isActive,
  }) async {
    await _runMutation(() async {
      await _adminFaqRepository.updateFaq(
        id,
        categoryId: categoryId,
        question: question,
        answer: answer,
        keywords: keywords,
        sortOrder: sortOrder,
        isActive: isActive,
      );
    });
  }

  Future<void> deactivateFaq(String id) async {
    await _runMutation(() async {
      await _adminFaqRepository.deactivateFaq(id);
    });
  }

  Future<AdminFaqItem> fetchFaq(String id) {
    return _adminFaqRepository.fetchFaq(id);
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    emit(state.copyWith(isMutating: true, errorMessage: null));
    try {
      await action();
      emit(state.copyWith(isMutating: false, errorMessage: null));
      await load(refreshCategories: true);
    } catch (error) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: error.toString(),
          status: AdminFaqStatus.failure,
        ),
      );
      rethrow;
    }
  }

  bool? _mapFilter(AdminFaqFilter filter) {
    switch (filter) {
      case AdminFaqFilter.active:
        return true;
      case AdminFaqFilter.inactive:
        return false;
      case AdminFaqFilter.all:
        return null;
    }
  }
}
