import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/ticket_repository.dart';

enum TicketDetailStatus { initial, loading, success, failure }

class TicketDetailState extends Equatable {
  const TicketDetailState({
    this.status = TicketDetailStatus.initial,
    this.ticket,
    this.errorMessage,
    this.replyDraft = '',
    this.isSubmittingReply = false,
    this.isClosingTicket = false,
  });

  final TicketDetailStatus status;
  final TicketDetail? ticket;
  final String? errorMessage;
  final String replyDraft;
  final bool isSubmittingReply;
  final bool isClosingTicket;

  bool get canReply => ticket?.status != 'CLOSED';

  TicketDetailState copyWith({
    TicketDetailStatus? status,
    TicketDetail? ticket,
    String? errorMessage,
    String? replyDraft,
    bool? isSubmittingReply,
    bool? isClosingTicket,
    bool clearTicket = false,
  }) {
    return TicketDetailState(
      status: status ?? this.status,
      ticket: clearTicket ? null : (ticket ?? this.ticket),
      errorMessage: errorMessage,
      replyDraft: replyDraft ?? this.replyDraft,
      isSubmittingReply: isSubmittingReply ?? this.isSubmittingReply,
      isClosingTicket: isClosingTicket ?? this.isClosingTicket,
    );
  }

  @override
  List<Object?> get props => [
    status,
    ticket,
    errorMessage,
    replyDraft,
    isSubmittingReply,
    isClosingTicket,
  ];
}

class TicketDetailCubit extends Cubit<TicketDetailState> {
  TicketDetailCubit({required TicketRepository ticketRepository})
    : _ticketRepository = ticketRepository,
      super(const TicketDetailState());

  final TicketRepository _ticketRepository;

  Future<void> load(String ticketId) async {
    emit(
      state.copyWith(
        status: TicketDetailStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final ticket = await _ticketRepository.fetchTicketDetail(ticketId);
      emit(
        state.copyWith(
          status: TicketDetailStatus.success,
          ticket: ticket,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TicketDetailStatus.failure,
          errorMessage: error.toString(),
          clearTicket: true,
        ),
      );
    }
  }

  void updateReplyDraft(String value) {
    emit(state.copyWith(replyDraft: value));
  }

  Future<bool> submitReply(String ticketId) async {
    final body = state.replyDraft.trim();
    if (body.isEmpty || state.isSubmittingReply) {
      return false;
    }

    emit(state.copyWith(isSubmittingReply: true, errorMessage: null));
    try {
      await _ticketRepository.replyTicket(ticketId: ticketId, body: body);
      final ticket = await _ticketRepository.fetchTicketDetail(ticketId);
      emit(
        state.copyWith(
          status: TicketDetailStatus.success,
          ticket: ticket,
          replyDraft: '',
          isSubmittingReply: false,
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmittingReply: false,
          errorMessage: error.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> closeTicket(String ticketId, {String? reason}) async {
    if (state.isClosingTicket) {
      return false;
    }

    emit(state.copyWith(isClosingTicket: true, errorMessage: null));
    try {
      await _ticketRepository.closeTicket(ticketId: ticketId, reason: reason?.trim());
      final ticket = await _ticketRepository.fetchTicketDetail(ticketId);
      emit(
        state.copyWith(
          status: TicketDetailStatus.success,
          ticket: ticket,
          isClosingTicket: false,
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isClosingTicket: false,
          errorMessage: error.toString(),
        ),
      );
      return false;
    }
  }
}
