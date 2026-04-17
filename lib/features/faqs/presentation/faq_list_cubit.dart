import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/faq_repository.dart';

enum FaqListStatus { initial, loading, success, failure }

class FaqListState extends Equatable {
  const FaqListState({
    this.status = FaqListStatus.initial,
    this.categories = const [],
    this.items = const [],
    this.selectedCategoryId,
    this.keyword = '',
    this.errorMessage,
  });

  final FaqListStatus status;
  final List<FaqCategory> categories;
  final List<FaqSummary> items;
  final String? selectedCategoryId;
  final String keyword;
  final String? errorMessage;

  FaqListState copyWith({
    FaqListStatus? status,
    List<FaqCategory>? categories,
    List<FaqSummary>? items,
    String? selectedCategoryId,
    String? keyword,
    String? errorMessage,
  }) {
    return FaqListState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      selectedCategoryId: selectedCategoryId == ''
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      keyword: keyword ?? this.keyword,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    items,
    selectedCategoryId,
    keyword,
    errorMessage,
  ];
}

class FaqListCubit extends Cubit<FaqListState> {
  FaqListCubit({required FaqRepository faqRepository})
    : _faqRepository = faqRepository,
      super(const FaqListState());

  final FaqRepository _faqRepository;

  Future<void> load({String? categoryId, String? keyword}) async {
    emit(
      state.copyWith(
        status: FaqListStatus.loading,
        selectedCategoryId: categoryId ?? state.selectedCategoryId,
        keyword: keyword ?? state.keyword,
      ),
    );

    try {
      final categories = state.categories.isEmpty
          ? await _faqRepository.fetchCategories()
          : state.categories;
      final result = await _faqRepository.fetchFaqs(
        categoryId: categoryId ?? state.selectedCategoryId,
        keyword: keyword ?? state.keyword,
      );
      emit(
        state.copyWith(
          status: FaqListStatus.success,
          categories: categories,
          items: result.items,
          selectedCategoryId: categoryId ?? state.selectedCategoryId,
          keyword: keyword ?? state.keyword,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FaqListStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
