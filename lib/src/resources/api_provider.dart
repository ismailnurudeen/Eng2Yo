import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiProvider {
  ApiProvider();
  static const API_KEY = "ENTER API KEY";
  final translateApiEndpoint =
      "https://translation.googleapis.com/language/translate/v2?target=yo&key=$API_KEY&q=";
  final audioApiEndpoint =
      "https://gentle-falls-68008.herokuapp.com/api/v1/names/";

  String _getTranslateEndpoint(String word) => translateApiEndpoint + word;

  Future<String> fetchTranslation(String word) async {
    http.Response response = await http.get(
        Uri.encodeFull(_getTranslateEndpoint(word)),
        headers: {"Accept": "application/json"});
    print("TRANSLATED " + response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Map<String, dynamic> translations =
          jsonResponse["data"]["translations"][0];
      return translations["translatedText"];
    } else {
      throw Exception("Could not fetch translation");
    }
  }
}
