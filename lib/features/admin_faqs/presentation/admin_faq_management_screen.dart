import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_theme.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../core/widgets/primary_pill_button.dart';
import '../../../core/widgets/surface_card.dart';
import '../data/admin_faq_repository.dart';
import 'admin_faq_cubit.dart';

class AdminFaqManagementScreen extends StatefulWidget {
  const AdminFaqManagementScreen({super.key});

  @override
  State<AdminFaqManagementScreen> createState() =>
      _AdminFaqManagementScreenState();
}

class _AdminFaqManagementScreenState extends State<AdminFaqManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminFaqCubit>().load(refreshCategories: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ management')),
      body: BlocConsumer<AdminFaqCubit, AdminFaqState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () =>
                context.read<AdminFaqCubit>().load(refreshCategories: true),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Manage common questions.',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create, edit, and deactivate FAQ content shown to users.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _AdminFaqToolbar(
                  searchController: _searchController,
                  state: state,
                  onAddCategory: () => _showCategoryForm(context),
                  onAddFaq: state.categories.isEmpty
                      ? null
                      : () =>
                            _showFaqForm(context, categories: state.categories),
                ),
                const SizedBox(height: 16),
                _CategorySection(
                  categories: state.categories,
                  selectedCategoryId: state.selectedCategoryId,
                  onSelected: (id) => context.read<AdminFaqCubit>().load(
                    categoryId: id,
                    refreshCategories: false,
                  ),
                  onEdit: (category) =>
                      _showCategoryForm(context, category: category),
                  onDeactivate: (category) =>
                      _confirmDeactivateCategory(context, category),
                ),
                const SizedBox(height: 16),
                _FilterChips(
                  filter: state.filter,
                  onChanged: (filter) => context.read<AdminFaqCubit>().load(
                    filter: filter,
                    refreshCategories: false,
                  ),
                ),
                const SizedBox(height: 16),
                if (state.status == AdminFaqStatus.loading && !state.hasLoaded)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.items.isEmpty)
                  const EmptyStateCard(
                    title: 'No FAQs found',
                    description: 'Try another filter or create a new FAQ.',
                  )
                else
                  ...state.items.map(
                    (faq) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AdminFaqCard(
                        faq: faq,
                        onEdit: () async {
                          final latest = await context
                              .read<AdminFaqCubit>()
                              .fetchFaq(faq.id);
                          if (!context.mounted) {
                            return;
                          }
                          await _showFaqForm(
                            context,
                            faq: latest,
                            categories: state.categories,
                          );
                        },
                        onDeactivate: () => _confirmDeactivateFaq(context, faq),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCategoryForm(
    BuildContext context, {
    AdminFaqCategory? category,
  }) async {
    final result = await showDialog<_CategoryFormResult>(
      context: context,
      builder: (_) => _CategoryFormDialog(category: category),
    );
    if (result == null || !context.mounted) {
      return;
    }

    final cubit = context.read<AdminFaqCubit>();
    if (category == null) {
      await cubit.createCategory(
        name: result.name,
        sortOrder: result.sortOrder,
        isActive: result.isActive,
      );
      return;
    }

    await cubit.updateCategory(
      id: category.id,
      name: result.name,
      sortOrder: result.sortOrder,
      isActive: result.isActive,
    );
  }

  Future<void> _showFaqForm(
    BuildContext context, {
    AdminFaqItem? faq,
    required List<AdminFaqCategory> categories,
  }) async {
    final result = await showDialog<_FaqFormResult>(
      context: context,
      builder: (_) => _FaqFormDialog(faq: faq, categories: categories),
    );
    if (result == null || !context.mounted) {
      return;
    }

    final cubit = context.read<AdminFaqCubit>();
    if (faq == null) {
      await cubit.createFaq(
        categoryId: result.categoryId,
        question: result.question,
        answer: result.answer,
        keywords: result.keywords,
        sortOrder: result.sortOrder,
        isActive: result.isActive,
      );
      return;
    }

    await cubit.updateFaq(
      id: faq.id,
      categoryId: result.categoryId,
      question: result.question,
      answer: result.answer,
      keywords: result.keywords,
      sortOrder: result.sortOrder,
      isActive: result.isActive,
    );
  }

  Future<void> _confirmDeactivateCategory(
    BuildContext context,
    AdminFaqCategory category,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Deactivate category?',
      body: 'This hides the category from public FAQ navigation.',
    );
    if (confirmed && context.mounted) {
      await context.read<AdminFaqCubit>().deactivateCategory(category.id);
    }
  }

  Future<void> _confirmDeactivateFaq(
    BuildContext context,
    AdminFaqItem faq,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Deactivate FAQ?',
      body: 'This hides the FAQ from users but keeps it editable here.',
    );
    if (confirmed && context.mounted) {
      await context.read<AdminFaqCubit>().deactivateFaq(faq.id);
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Deactivate'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _AdminFaqToolbar extends StatelessWidget {
  const _AdminFaqToolbar({
    required this.searchController,
    required this.state,
    required this.onAddCategory,
    required this.onAddFaq,
  });

  final TextEditingController searchController;
  final AdminFaqState state;
  final VoidCallback onAddCategory;
  final VoidCallback? onAddFaq;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Search FAQs',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) => context.read<AdminFaqCubit>().load(
              keyword: value,
              refreshCategories: false,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PrimaryPillButton(label: 'Add FAQ', onPressed: onAddFaq),
              OutlinedButton.icon(
                onPressed: onAddCategory,
                icon: const Icon(Icons.add),
                label: const Text('Add category'),
              ),
              if (state.status == AdminFaqStatus.loading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    required this.onEdit,
    required this.onDeactivate,
  });

  final List<AdminFaqCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;
  final ValueChanged<AdminFaqCategory> onEdit;
  final ValueChanged<AdminFaqCategory> onDeactivate;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: selectedCategoryId == null,
                onSelected: (_) => onSelected(null),
              ),
              ...categories.map(
                (category) => InputChip(
                  label: Text(
                    category.isActive ? category.name : '${category.name} off',
                  ),
                  selected: selectedCategoryId == category.id,
                  onSelected: (_) => onSelected(category.id),
                  onPressed: () => onSelected(category.id),
                  onDeleted: category.isActive
                      ? () => onDeactivate(category)
                      : null,
                  deleteIcon: const Icon(Icons.visibility_off_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map(
                  (category) => OutlinedButton(
                    onPressed: () => onEdit(category),
                    child: Text('Edit ${category.name}'),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.onChanged});

  final AdminFaqFilter filter;
  final ValueChanged<AdminFaqFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Active'),
          selected: filter == AdminFaqFilter.active,
          onSelected: (_) => onChanged(AdminFaqFilter.active),
        ),
        ChoiceChip(
          label: const Text('Inactive'),
          selected: filter == AdminFaqFilter.inactive,
          onSelected: (_) => onChanged(AdminFaqFilter.inactive),
        ),
        ChoiceChip(
          label: const Text('All'),
          selected: filter == AdminFaqFilter.all,
          onSelected: (_) => onChanged(AdminFaqFilter.all),
        ),
      ],
    );
  }
}

