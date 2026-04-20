import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_theme.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../core/widgets/surface_card.dart';
import '../data/faq_repository.dart';
import 'faq_list_cubit.dart';

class FaqListScreen extends StatefulWidget {
  const FaqListScreen({super.key});

  @override
  State<FaqListScreen> createState() => _FaqListScreenState();
}

class _FaqListScreenState extends State<FaqListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FaqListCubit>().load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaqListCubit, FaqListState>(
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () => context.read<FaqListCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Text(
                  'Find answers fast.',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Search common support topics before opening a ticket.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search FAQs',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (value) =>
                      context.read<FaqListCubit>().load(keyword: value),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: 'All',
                        selected: state.selectedCategoryId == null,
                        onSelected: () =>
                            context.read<FaqListCubit>().load(categoryId: ''),
                      ),
                      for (final category in state.categories) ...[
                        const SizedBox(width: 8),
                        _CategoryChip(
                          label: category.name,
                          selected: state.selectedCategoryId == category.id,
                          onSelected: () => context.read<FaqListCubit>().load(
                            categoryId: category.id,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (state.status == FaqListStatus.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.status == FaqListStatus.failure)
                  EmptyStateCard(
                    title: 'Could not load FAQs',
                    description: state.errorMessage ?? 'Please try again.',
                  )
                else if (state.items.isEmpty)
                  const EmptyStateCard(
                    title: 'No answers yet',
                    description: 'Try a different keyword or category.',
                  )
                else
                  ...state.items.map(
                    (faq) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FaqCard(faq: faq),
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.faq});

  final FaqSummary faq;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FaqDetailScreen(faqId: faq.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(faq.question, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              faq.answerPreview,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class FaqDetailScreen extends StatelessWidget {
  const FaqDetailScreen({super.key, required this.faqId});

  final String faqId;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<FaqRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: FutureBuilder<FaqDetail>(
        future: repository.fetchFaqDetail(faqId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyStateCard(
                  title: 'Could not load FAQ',
                  description: snapshot.error.toString(),
                ),
              ),
            );
          }

          final faq = snapshot.data;
          if (faq == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: EmptyStateCard(
                  title: 'FAQ not found',
                  description: 'Please return to the list and try again.',
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq.question,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      faq.answer,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
