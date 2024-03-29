//import 'dart:io';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'dart:js' as js;
//import 'dart:html' as html;
//import 'package:html/parser.dart' as htmlParser;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_application_1/pages/dashboard.dart';
import 'package:flutter_application_1/pages/welcome.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/cookies/app_cookies.dart';
import 'package:flutter_application_1/cookies/service.dart';
import 'package:flutter_application_1/cookies/web_cookies.dart';
import 'package:flutter_application_1/providers/time_series_type.dart';

class HttpService {
  static final _client = http.Client();

  static const _appBaseUrl = 'https://terjack.space'; //'http://10.0.2.2:5000';
  static const _webBaseUrl =
      'https://terjack.space'; //'http://localhost:5000';http://flask-app:5000

  static String get baseUrl => kIsWeb ? _webBaseUrl : _appBaseUrl;

  late CookieService cookieService;

  HttpService() {
    if (kIsWeb) {
      cookieService = WebCookieService();
    } else {
      cookieService = AppCookieService();
    }
  }

  Future<void> login(email, password, context) async {
    final loginUrl = Uri.parse('$baseUrl/login');
    try {
      http.Response response = await _client.post(
        loginUrl,
        body: {"email": email, "password": password},
      ); //headers: {'withCredentials': 'true'}
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        if (json["response"] == 'success') {
          await EasyLoading.showSuccess(json["response"]);
          String csrfToken = json["csrf"];
          String accesToken = json["acces"];
          cookieService.setCookie("csrf", csrfToken);
          cookieService.setCookie("acces", accesToken);

          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Dashboard()));
        } else {
          await EasyLoading.showError(json["response"]);
        }
      } else {
        await EasyLoading.showError(
            "Error Code : ${response.statusCode.toString()} \n" +
                " ${response.body.toString()}");
      }
    } catch (e) {
      print('Error making HTTP request: $e');
    }
  }

  Future<void> register(email, password, context) async {
    final registerUrl = Uri.parse('$baseUrl/register');
    http.Response response = await _client.post(registerUrl, body: {
      "email": email,
      "password": password,
    });

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      if (['user alredy exist', 'Invalid email format', 'Weak password']
          .contains(json["response"])) {
        await EasyLoading.showError(json["response"]);
      } else {
        await EasyLoading.showSuccess(json["response"]);
        String csrfToken = json["csrf"];
        String accesToken = json["acces"];
        cookieService.setCookie("csrf", csrfToken);
        cookieService.setCookie("acces", accesToken);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Dashboard()));
      }
    } else {
      await EasyLoading.showError(
          "Error Code : ${response.statusCode.toString()}");
    }
  }

  Future<void> logout(context) async {
    final logoutUrl = Uri.parse('$baseUrl/logout');
    String? csrfToken = await cookieService.getCookie("csrf");
    String? accesToken = await cookieService.getCookie("acces");
    if (csrfToken != null && accesToken != null) {
      http.Response response = await _client.post(logoutUrl, headers: {
        'X-CSRF-TOKEN': csrfToken,
        'Authorization': 'Bearer $accesToken'
      });
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (['Logged out'].contains(json["response"])) {
          await EasyLoading.showSuccess(json["response"]);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => WelcomePage()));
        } else {
          await EasyLoading.showError(json["response"]);
        }
      } else {
        await EasyLoading.showError(
            "Error Code : ${response.statusCode.toString()}");
      }
    } else {
      await EasyLoading.showError("pas d'authentification CSRF");
    }
  }

  Future<List<TimeSeriesTypeT>> getTemperatureData() async {
    final temperatureUrl = Uri.parse('$baseUrl/temperature');

    try {
      http.Response response = await _client.get(temperatureUrl);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        // Map each item in jsonData to a Map with keys 'temperature' and 'timestamp'
        List<TimeSeriesTypeT> temperatureData = jsonData.map((item) {
          return TimeSeriesTypeT(
            DateTime.parse(item['timestamp']),
            item['temperature'].toDouble(),
          );
        }).toList();

        return temperatureData;
      } else {
        throw Exception('Failed to fetch temperature data');
      }
    } catch (e) {
      print('Error making HTTP request: $e');
      throw Exception('Failed to fetch temperature data');
    }
  }

  Future<List<TimeSeriesTypeH>> getMoistureData() async {
    final moistureUrl = Uri.parse('$baseUrl/moisture');

    try {
      http.Response response = await _client.get(moistureUrl);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        // Map each item in jsonData to a Map with keys 'temperature' and 'timestamp'
        List<TimeSeriesTypeH> moistureData = jsonData.map((item) {
          return TimeSeriesTypeH(
            DateTime.parse(item['timestamp']),
            item['moisture'].toDouble(),
          );
        }).toList();

        return moistureData;
      } else {
        throw Exception('Failed to fetch moisture data');
      }
    } catch (e) {
      print('Error making HTTP request: $e');
      throw Exception('Failed to fetch moisture data');
    }
  }

  Future<List<TimeSeriesTypeP>> getPhData() async {
    final phUrl = Uri.parse('$baseUrl/ph');

    try {
      http.Response response = await _client.get(phUrl);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        // Map each item in jsonData to a Map with keys 'temperature' and 'timestamp'
        List<TimeSeriesTypeP> phData = jsonData.map((item) {
          return TimeSeriesTypeP(
            DateTime.parse(item['timestamp']),
            item['ph'].toDouble(),
          );
        }).toList();

        return phData;
      } else {
        throw Exception('Failed to fetch ph data');
      }
    } catch (e) {
      print('Error making HTTP request: $e');
      throw Exception('Failed to fetch ph data');
    }
  }

  Future<List<TimeSeriesTypeE>> getEcData() async {
    final ecUrl = Uri.parse('$baseUrl/ec');

    try {
      http.Response response = await _client.get(ecUrl);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        // Map each item in jsonData to a Map with keys 'temperature' and 'timestamp'
        List<TimeSeriesTypeE> ecData = jsonData.map((item) {
          return TimeSeriesTypeE(
            DateTime.parse(item['timestamp']),
            item['ec'].toDouble(),
          );
        }).toList();

        return ecData;
      } else {
        throw Exception('Failed to fetch ec data');
      }
    } catch (e) {
      print('Error making HTTP request: $e');
      throw Exception('Failed to fetch ec data');
    }
  }
/*
  Future<String> getImageData() async {
    final imUrl = Uri.parse('$baseUrl/image');
    try {
      final response = await _client.get(imUrl);
      if (response.statusCode == 200) {
        final image = jsonDecode(response.body);
        //ImageCustom(response.bodyBytes);
        return image['image'];
      } else {
        throw Exception('Failed to fetch image data');
      }
    } catch (e) {
      print('Error fetching image: $e');
      throw Exception('Failed to fetch image data');
    }
  }
*/
}
