import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; 

class AddWatchPage extends StatefulWidget {
  @override
  _AddWatchPageState createState() => _AddWatchPageState();
}

class _AddWatchPageState extends State<AddWatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _brandController = TextEditingController();
  final _ratingController = TextEditingController();
  final _materialController = TextEditingController();
  final _movementTypeController = TextEditingController();
  final _waterResistanceController = TextEditingController();
  final _dialSizeController = TextEditingController();
  final _strapSizeController = TextEditingController();
  final _discountController = TextEditingController();
  final _warrantyPeriodController = TextEditingController();
  final _releaseDateController = TextEditingController();
  bool _isActive = true; 
  XFile? _image;
  final _picker = ImagePicker();
  bool isUploading = false;
  Uint8List? _imageBytes;

  
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
      if (pickedFile != null) {
        pickedFile.readAsBytes().then((bytes) {
          setState(() {
            _imageBytes = bytes; 
          });
        });
      }
    });
  }
  Future<String> _uploadImage() async {
    if (_image == null || _imageBytes == null) return '';

    final fileName = _image!.name;
    final filePath = 'watches/$fileName';

    final storage = Supabase.instance.client.storage;

    try {
      if (kIsWeb) {
        
        await storage.from('watch-images').uploadBinary(
              filePath,
              _imageBytes!,
            );
        print("Image uploaded successfully for web.");
      } else {
        
        final file = File(_image!.path);
        await storage.from('watch-images').upload(filePath, file);
        print("Image uploaded successfully for mobile.");
      }

  
      final publicUrl = storage.from('watch-images').getPublicUrl(filePath);
      print("Public URL: $publicUrl");
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  
  Future<void> _addWatch() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to add a watch')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isUploading = true;
    });

    try {
      final imageUrl = await _uploadImage();

      
      final response = await Supabase.instance.client
          .from('watches')
          .insert({
            'name': _nameController.text,
            'category': _categoryController.text,
            'description': _descriptionController.text,
            'price': double.tryParse(_priceController.text) ?? 0.0,
            'stock': int.tryParse(_stockController.text) ?? 0,
            'brand': _brandController.text,
            'rating': double.tryParse(_ratingController.text) ?? 0.0,
            'image_url': imageUrl,
            'material': _materialController.text,
            'movement_type': _movementTypeController.text,
            'water_resistance': _waterResistanceController.text,
            'dial_size': int.tryParse(_dialSizeController.text) ?? 0,
            'strap_size': _strapSizeController.text,
            'discount': double.tryParse(_discountController.text) ?? 0.0,
            'warranty_period': int.tryParse(_warrantyPeriodController.text) ?? 0,
            'release_date': _releaseDateController.text,
            'is_active': _isActive,
            'created_at': DateTime.now().toIso8601String(),
            
          })
          .select()
          .single();

      print(response);

      if (response == null) {
        throw Exception('Failed to add watch');
      }

      
      _nameController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _stockController.clear();
      _brandController.clear();
      _ratingController.clear();
      _materialController.clear();
      _movementTypeController.clear();
      _waterResistanceController.clear();
      _dialSizeController.clear();
      _strapSizeController.clear();
      _discountController.clear();
      _warrantyPeriodController.clear();
      _releaseDateController.clear();
      setState(() {
        _image = null;
        _imageBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Watch added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add watch: $e')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Watch')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Watch Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the watch name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stock quantity';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(labelText: 'Brand'),
                ),
                TextFormField(
                  controller: _ratingController,
                  decoration: InputDecoration(labelText: 'Rating'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _materialController,
                  decoration: InputDecoration(labelText: 'Material'),
                ),
                TextFormField(
                  controller: _movementTypeController,
                  decoration: InputDecoration(labelText: 'Movement Type'),
                ),
                TextFormField(
                  controller: _waterResistanceController,
                  decoration: InputDecoration(labelText: 'Water Resistance'),
                ),
                TextFormField(
                  controller: _dialSizeController,
                  decoration: InputDecoration(labelText: 'Dial Size'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _strapSizeController,
                  decoration: InputDecoration(labelText: 'Strap Size (mm)'),
                ),
                TextFormField(
                  controller: _discountController,
                  decoration: InputDecoration(labelText: 'Discount (%)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _warrantyPeriodController,
                  decoration: InputDecoration(labelText: 'Warranty Period (years)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _releaseDateController,
                  decoration: InputDecoration(labelText: 'Release Date'),
                  keyboardType: TextInputType.datetime,
                ),
                SwitchListTile(
                  title: Text('Active'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: _image == null
                        ? Center(child: Text('Tap to pick an image'))
                        : kIsWeb
                            ? (_imageBytes != null
                                ? Image.memory(_imageBytes!)
                                : Center(child: CircularProgressIndicator()))
                            : Image.file(File(_image!.path), fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 20),
                isUploading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _addWatch,
                        child: Text('Add Watch'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
