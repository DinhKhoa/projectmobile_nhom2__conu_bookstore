import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  static Future<List<Category>> getAllCategories({bool includeInactive = false}) async {
    final response = await ApiService.get('/categories', queryParams: {
      'includeInactive': includeInactive.toString(),
    });

    if (response['success'] == true) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Category.fromJson(json)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> createCategory(Category category) async {
    return await ApiService.post('/categories', category.toJson());
  }

}
