import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';


class PlantPost {
  static const String PLANT_URL = "https://aip.baidubce.com/rest/2.0/image-classify/v1/plant";
  static const String AUTH_URL = "https://aip.baidubce.com/oauth/2.0/token?"
      "grant_type=client_credentials&"
      "client_id=XBofGeAFEGMuUAtrYDCn15tI&"
      "client_secret=81lkpxQS1fImUaMs8FpFPDI2lZLL0qEz";
}
Future<String> fetchAuthToken() async {
  return post(PlantPost.AUTH_URL).then( (response) {
    print('fetchAuthToken body'+response.body);
    if(response.statusCode == 200) {
      return json.decode(response.body)['access_token'];
    } else {
      return "";
    }
  });
}

Future<RecognizeResultEntity> fetchPlantResult(String imagePath) async {
  String authToken = await fetchAuthToken();
  print('authToken'+authToken.toString());
  final response = await post(
      PlantPost.PLANT_URL+"?access_token=${authToken}",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: {
        "image": base64Encode(File(imagePath).readAsBytesSync())
      },
  encoding: Encoding.getByName("utf-8"));
  print(response.body);
  if(response.statusCode == 200) {
    return RecognizeResultEntity.fromJson(json.decode(utf8.decode(response.bodyBytes,allowMalformed: true)));
  } else {
    throw Exception('Fail to fetch result');
  }
}

class Result {
  final String name;
  final double score;
  Result({this.name,this.score});
  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      name: json['name'],
      score: json['score']
    );
  }
}
class RecognizeResultEntity {
  final int log_id;
  final List<Result> result;

  RecognizeResultEntity({this.log_id,this.result});

  factory RecognizeResultEntity.fromJson(Map<String, dynamic> json) {
    final items = (json['result'] as List).map((i) => new Result.fromJson(i)).toList();
    return RecognizeResultEntity(
      log_id: json['log_id'],
      result: items
    );
  }

}
