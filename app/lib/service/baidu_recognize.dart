import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IMAGE_TYPE {

    final _url;
    const IMAGE_TYPE._internal(this._url);

    static const CAR = const IMAGE_TYPE._internal(PostConstants.CAR_URL);
    static const PLANT = const IMAGE_TYPE._internal(PostConstants.PLANT_URL);
    static const DISH = const IMAGE_TYPE._internal(PostConstants.DISH_URL);

    getUrl() => _url;
}


class PostConstants {
  static const String PLANT_URL =
      "https://aip.baidubce.com/rest/2.0/image-classify/v1/plant";
  static const String CAR_URL =
      "https://aip.baidubce.com/rest/2.0/image-classify/v1/car";
  static const String DISH_URL =
      "https://aip.baidubce.com/rest/2.0/image-classify/v2/dish";

  static const String AUTH_URL = "https://aip.baidubce.com/oauth/2.0/token?"
      "grant_type=client_credentials&"
      "client_id=XBofGeAFEGMuUAtrYDCn15tI&"
      "client_secret=81lkpxQS1fImUaMs8FpFPDI2lZLL0qEz";
  static const String KEY_ACCESS_TOKEN = "BAIDU_ACCESS_TOKEN";
}

Future<String> fetchAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString(PostConstants.KEY_ACCESS_TOKEN) != null) {
    return prefs.getString(PostConstants.KEY_ACCESS_TOKEN);
  } else {
    return post(PostConstants.AUTH_URL).then((response) {
      print('fetchAuthToken body' + response.body);
      if (response.statusCode == 200) {
        String accessToken = json.decode(response.body)['access_token'];
        prefs.setString(PostConstants.KEY_ACCESS_TOKEN, accessToken);
        return json.decode(response.body)['access_token'];
      } else {
        return "";
      }
    });
  }
}

Future<RecognizeResultEntity> fetchResult(String imagePath, IMAGE_TYPE imageType) async {
  String authToken = await fetchAuthToken();
  print('authToken' + authToken.toString());
  final response = await post(
      imageType.getUrl() + "?access_token=${authToken}",
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"image": base64Encode(File(imagePath).readAsBytesSync())},
      encoding: Encoding.getByName("utf-8"));
  print(response.body);
  if (response.statusCode == 200) {
    return RecognizeResultEntity.fromJson(
        json.decode(utf8.decode(response.bodyBytes, allowMalformed: true)));
  } else {
    print("error");
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(PostConstants.KEY_ACCESS_TOKEN);
    return null;
  }
}


Future<RecognizeResultEntity> fetchPlantResult(String imagePath) async {
  return fetchResult(imagePath, IMAGE_TYPE.PLANT);
}

Future<RecognizeResultEntity> fetchCarResult(String imagePath) async {
  return fetchResult(imagePath, IMAGE_TYPE.CAR);
}

Future<RecognizeResultEntity> fetchDishResult(String imagePath) async {
  return fetchResult(imagePath, IMAGE_TYPE.DISH);
}

class Result {
  final String name;
  final double score;

  Result({this.name, this.score});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(name: json['name'], score: json['score']);
  }
}

class RecognizeResultEntity {
  final int log_id;
  final List<Result> result;

  RecognizeResultEntity({this.log_id, this.result});

  factory RecognizeResultEntity.fromJson(Map<String, dynamic> json) {
    final items =
        (json['result'] as List).map((i) => new Result.fromJson(i)).toList();
    return RecognizeResultEntity(log_id: json['log_id'], result: items);
  }
}
