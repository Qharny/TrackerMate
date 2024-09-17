import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late User _user;
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _displayNameController = TextEditingController(text: _user.displayName);
    _emailController = TextEditingController(text: _user.email);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update display name
      await _user.updateDisplayName(_displayNameController.text);
      
      // Update email
      if (_emailController.text != _user.email) {
        await _user.updateEmail(_emailController.text);
      }

      // Update Firestore document
      await _firestore.collection('users').doc(_user.uid).set({
        'displayName': _displayNameController.text,
        'email': _emailController.text,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    String? email = _user.email;
    if (email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending password reset email: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm) {
      try {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(_user.uid).delete();
        await _firestore.collection('device_locations').doc(_user.uid).delete();

        // Delete the user account
        await _user.delete();

        // Sign out and navigate to login screen
        await _auth.signOut();
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Update Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Change Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _deleteAccount,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}