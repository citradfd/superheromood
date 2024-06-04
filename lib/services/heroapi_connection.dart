import 'dart:convert';
import 'package:superheromood/model/hero.dart';
import 'package:http/http.dart' as http;

class HeroApiConnection {
  final String heroName;

  HeroApiConnection({required this.heroName});

  Future<HeroData> getData() async {
    final response = await http.get(
      Uri.parse('https://superheroapi.com/api.php/326ecb7cb3613a010afc593d290c461a/search/$heroName'),
    );

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> json = jsonDecode(response.body);
        return HeroData.fromJson(json);
      } catch (e) {
        throw Exception('Failed to parse HeroData');
      }
    } else {
      throw Exception('Failed to load HeroData');
    }
  }
}