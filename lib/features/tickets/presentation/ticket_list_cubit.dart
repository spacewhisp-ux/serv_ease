import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/ticket_repository.dart';

enum TicketListStatus { initial, loading, success, failure }

class TicketListState extends Equatable {
  const TicketListState({
    this.status = TicketListStatus.initial,
    this.items = const [],
    this.selectedStatus = 'ALL',
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final TicketListStatus status;
  final List<TicketSummary> items;
  final String selectedStatus;
  final int page;
  final int totalPages;
  final int total;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => page < totalPages;

  TicketListState copyWith({
    TicketListStatus? status,
    List<TicketSummary>? items,
    String? selectedStatus,
    int? page,
    int? totalPages,
    int? total,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return TicketListState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    selectedStatus,
    page,
    totalPages,
    total,
    isLoadingMore,
    errorMessage,
  ];
}

class TicketListCubit extends Cubit<TicketListState> {
  TicketListCubit({required TicketRepository ticketRepository})
    : _ticketRepository = ticketRepository,
      super(const TicketListState());

  final TicketRepository _ticketRepository;

  Future<void> load({String? status, bool refresh = false}) async {
    final selectedStatus = status ?? state.selectedStatus;
    emit(
      state.copyWith(
        status: TicketListStatus.loading,
        selectedStatus: selectedStatus,
        errorMessage: null,
      ),
    );

    try {
      final result = await _ticketRepository.fetchTickets(
        status: selectedStatus == 'ALL' ? null : selectedStatus,
        page: 1,
      );
      emit(
        state.copyWith(
          status: TicketListStatus.success,
          items: result.items,
          selectedStatus: selectedStatus,
          page: result.page,
          totalPages: result.totalPages,
          total: result.total,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TicketListStatus.failure,
          isLoadingMore: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.status != TicketListStatus.success) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));

    try {
      final nextPage = state.page + 1;
      final result = await _ticketRepository.fetchTickets(
        status: state.selectedStatus == 'ALL' ? null : state.selectedStatus,
        page: nextPage,
      );
      emit(
        state.copyWith(
          status: TicketListStatus.success,
          items: [...state.items, ...result.items],
          page: result.page,
          totalPages: result.totalPages,
          total: result.total,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
