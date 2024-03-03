import 'dart:convert';

import 'package:http/http.dart';

import 'api_constants.dart';

class ApiClient {
  final Client client;

  ApiClient(this.client);

  dynamic get(String path) async {
    final response = await client.get(
        Uri.parse(
            '${APIConstants.baseURL}$path?api_key=${APIConstants.API_KEY}'),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  dynamic getSpecial(String path) async {
    final response = await client.get(
        Uri.parse(
            '${APIConstants.baseURL}$path&api_key=${APIConstants.API_KEY}'),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(response.reasonPhrase);
    }
  }
}
