import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class AddWatchPage extends StatefulWidget {
  final Map<String, dynamic>? watch;

  AddWatchPage({this.watch});

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

  @override
  void initState() {
    super.initState();
    if (widget.watch != null) {
      _nameController.text = widget.watch!['name'];
      _categoryController.text = widget.watch!['category'];
      _descriptionController.text = widget.watch!['description'];
      _priceController.text = widget.watch!['price'].toString();
      _stockController.text = widget.watch!['stock'].toString();
      _brandController.text = widget.watch!['brand'];
      _ratingController.text = widget.watch!['rating'].toString();
      _materialController.text = widget.watch!['material'];
      _movementTypeController.text = widget.watch!['movement_type'];
      _waterResistanceController.text = widget.watch!['water_resistance'];
      _dialSizeController.text = widget.watch!['dial_size'].toString();
      _strapSizeController.text = widget.watch!['strap_size'];
      _discountController.text = widget.watch!['discount'].toString();
      _warrantyPeriodController.text =
          widget.watch!['warranty_period'].toString();
      _releaseDateController.text = widget.watch!['release_date'];
      _isActive = widget.watch!['is_active'];
    }
  }

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

 Future<String> _uploadImage(String? existingImageUrl) async {
  if (_image == null || _imageBytes == null) return existingImageUrl ?? '';

  
  final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_${_image!.name}';
  final String filePath = 'watches/$uniqueFileName';

  final storage = Supabase.instance.client.storage;

  
  if (await _imageExists(filePath)) {
    print("Image already exists: $filePath");
    return existingImageUrl ?? ''; 
  }

  try {
    if (kIsWeb) {
      await storage.from('watch-images').uploadBinary(
            filePath,
            _imageBytes!,
          );
    } else {
      final file = File(_image!.path);
      await storage.from('watch-images').upload(filePath, file);
    }

    final publicUrl = storage.from('watch-images').getPublicUrl(filePath);
    return publicUrl;
  } catch (e) {
    print('Error uploading image: $e');
    return '';
  }
}

Future<bool> _imageExists(String filePath) async {
  final storage = Supabase.instance.client.storage;
  try {
    final response = await storage.from('watch-images').list();
    return response.any((file) => file.name == filePath.split('/').last);
  } catch (e) {
    print('Error checking image existence: $e');
    return false;
  }
}



  Future<void> _addOrUpdateWatch() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('You need to be logged in to add or update a watch')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isUploading = true;
    });

    try {
      String imageUrl;

      
      if (_image != null) {
        imageUrl = await _uploadImage(
            widget.watch != null ? widget.watch!['image_url'] : null);
      } else {
       
        imageUrl = widget.watch != null ? widget.watch!['image_url'] : '';
      }

      final watchData = {
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
      };

      if (widget.watch == null) {
        // Insert new watch
        final response = await Supabase.instance.client
            .from('watches')
            .insert(watchData)
            .select()
            .single();

        if (response == null) {
          throw Exception('Failed to add watch');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Watch added successfully!')),
        );
      } else {
        
        final response = await Supabase.instance.client
            .from('watches')
            .update(watchData)
            .eq('id', widget.watch!['id'])
            .select()
            .maybeSingle();

        if (response == null) {
          throw Exception('Failed to update watch: No rows returned');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Watch updated successfully!')),
        );
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add or update watch: $e')),
      );
      print("Failed to update: $e");
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    final storage = Supabase.instance.client.storage;
    final filePath = imageUrl.split('/').last;

    try {
      await storage.from('watch-images').remove([filePath]);
      print("Image deleted successfully.");
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.watch == null ? 'Add Watch' : 'Edit Watch')),
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
                  decoration:
                      InputDecoration(labelText: 'Warranty Period (years)'),
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
                        onPressed: _addOrUpdateWatch,
                        child: Text(widget.watch == null
                            ? 'Add Watch'
                            : 'Update Watch'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
