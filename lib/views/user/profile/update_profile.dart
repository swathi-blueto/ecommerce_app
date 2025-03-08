import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/views/user/profile/profile_details.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedGender;
  String? _selectedState;
  String? _selectedCity;
  XFile? _profileImage;

  final List<String> _genders = ["Male", "Female", "Other"];
  final List<String> _states = ["Tamil Nadu", "Karnataka", "Kerala"];
  final Map<String, List<String>> _cities = {
    "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai"],
    "Karnataka": ["Bangalore", "Mysore"],
    "Kerala": ["Kochi", "Trivandrum"]
  };

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile; 
      });
    }
  }

  void _updateProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    String fullName = _fullNameController.text;
    String phoneNumber = _phoneNumberController.text;

    if (fullName.isEmpty ||
        phoneNumber.isEmpty ||
        _selectedGender == null ||
        _selectedState == null ||
        _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    String? imageUrl;
    if (_profileImage != null) {
      imageUrl = await authProvider.uploadProfileImage(_profileImage!); // Pass XFile directly
    }

    print("imageurl in updateprofile $imageUrl");

    await authProvider.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      gender: _selectedGender!,
      state: _selectedState!,
      city: _selectedCity!,
      imageUrl: imageUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfileDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
          
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? NetworkImage(_profileImage!.path) // Use NetworkImage for XFile
                    : AssetImage("assets/profile_placeholder.png")
                        as ImageProvider,
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 20),

           
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            SizedBox(height: 10),

           
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            SizedBox(height: 10),

            
            DropdownButtonFormField<String>(
              value: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              items: _genders
                  .map((gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender)))
                  .toList(),
              decoration: InputDecoration(labelText: "Gender"),
            ),
            SizedBox(height: 10),

           
            DropdownButtonFormField<String>(
              value: _selectedState,
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                  _selectedCity = null; 
                });
              },
              items: _states
                  .map((state) =>
                      DropdownMenuItem(value: state, child: Text(state)))
                  .toList(),
              decoration: InputDecoration(labelText: "State"),
            ),
            SizedBox(height: 10),

            
            DropdownButtonFormField<String>(
              value: _selectedCity,
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
              },
              items:
                  _selectedState != null && _cities.containsKey(_selectedState)
                      ? _cities[_selectedState]!
                          .map((city) =>
                              DropdownMenuItem(value: city, child: Text(city)))
                          .toList()
                      : [],
              decoration: InputDecoration(labelText: "City"),
            ),

            SizedBox(height: 20),

           
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}