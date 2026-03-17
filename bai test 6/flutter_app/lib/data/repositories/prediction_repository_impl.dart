import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/prediction_result.dart';
import '../../domain/repositories/i_prediction_repository.dart';
import '../models/prediction_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb

class PredictionRepositoryImpl implements IPredictionRepository {
  final http.Client client;
  
  // Choose the host depending on the platform
  String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000"; // Android Emulator
    } else {
      return "http://localhost:8000"; // iOS Simulator or Web/Desktop
    }
  }

  PredictionRepositoryImpl({required this.client});

  @override
  Future<PredictionResult> getPrediction(
      String countryCode, int targetYear, List<String> models) async {
    final response = await client.post(
      Uri.parse('$baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'country_code': countryCode,
        'target_year': targetYear,
        'selected_models': models,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      return PredictionModel.fromJson(jsonMap);
    } else {
      throw Exception('Failed to fetch predictions from Backend: ${response.statusCode}');
    }
  }
}
