import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:superheromood/model/hero.dart';
import 'package:superheromood/services/heroapi_connection.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

class CreateMoodsScreen extends StatefulWidget {
  static const String id = 'createmoods_screen';
  const CreateMoodsScreen({super.key});

  @override
  State<CreateMoodsScreen> createState() => _CreateMoodsScreenState();
}

class _CreateMoodsScreenState extends State<CreateMoodsScreen> {
  String heroNameToSearch = '';
  Future<HeroData>? getHeroData;
  String? namaHero;
  String? imgHero;
  int selectedIndex = -1;
  String? moodsText; 
  final firestoreInstance = FirebaseFirestore.instance; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  heroNameToSearch = value;
                  getHeroData = HeroApiConnection(heroName: heroNameToSearch).getData();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search for a hero',
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<HeroData>(
              future: getHeroData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.results == null) {
                  return Center(child: Text('No data found'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.results!.length,
                    itemBuilder: (context, index) {
                      var heroesData = snapshot.data!.results![index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                selectedIndex = index;
                                namaHero = heroesData.name;
                                imgHero = heroesData.image;
                              });
                            },
                            child: Card(
                              shape: (selectedIndex == index)
                                  ? RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.blueAccent),
                                    )
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                height: 300.0,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Image.network(heroesData.image!),
                                    Text(
                                      heroesData.name!,
                                      style: const TextStyle(
                                          fontSize: 20.0, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomSheet: Card(
        child: ListTile(
          leading: Text(
            'Moods',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          title: TextField(
            onChanged: (value) { 
              moodsText = value; 
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.send), 
            onPressed: () async { 
  try {
    await FirebaseFirestore.instance.collection('moods').add({
      'namahero': namaHero,
      'urlHero': imgHero,
      'moodstext': moodsText,
      'timestamp': FieldValue.serverTimestamp() // Add a timestamp if needed
    }).then((value) {
      print('Mood successfully added with ID: ${value.id}');
      Navigator.pop(context);
    }).catchError((error) {
      print('Failed to add mood to the database: $error');
    });
  } catch (e) {
    print('An error occurred: $e');
  }

            },
          ),
        ),
      ),
    );
  }
}