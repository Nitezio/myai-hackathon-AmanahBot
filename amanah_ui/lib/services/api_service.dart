import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import 'dart:html' as html; // Added for domain detection

class ApiService {
  // Automatically uses the domain it's hosted on (e.g., your Cloud Run URL)
  static String get baseUrl {
    final String origin = html.window.location.origin;
    // If running locally, default to 8080. If in cloud, use the cloud URL.
    return origin.contains('localhost') ? 'http://localhost:8080' : origin;
  }

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
      String escrowId, String complaint, String sellerResponse, String logs) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/escrow/dispute/$escrowId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'buyer_complaint': complaint,
        'seller_response': sellerResponse,
        'chat_logs': logs,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to raise dispute: ${response.body}');
    }
  }
}
