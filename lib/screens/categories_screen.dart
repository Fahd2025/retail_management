import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../database/drift_database.dart';
import '../models/category.dart' as models;
import '../widgets/form_bottom_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _database = AppDatabase();
  List<Map<String, dynamic>> _categoriesWithCount = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  // Public method that can be called from dashboard
  Future<void> loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await _database.getCategoriesWithProductCount();
      if (mounted) {
        setState(() {
          _categoriesWithCount = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSavingCategory(e.toString()))),
        );
      }
    }
  }

  // Public method that can be called from dashboard
  void showCategoryDialog([models.Category? category]) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: category?.name ?? '');
    final nameArController =
        TextEditingController(text: category?.nameAr ?? '');
    final descriptionController =
        TextEditingController(text: category?.description ?? '');
    final descriptionArController =
        TextEditingController(text: category?.descriptionAr ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Build the form content
        final formContent = Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Name Field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterCategoryName;
                  }
                  return null;
                },
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Category Name (Arabic) Field
              TextFormField(
                controller: nameArController,
                decoration: InputDecoration(
                  labelText: '${l10n.name} (عربي)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.translate),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionOptional,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description (Arabic) Field
              TextFormField(
                controller: descriptionArController,
                decoration: InputDecoration(
                  labelText: '${l10n.description} (عربي)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.translate),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        );

        // Wrap in FormBottomSheet
        return FormBottomSheet(
          title: category == null ? l10n.add : l10n.editCategory,
          saveButtonText: category == null ? l10n.add : l10n.save,
          cancelButtonText: l10n.cancel,
          onSave: () async {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context);
              await _saveCategory(
                category,
                nameController.text.trim(),
                nameArController.text.trim(),
                descriptionController.text.trim(),
                descriptionArController.text.trim(),
              );
            }
          },
          child: formContent,
        );
      },
    );
  }

  Future<void> _saveCategory(
    models.Category? existingCategory,
    String name,
    String nameAr,
    String description,
    String descriptionAr,
  ) async {
    try {
      if (existingCategory == null) {
        // Create new category
        final newCategory = models.Category(
          id: const Uuid().v4(),
          name: name,
          nameAr: nameAr.isEmpty ? null : nameAr,
          description: description.isEmpty ? null : description,
          descriptionAr: descriptionAr.isEmpty ? null : descriptionAr,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _database.createCategory(newCategory);
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.categoryAddedSuccess)),
          );
        }
      } else {
        // Update existing category
        final updatedCategory = existingCategory.copyWith(
          name: name,
          nameAr: nameAr.isEmpty ? null : nameAr,
          description: description.isEmpty ? null : description,
          descriptionAr: descriptionAr.isEmpty ? null : descriptionAr,
          updatedAt: DateTime.now(),
        );
        await _database.updateCategory(updatedCategory);
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.categoryUpdatedSuccess)),
          );
        }
      }
      await loadCategories();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSavingCategory(e.toString()))),
        );
      }
    }
  }

  Future<void> _deleteCategory(
      models.Category category, int productCount) async {
    if (productCount > 0) {
      // Show warning if category has products
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.cannotDeleteCategory),
          content: Text(AppLocalizations.of(context)!.categoryHasProducts),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
      return;
    }

    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCategory),
        content: Text(
            AppLocalizations.of(context)!.deleteCategoryConfirm(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _database.deleteCategory(category.id);
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.categoryDeletedSuccess)),
          );
        }
        await loadCategories();
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorDeletingCategory(e.toString()))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _categoriesWithCount.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noCategoriesFound,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 800;

                  if (isDesktop) {
                    // Desktop/Tablet: DataTable layout that fills width
                    return RefreshIndicator(
                      onRefresh: loadCategories,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              columnSpacing: 24,
                              horizontalMargin: 16,
                              columns: [
                                DataColumn(label: Text(l10n.name)),
                                DataColumn(label: Text(l10n.description)),
                                DataColumn(
                                    label: Text(
                                        l10n.productCount(0).split(' ')[0])),
                                DataColumn(label: Text(l10n.actions)),
                              ],
                              rows: _categoriesWithCount.map((data) {
                                final category =
                                    data['category'] as models.Category;
                                final productCount =
                                    data['productCount'] as int;

                                return DataRow(cells: [
                                  DataCell(Text(
                                    Localizations.localeOf(context)
                                                .languageCode ==
                                            'ar'
                                        ? (category.nameAr ?? category.name)
                                        : category.name,
                                  )),
                                  DataCell(
                                    Text(
                                      Localizations.localeOf(context)
                                                  .languageCode ==
                                              'ar'
                                          ? (category.descriptionAr ??
                                              category.description ??
                                              '-')
                                          : (category.description ?? '-'),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DataCell(Text(productCount.toString())),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(Icons.edit, size: 20),
                                          onPressed: () =>
                                              showCategoryDialog(category),
                                          tooltip: l10n.tooltipEdit,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              size: 20,
                                              color: theme.colorScheme.error),
                                          onPressed: () => _deleteCategory(
                                              category, productCount),
                                          tooltip: l10n.tooltipDelete,
                                        ),
                                      ],
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Mobile: Card with ExpansionTile layout
                    return RefreshIndicator(
                      onRefresh: loadCategories,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _categoriesWithCount.length,
                        itemBuilder: (context, index) {
                          final data = _categoriesWithCount[index];
                          final category = data['category'] as models.Category;
                          final productCount = data['productCount'] as int;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.category,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: Text(
                                Localizations.localeOf(context).languageCode ==
                                        'ar'
                                    ? (category.nameAr ?? category.name)
                                    : category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                l10n.productCount(productCount),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: theme.colorScheme.primary),
                                    onPressed: () =>
                                        showCategoryDialog(category),
                                    tooltip: l10n.tooltipEdit,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: theme.colorScheme.error),
                                    onPressed: () =>
                                        _deleteCategory(category, productCount),
                                    tooltip: l10n.tooltipDelete,
                                  ),
                                ],
                              ),
                              children: [
                                if ((Localizations.localeOf(context)
                                                    .languageCode ==
                                                'ar'
                                            ? (category.descriptionAr ??
                                                category.description)
                                            : category.description) !=
                                        null &&
                                    (Localizations.localeOf(context)
                                                    .languageCode ==
                                                'ar'
                                            ? (category.descriptionAr ??
                                                category.description)!
                                            : category.description!)
                                        .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.description,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          Localizations.localeOf(context)
                                                      .languageCode ==
                                                  'ar'
                                              ? (category.descriptionAr ??
                                                  category.description!)
                                              : category.description!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
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
                },
              );
  }
}
