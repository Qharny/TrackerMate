import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late User _user;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final doc = await _firestore.collection('users').doc(_user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      _usernameController.text = data?['username'] ?? 'User';
      _emailController.text = data?['email'] ?? 'user@example.com';
    }
  }

  Future<void> _updateUserProfile() async {
    await _firestore.collection('users').doc(_user.uid).set({
      'username': _usernameController.text,
      'email': _emailController.text,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _updateUserProfile,
            child: const Text('Update Profile'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
