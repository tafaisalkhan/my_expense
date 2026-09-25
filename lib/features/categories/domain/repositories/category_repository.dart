import 'package:myexpence/features/categories/domain/models/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getCategories({bool activeOnly = true});
  Future<Category?> getCategoryById(String id);
  Future<List<Subcategory>> getSubcategories(String categoryId, {bool activeOnly = true});
  Future<void> addCategory(Category category);
  Future<void> addSubcategory(Subcategory subcategory);
}
