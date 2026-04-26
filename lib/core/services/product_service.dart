import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  static Future<List<Product>> getAllProducts({bool includeInactive = false, String? categoryId, String? search}) async {
    final Map<String, String> params = {
      'includeInactive': includeInactive.toString(),
    };
    if (categoryId != null) params['category'] = categoryId;
    if (search != null) params['search'] = search;

    final response = await ApiService.get('/products', queryParams: params);

    if (response['success'] == true) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> createProduct(Product product) async {
    return await ApiService.post('/products', product.toJson());
  }

  static Future<Map<String, dynamic>> updateProduct(String id, Product product) async {
    return await ApiService.put('/products/$id', product.toJson());
  }

  static Future<Map<String, dynamic>> deleteProduct(String id) async {
    return await ApiService.delete('/products/$id');
  }
}
