import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/ticket_repository.dart';

enum CreateTicketStatus { idle, submitting, success, failure }

class CreateTicketState extends Equatable {
  const CreateTicketState({
    this.status = CreateTicketStatus.idle,
    this.createdTicket,
    this.errorMessage,
  });

  final CreateTicketStatus status;
  final TicketSummary? createdTicket;
  final String? errorMessage;

  CreateTicketState copyWith({
    CreateTicketStatus? status,
    TicketSummary? createdTicket,
    String? errorMessage,
  }) {
    return CreateTicketState(
      status: status ?? this.status,
      createdTicket: createdTicket ?? this.createdTicket,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, createdTicket, errorMessage];
}

class CreateTicketCubit extends Cubit<CreateTicketState> {
  CreateTicketCubit({required TicketRepository ticketRepository})
    : _ticketRepository = ticketRepository,
      super(const CreateTicketState());

  final TicketRepository _ticketRepository;

  Future<void> submit({
    required String subject,
    required String description,
    required String category,
    String priority = 'NORMAL',
  }) async {
    emit(const CreateTicketState(status: CreateTicketStatus.submitting));

    try {
      final ticket = await _ticketRepository.createTicket(
        subject: subject,
        description: description,
        category: category,
        priority: priority,
      );
      emit(
        CreateTicketState(
          status: CreateTicketStatus.success,
          createdTicket: ticket,
        ),
      );
    } catch (error) {
      emit(
        CreateTicketState(
          status: CreateTicketStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(const CreateTicketState());
  }
}
