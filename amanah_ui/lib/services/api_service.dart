import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for Web. 
  // TODO: Update to your Cloud Run URL once deployed.
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000');

  static Future<Map<String, dynamic>> createEscrow(
      String itemName, double price, String trackingNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/escrow/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'item_name': itemName,
        'price': price,
        'tracking_number': trackingNumber,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create escrow: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> uploadReceipt(
      String escrowId, XFile imageFile) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/api/escrow/upload-receipt/$escrowId'));
    
    // Support Flutter Web by using readAsBytes
    final bytes = await imageFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: imageFile.name,
      contentType: MediaType('image', 'jpeg'),
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload receipt: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getEscrowStatus(String escrowId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/escrow/status/$escrowId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get status: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> raiseDispute(
      String escrowId, String complaint, String aiReasoning, String history) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/dispute/raise'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'escrow_id': escrowId,
        'user_complaint': complaint,
        'ai_reasoning': aiReasoning,
        'chat_history': history,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to raise dispute: ${response.body}');
    }
  }
}
