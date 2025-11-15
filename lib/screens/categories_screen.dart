import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:glassmorphism/glassmorphism.dart';
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
        // Build the form content with standard Flutter components
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
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: const OutlineInputBorder(),
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
                  prefixIcon: const Icon(Icons.translate),
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionOptional,
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: const OutlineInputBorder(),
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
                  prefixIcon: const Icon(Icons.translate),
                  border: const OutlineInputBorder(),
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
    final theme = Theme.of(context);

    if (productCount > 0) {
      // Show warning if category has products
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              size: 48,
            ),
            title: Text(
              AppLocalizations.of(context)!.cannotDeleteCategory,
              textAlign: TextAlign.center,
            ),
            content: Text(
              AppLocalizations.of(context)!.categoryHasProducts,
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          );
        },
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.delete_outline,
            color: theme.colorScheme.error,
            size: 48,
          ),
          title: Text(
            AppLocalizations.of(context)!.deleteCategory,
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.of(context)!
                .deleteCategoryConfirm(category.name),
            textAlign: TextAlign.center,
          ),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
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
                    GlassmorphicContainer(
                      width: 120,
                      height: 120,
                      borderRadius: 60,
                      blur: 15,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.surface.withValues(alpha: 0.15),
                          theme.colorScheme.surface.withValues(alpha: 0.05),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                        ],
                      ),
                      child: Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noCategoriesFound,
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 800;

                  if (isDesktop) {
                    // Desktop/Tablet: DataTable layout with Glass styling
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
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  return GlassmorphicContainer(
                                      width: constraints.maxWidth - 32,
                                      height: 600,
                                      borderRadius: 16,
                                blur: 20,
                                alignment: Alignment.center,
                                border: 2,
                                linearGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.surface.withValues(alpha: 0.15),
                                    theme.colorScheme.surface.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withValues(alpha: 0.2),
                                    theme.colorScheme.primary.withValues(alpha: 0.1),
                                  ],
                                ),
                                child: DataTable(
                                  columnSpacing: 24,
                                  horizontalMargin: 16,
                                  headingTextStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  dataTextStyle: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                  ),
                                  columns: [
                                    DataColumn(label: Text(l10n.name)),
                                    DataColumn(label: Text(l10n.description)),
                                    DataColumn(
                                        label: Text(l10n
                                            .productCount(0)
                                            .split(' ')[0])),
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
                                            Tooltip(
                                              message: l10n.tooltipEdit,
                                              child: IconButton(
                                                onPressed: () =>
                                                    showCategoryDialog(category),
                                                icon: const Icon(Icons.edit, size: 20),
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Tooltip(
                                              message: l10n.tooltipDelete,
                                              child: IconButton(
                                                onPressed: () => _deleteCategory(
                                                    category, productCount),
                                                icon: const Icon(Icons.delete, size: 20),
                                                color: theme.colorScheme.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                              );
                                },
                              ),
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

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassmorphicContainer(
                              width: double.infinity,
                              height: 80,
                              borderRadius: 16,
                              blur: 18,
                              alignment: Alignment.center,
                              border: 2,
                              linearGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.surface.withValues(alpha: 0.15),
                                  theme.colorScheme.surface.withValues(alpha: 0.05),
                                ],
                              ),
                              borderGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary.withValues(alpha: 0.2),
                                  theme.colorScheme.primary.withValues(alpha: 0.1),
                                ],
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  leading: GlassmorphicContainer(
                                    width: 48,
                                    height: 48,
                                    borderRadius: 24,
                                    blur: 12,
                                    alignment: Alignment.center,
                                    border: 2,
                                    linearGradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        theme.colorScheme.surface.withValues(alpha: 0.2),
                                        theme.colorScheme.surface.withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderGradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        theme.colorScheme.primary.withValues(alpha: 0.3),
                                        theme.colorScheme.primary.withValues(alpha: 0.1),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.category,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    Localizations.localeOf(context)
                                                .languageCode ==
                                            'ar'
                                        ? (category.nameAr ?? category.name)
                                        : category.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    l10n.productCount(productCount),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Tooltip(
                                        message: l10n.tooltipEdit,
                                        child: IconButton(
                                          onPressed: () =>
                                              showCategoryDialog(category),
                                          icon: const Icon(Icons.edit, size: 20),
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Tooltip(
                                        message: l10n.tooltipDelete,
                                        child: IconButton(
                                          onPressed: () =>
                                              _deleteCategory(category, productCount),
                                          icon: const Icon(Icons.delete, size: 20),
                                          color: theme.colorScheme.error,
                                        ),
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
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: theme.colorScheme.onSurface,
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
                                                color: theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
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
