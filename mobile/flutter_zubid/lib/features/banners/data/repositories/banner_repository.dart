import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../models/banner_model.dart';

class BannerRepository {
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/banners'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> bannersJson = data['banners'] ?? [];
        return bannersJson.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty list on error - banners are optional
      developer.log('Banner loading error: $e', name: 'BannerRepository');
      return [];
    }
  }
}
