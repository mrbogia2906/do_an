import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../utilities/constants/server_constants.dart';
import '../../../models/api/responses/search/search_result.dart';

abstract class SearchRepository {
  Future<List<SearchResult>> getSearchResults(String token, String query);
}

class SearchRepositoryImpl implements SearchRepository {
  final String baseUrl = "${ServerConstant.serverURL}/api";

  @override
  Future<List<SearchResult>> getSearchResults(
      String token, String query) async {
    var uri = Uri.parse("$baseUrl/search?query=${Uri.encodeComponent(query)}");
    print('Making GET request to $uri'); // Log the request URI

    var response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "x-auth-token": token,
      },
    );

    print(
        'Received response with status code ${response.statusCode}'); // Log the status code

    if (response.statusCode == 200) {
      try {
        // In ra nội dung của phản hồi trước khi giải mã
        print('Response body: ${response.body}');

        // Giải mã với utf-8, nếu cần
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonResponse = json.decode(decodedBody);

        print('Decoded response body: $jsonResponse');
        return (jsonResponse as List)
            .map<SearchResult>((json) => SearchResult.fromJson(json))
            .toList();
      } catch (e) {
        print('Failed to decode JSON: $e');
        throw Exception('Failed to decode JSON: $e');
      }
    } else {
      try {
        final error = json.decode(response.body);
        print('Error response: $error'); // Log the error response
        throw Exception(error['detail'] ?? 'Failed to fetch search results');
      } catch (e) {
        print('Error parsing response: $e'); // Log the parsing error
        throw Exception('Error parsing response: $e');
      }
    }
  }
}
