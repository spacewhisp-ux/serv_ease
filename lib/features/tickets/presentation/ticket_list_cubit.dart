import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/ticket_repository.dart';

enum TicketListStatus { initial, loading, success, failure }

class TicketListState extends Equatable {
  const TicketListState({
    this.status = TicketListStatus.initial,
    this.items = const [],
    this.selectedStatus = 'ALL',
    this.errorMessage,
  });

  final TicketListStatus status;
  final List<TicketSummary> items;
  final String selectedStatus;
  final String? errorMessage;

  TicketListState copyWith({
    TicketListStatus? status,
    List<TicketSummary>? items,
    String? selectedStatus,
    String? errorMessage,
  }) {
    return TicketListState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, selectedStatus, errorMessage];
}

class TicketListCubit extends Cubit<TicketListState> {
  TicketListCubit({required TicketRepository ticketRepository})
    : _ticketRepository = ticketRepository,
      super(const TicketListState());

  final TicketRepository _ticketRepository;

  Future<void> load({String? status}) async {
    final selectedStatus = status ?? state.selectedStatus;
    emit(
      state.copyWith(
        status: TicketListStatus.loading,
        selectedStatus: selectedStatus,
      ),
    );

    try {
      final result = await _ticketRepository.fetchTickets(
        status: selectedStatus == 'ALL' ? null : selectedStatus,
      );
      emit(
        state.copyWith(
          status: TicketListStatus.success,
          items: result.items,
          selectedStatus: selectedStatus,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TicketListStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
