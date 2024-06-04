import 'package:flutter/material.dart';
import 'package:superheromood/createmoods_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  static const String id = 'main_screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String imgProfile =
      'https://www.hotelbooqi.com/wp-content/uploads/2021/12/128-1280406_view-user-icon-png-user-circle-icon-png.png';
  String myDisplayName = 'User';
  String moodText = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(imgProfile),
                    radius: 80.0,
                  ),
                  Text(
                    'Hello $myDisplayName, you are Superhero: $myDisplayName!',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    'Moods: $moodText',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          iconSize: 35.0,
                          tooltip: 'Set Profile Name',
                          icon: Icon(Icons.settings),
                          onPressed: null,
                        ),
                        IconButton(
                          iconSize: 35.0,
                          tooltip: 'Create Moods',
                          icon: Icon(Icons.person_add),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, CreateMoodsScreen.id).then((value) {
                              if (value != null && value is Map<String, String>) {
                                setState(() {
                                  myDisplayName = value['superheroName'] ?? myDisplayName;
                                  moodText = value['moodText'] ?? moodText;
                                });
                              }
                            });
                          },
                        ),
                        IconButton(
                            iconSize: 35.0,
                            tooltip: 'Log Out',
                            icon: Icon(Icons.power_settings_new),
                            onPressed: null),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch initial mood data from Firebase
    fetchMoodData();
  }

  void fetchMoodData() async {
    try {
      // Assuming your collection is named 'moods' and each document represents a mood entry
      var snapshot = await FirebaseFirestore.instance.collection('moods').get();
      if (snapshot.docs.isNotEmpty) {
        var latestMood = snapshot.docs.last; // Get the latest mood entry
        setState(() {
          myDisplayName = latestMood['namahero'] ?? myDisplayName;
          moodText = latestMood['moodstext'] ?? moodText;
          // Assuming you store the image URL in the document
          imgProfile = latestMood['urlHero'] ?? imgProfile;
        });
      }
    } catch (e) {
      print('Error fetching mood data: $e');
    }
  }
}