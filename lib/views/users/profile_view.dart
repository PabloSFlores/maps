import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    SharedPreferences? localStorage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://thispersondoesnotexist.com/'),
                  radius: 60,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
