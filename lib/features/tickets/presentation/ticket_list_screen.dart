import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../app/app_theme.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../core/widgets/primary_pill_button.dart';
import '../../../core/widgets/surface_card.dart';
import '../data/ticket_repository.dart';
import 'create_ticket_cubit.dart';
import 'ticket_list_cubit.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TicketListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketListCubit, TicketListState>(
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () => context.read<TicketListCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Text(
                  'Track every support request.',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Create a ticket, follow replies, and close the case when it is resolved.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryPillButton(
                    label: 'New ticket',
                    onPressed: () async {
                      final created = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => const CreateTicketScreen(),
                        ),
                      );
                      if (created == true && context.mounted) {
                        await context.read<TicketListCubit>().load();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final status in _ticketStatuses) ...[
                        if (status != _ticketStatuses.first)
                          const SizedBox(width: 8),
                        _StatusChip(
                          label: status.label,
                          selected: state.selectedStatus == status.value,
                          onSelected: () => context
                              .read<TicketListCubit>()
                              .load(status: status.value),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (state.status == TicketListStatus.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.status == TicketListStatus.failure)
                  EmptyStateCard(
                    title: 'Could not load tickets',
                    description: state.errorMessage ?? 'Please try again.',
                  )
                else if (state.items.isEmpty)
                  const EmptyStateCard(
                    title: 'No tickets yet',
                    description:
                        'Create your first support ticket to get help.',
                  )
                else
                  ...state.items.map(
                    (ticket) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TicketCard(ticket: ticket),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final TicketSummary ticket;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, HH:mm');
    return SurfaceCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TicketDetailScreen(ticketId: ticket.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 12),
                _Tag(label: ticket.statusLabel),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.ticketNo,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MetaLabel(label: ticket.priorityLabel),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Updated ${formatter.format(ticket.lastMessageAt.toLocal())}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = _ticketCategories.first;
  String _priority = _ticketPriorities.first.value;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateTicketCubit, CreateTicketState>(
      listener: (context, state) {
        if (state.status == CreateTicketStatus.success) {
          context.read<CreateTicketCubit>().reset();
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Create ticket')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Describe the issue clearly.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(labelText: 'Subject'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: _ticketCategories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _priority,
                      items: _ticketPriorities
                          .map(
                            (priority) => DropdownMenuItem(
                              value: priority.value,
                              child: Text(priority.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _priority = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      minLines: 5,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'What happened?',
                        alignLabelWithHint: true,
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    const SizedBox(height: 20),
                    PrimaryPillButton(
                      label: 'Submit ticket',
                      isLoading: state.status == CreateTicketStatus.submitting,
                      onPressed: () {
                        context.read<CreateTicketCubit>().submit(
                          subject: _subjectController.text.trim(),
                          description: _descriptionController.text.trim(),
                          category: _category,
                          priority: _priority,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late Future<TicketDetail> _detailFuture;
  final _replyController = TextEditingController();
  bool _isSubmittingReply = false;
  bool _isClosingTicket = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<TicketDetail> _loadDetail() {
    return context.read<TicketRepository>().fetchTicketDetail(widget.ticketId);
  }

  Future<void> _refresh() async {
    final next = _loadDetail();
    setState(() {
      _detailFuture = next;
    });
    await next;
  }

  Future<void> _submitReply() async {
    final body = _replyController.text.trim();
    if (body.isEmpty || _isSubmittingReply) {
      return;
    }

    setState(() => _isSubmittingReply = true);
    try {
      await context.read<TicketRepository>().replyTicket(
        ticketId: widget.ticketId,
        body: body,
      );
      _replyController.clear();
      await _refresh();
    } finally {
      if (mounted) {
        setState(() => _isSubmittingReply = false);
      }
    }
  }

  Future<void> _closeTicket() async {
    if (_isClosingTicket) {
      return;
    }

    setState(() => _isClosingTicket = true);
    try {
      await context.read<TicketRepository>().closeTicket(
        ticketId: widget.ticketId,
      );
      await _refresh();
      if (mounted) {
        await context.read<TicketListCubit>().load();
      }
    } finally {
      if (mounted) {
        setState(() => _isClosingTicket = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket details')),
      body: FutureBuilder<TicketDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyStateCard(
                  title: 'Could not load ticket',
                  description: snapshot.error.toString(),
                ),
              ),
            );
          }

          final ticket = snapshot.data;
          if (ticket == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: EmptyStateCard(
                  title: 'Ticket not found',
                  description:
                      'Please return to the ticket list and try again.',
                ),
              ),
            );
          }

          final canReply = ticket.status != 'CLOSED';

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ticket.subject,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _Tag(label: ticket.statusLabel),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${ticket.ticketNo} • ${ticket.category}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ticket.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _MetaLabel(label: ticket.priorityLabel),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Opened ${formatter.format(ticket.createdAt.toLocal())}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      if (canReply) ...[
                        const SizedBox(height: 20),
                        PrimaryPillButton(
                          label: 'Close ticket',
                          isLoading: _isClosingTicket,
                          onPressed: _closeTicket,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Conversation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...ticket.messages.map(
                  (message) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MessageBubble(message: message),
                  ),
                ),
                if (ticket.attachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attachments',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...ticket.attachments.map(
                          (attachment) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${attachment.fileName} (${attachment.mimeType})',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        canReply ? 'Send a reply' : 'This ticket is closed',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _replyController,
                        minLines: 4,
                        maxLines: 6,
                        enabled: canReply,
                        decoration: const InputDecoration(
                          labelText: 'Add more details',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryPillButton(
                        label: 'Send reply',
                        isLoading: _isSubmittingReply,
                        onPressed: canReply ? _submitReply : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final TicketMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.senderRole == 'USER';
    final backgroundColor = isUser ? AppTheme.expoBlack : AppTheme.pureWhite;
    final foregroundColor = isUser ? AppTheme.pureWhite : AppTheme.nearBlack;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: isUser ? null : Border.all(color: AppTheme.borderLavender),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : message.senderRoleLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isUser ? Colors.white70 : AppTheme.slateGray,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: foregroundColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppTheme.expoBlack,
      labelStyle: TextStyle(
        color: selected ? AppTheme.pureWhite : AppTheme.nearBlack,
      ),
      shape: const StadiumBorder(side: BorderSide(color: AppTheme.inputBorder)),
      onSelected: (_) => onSelected(),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.cloudGray,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _MetaLabel extends StatelessWidget {
  const _MetaLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.nearBlack,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TicketStatusOption {
  const _TicketStatusOption({required this.label, required this.value});

  final String label;
  final String value;
}

class _TicketPriorityOption {
  const _TicketPriorityOption({required this.label, required this.value});

  final String label;
  final String value;
}

const _ticketStatuses = [
  _TicketStatusOption(label: 'All', value: 'ALL'),
  _TicketStatusOption(label: 'Open', value: 'OPEN'),
  _TicketStatusOption(label: 'Pending', value: 'PENDING'),
  _TicketStatusOption(label: 'In progress', value: 'IN_PROGRESS'),
  _TicketStatusOption(label: 'Resolved', value: 'RESOLVED'),
  _TicketStatusOption(label: 'Closed', value: 'CLOSED'),
];

const _ticketPriorities = [
  _TicketPriorityOption(label: 'Low', value: 'LOW'),
  _TicketPriorityOption(label: 'Normal', value: 'NORMAL'),
  _TicketPriorityOption(label: 'High', value: 'HIGH'),
  _TicketPriorityOption(label: 'Urgent', value: 'URGENT'),
];

const _ticketCategories = [
  'Account',
  'Billing',
  'Bug report',
  'Order issue',
  'General support',
];

extension on TicketSummary {
  String get statusLabel => _humanize(status);
  String get priorityLabel => _humanize(priority);
}

extension on TicketDetail {
  String get statusLabel => _humanize(status);
  String get priorityLabel => _humanize(priority);
}

extension on TicketMessage {
  String get senderRoleLabel => _humanize(senderRole);
}

String _humanize(String value) {
  return value
      .toLowerCase()
      .split('_')
      .map((segment) => '${segment[0].toUpperCase()}${segment.substring(1)}')
      .join(' ');
}
