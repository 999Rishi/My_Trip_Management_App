import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../widgets/common_widgets.dart';

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  _ManageCategoriesScreenState createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState
    extends ConsumerState<ManageCategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final Map<String, IconData> _availableIcons = {
    'stars': Icons.stars,
    'local_dining': Icons.local_dining,
    'hotel': Icons.hotel,
    'train': Icons.train,
    'confirmation_number': Icons.confirmation_number,
    'help': Icons.help,
    'restaurant': Icons.restaurant,
    'flight': Icons.flight,
    'shopping_bag': Icons.shopping_bag,
    'theater_comedy': Icons.theater_comedy,
    'directions_car': Icons.directions_car,
    'local_gas_station': Icons.local_gas_station,
    'shopping_cart': Icons.shopping_cart,
    'health_and_safety': Icons.health_and_safety,
    'school': Icons.school,
  };

  final List<Color> _availableColors = [
    Color(0xFFFF6B6B),
    Color(0xFF6200EE),
    Color(0xFF03DAC6),
    Color(0xFF018786),
    Color(0xFF3700B3),
    Color(0xFFBB86FC),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  void _showAddCategoryDialog() {
    _nameController.clear();
    String selectedIcon = 'stars';
    Color selectedColor = Color(0xFFFF6B6B);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add Category',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Select Icon:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableIcons.entries.map((entry) {
                      final isSelected = selectedIcon == entry.key;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedIcon = entry.key;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey[100],
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            entry.value,
                            color: isSelected ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Select Color:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableColors.map((color) {
                      final isSelected = selectedColor.value == color.value;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addCategory(selectedIcon, selectedColor);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory(String icon, Color color) {
    try {
      final category = Category(
        id: Uuid().v4(),
        name: _nameController.text,
        icon: icon,
        color: color.value,
      );

      final addCategory = ref.read(addCategoryProvider);
      addCategory(category);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category added successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding category: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _deleteCategory(Category category) {
    // Check if it's a default category
    final isDefaultCategory = defaultCategories.any(
      (defaultCat) => defaultCat.id == category.id,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text(
          isDefaultCategory
              ? 'Default categories cannot be deleted. You can only delete custom categories.'
              : 'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          if (!isDefaultCategory)
            ElevatedButton(
              onPressed: () {
                try {
                  final deleteCategory = ref.read(deleteCategoryProvider);
                  deleteCategory(category.id);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting category: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text('Delete'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Manage Categories',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyState(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              subtitle: 'Add your first category',
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.lg),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return ModernCard(
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(category.color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(category.icon),
                        color: Color(category.color),
                        size: 28,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        category.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => _deleteCategory(category),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              SizedBox(height: AppSpacing.md),
              Text('Error loading categories'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: Icon(Icons.add),
        label: Text('Add Category'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'stars':
        return Icons.stars;
      case 'local_dining':
        return Icons.local_dining;
      case 'hotel':
        return Icons.hotel;
      case 'train':
        return Icons.train;
      case 'confirmation_number':
        return Icons.confirmation_number;
      case 'help':
        return Icons.help;
      case 'restaurant':
        return Icons.restaurant;
      case 'flight':
        return Icons.flight;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'theater_comedy':
        return Icons.theater_comedy;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'school':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
