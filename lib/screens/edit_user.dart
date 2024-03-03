import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetail {
  String uid;
  String name;
  String email;
  int age;
  String gender;
  String userImage;

  UserDetail({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.userImage,
  });
}

class EditUserDetailsScreen extends StatefulWidget {
  @override
  _EditUserDetailsScreenState createState() => _EditUserDetailsScreenState();
}

class _EditUserDetailsScreenState extends State<EditUserDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  File? _userImageFile;
  final ImagePicker _imagePicker = ImagePicker();
  late UserDetail _user;

  @override
  void initState() {
    super.initState();
    // Initialize the user data
    _user = UserDetail(
      uid: '', // Replace with the actual user UID
      name: '', // Replace with the user's name
      email: '', // Replace with the user's email
      age: 20, // Replace with the user's age
      gender: 'Male', // Replace with the user's gender
      userImage:
          'default_user_image_url_here', // Replace with the default user image URL or set it to an empty string
    );

    _nameController = TextEditingController(text: _user.name);
    _emailController = TextEditingController(text: _user.email);
    _ageController = TextEditingController(text: _user.age.toString());
    _genderController = TextEditingController(text: _user.gender);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _userImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUserDetails() async {
    setState(() {
      // Update the user data with the changes
      _user.name = _nameController.text;
      _user.email = _emailController.text;
      _user.age = int.parse(_ageController.text);
      _user.gender = _genderController.text;
    });

    try {
      // Upload the new user image to Firebase Storage if it's changed
      if (_userImageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(_user.uid + '.jpg');
        final uploadTask = storageRef.putFile(_userImageFile!);
        final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        final imageUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          _user.userImage = imageUrl;
        });
      }

      // Update the user details in Firestore
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await userRef.set({
        'name': _user.name,
        'email': _user.email,
        'age': _user.age,
        'gender': _user.gender,
        'userImage': _user.userImage,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User details updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_userImageFile != null)
                Image.file(_userImageFile!, width: 100, height: 100)
              else
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_user.userImage),
                ),
              ElevatedButton(
                onPressed: _getImageFromGallery,
                child: Text('Pick Image from Gallery'),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _genderController,
                decoration: InputDecoration(labelText: 'Gender'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateUserDetails,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