class _AdminFaqCard extends StatelessWidget {
  const _AdminFaqCard({
    required this.faq,
    required this.onEdit,
    required this.onDeactivate,
  });

  final AdminFaqItem faq;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  faq.question,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _StatusBadge(isActive: faq.isActive),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            faq.answer.length > 160
                ? '${faq.answer.substring(0, 157)}...'
                : faq.answer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(label: faq.category?.name ?? 'Unknown category'),
              _MetaChip(label: 'Sort ${faq.sortOrder}'),
              _MetaChip(label: '${faq.viewCount} views'),
              ...faq.keywords.map((keyword) => _MetaChip(label: keyword)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              if (faq.isActive)
                TextButton.icon(
                  onPressed: onDeactivate,
                  icon: const Icon(Icons.visibility_off_outlined),
                  label: const Text('Deactivate'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isActive ? AppTheme.nearBlack : AppTheme.cloudGray,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            color: isActive ? AppTheme.pureWhite : AppTheme.slateGray,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

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
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
      ),
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.category});

  final AdminFaqCategory? category;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sortOrderController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _sortOrderController = TextEditingController(
      text: (widget.category?.sortOrder ?? 0).toString(),
    );
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add category' : 'Edit category'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sortOrderController,
                decoration: const InputDecoration(labelText: 'Sort order'),
                keyboardType: TextInputType.number,
                validator: _integer,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: const Text('Active'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      _CategoryFormResult(
        name: _nameController.text.trim(),
        sortOrder: int.parse(_sortOrderController.text.trim()),
        isActive: _isActive,
      ),
    );
  }
}

class _FaqFormDialog extends StatefulWidget {
  const _FaqFormDialog({required this.categories, this.faq});

  final List<AdminFaqCategory> categories;
  final AdminFaqItem? faq;

  @override
  State<_FaqFormDialog> createState() => _FaqFormDialogState();
}

class _FaqFormDialogState extends State<_FaqFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  late final TextEditingController _keywordsController;
  late final TextEditingController _sortOrderController;
  late String _categoryId;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final firstCategory = widget.categories.first;
    _categoryId = widget.faq?.categoryId ?? firstCategory.id;
    _questionController = TextEditingController(
      text: widget.faq?.question ?? '',
    );
    _answerController = TextEditingController(text: widget.faq?.answer ?? '');
    _keywordsController = TextEditingController(
      text: widget.faq?.keywords.join(', ') ?? '',
    );
    _sortOrderController = TextEditingController(
      text: (widget.faq?.sortOrder ?? 0).toString(),
    );
    _isActive = widget.faq?.isActive ?? true;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _keywordsController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.faq == null ? 'Add FAQ' : 'Edit FAQ'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: widget.categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(
                            category.isActive
                                ? category.name
                                : '${category.name} inactive',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _categoryId = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                  maxLength: 255,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _answerController,
                  decoration: const InputDecoration(labelText: 'Answer'),
                  minLines: 4,
                  maxLines: 8,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _keywordsController,
                  decoration: const InputDecoration(
                    labelText: 'Keywords',
                    hintText: 'refund, account, billing',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sortOrderController,
                  decoration: const InputDecoration(labelText: 'Sort order'),
                  keyboardType: TextInputType.number,
                  validator: _integer,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: const Text('Active'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      _FaqFormResult(
        categoryId: _categoryId,
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        keywords: _keywordsController.text
            .split(',')
            .map((keyword) => keyword.trim())
            .where((keyword) => keyword.isNotEmpty)
            .toList(),
        sortOrder: int.parse(_sortOrderController.text.trim()),
        isActive: _isActive,
      ),
    );
  }
}

class _CategoryFormResult {
  const _CategoryFormResult({
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  final String name;
  final int sortOrder;
  final bool isActive;
}

class _FaqFormResult {
  const _FaqFormResult({
    required this.categoryId,
    required this.question,
    required this.answer,
    required this.keywords,
    required this.sortOrder,
    required this.isActive,
  });

  final String categoryId;
  final String question;
  final String answer;
  final List<String> keywords;
  final int sortOrder;
  final bool isActive;
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String? _integer(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  if (int.tryParse(value.trim()) == null) {
    return 'Enter a whole number';
  }
  return null;
}
