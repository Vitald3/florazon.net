import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'models/api.dart';

class Api {
  Future<Data> getData(body) async {
    final response = await post(
        Uri.parse("https://api.florazon.net/laravel/public/api"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body)
    ).catchError((error) {
      return error;
    });

    if (response.statusCode == 200) {
      return Data.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error response");
    }
  }
}