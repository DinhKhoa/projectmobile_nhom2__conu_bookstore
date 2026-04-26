import '../models/customer.dart';
import 'api_service.dart';

class CustomerService {
  static Future<List<Customer>> getAllCustomers({bool includeInactive = false, String? search}) async {
    final Map<String, String> queryParams = {
      'includeInactive': includeInactive.toString(),
    };
    if (search != null) queryParams['search'] = search;

    final response = await ApiService.get('/customers', queryParams: queryParams);

    if (response['success'] == true) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Customer.fromJson(json)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> createCustomer(Customer customer) async {
    return await ApiService.post('/customers', customer.toJson());
  }

  static Future<Map<String, dynamic>> updateCustomer(String id, Customer customer) async {
    return await ApiService.put('/customers/$id', customer.toJson());
  }

  static Future<Map<String, dynamic>> deleteCustomer(String id) async {
    return await ApiService.delete('/customers/$id');
  }
}
