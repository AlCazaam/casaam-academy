import 'dart:io' as IO;
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/providers/category_provider.dart';
import 'package:uidesign/models/category.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'dart:typed_data';

import 'package:flutter/services.dart'; // rootBundle



class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _pickedFile;
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  bool _isAddingCategory = false; // Track add category button state

  @override
  void initState() {
    super.initState();
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.fadingCircle;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _pickedFile = pickedFile;
    });
  }

  Widget _buildImagePreview() {
    if (_pickedFile != null) {
      if (foundation.kIsWeb) {
        return Image.network(
          _pickedFile!.path,
          height: 80,
          width: 80,
          fit: BoxFit.cover,
        );
      } else {
        return Image.file(
          IO.File(_pickedFile!.path),
          height: 80,
          width: 80,
          fit: BoxFit.cover,
        );
      }
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        // Wrap body in Stack to allow EasyLoading overlay
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 4,
                    color: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Add New Category",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.tertiary,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _nameController,
                              style: TextStyle(color: colorScheme.tertiary),
                              decoration: InputDecoration(
                                labelText: "Category Name",
                                labelStyle: TextStyle(color: colorScheme.tertiary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: colorScheme.tertiary),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: colorScheme.tertiary),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: colorScheme.tertiary),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter category name';
                                }
                                return null;
                              },
                            ).animate().fadeIn(delay: 100.ms),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              style: TextStyle(color: colorScheme.tertiary),
                              decoration: InputDecoration(
                                labelText: "Category Description",
                                labelStyle: TextStyle(color: colorScheme.tertiary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: colorScheme.tertiary),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: colorScheme.tertiary),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: colorScheme.tertiary),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter category description';
                                }
                                return null;
                              },
                            ).animate().fadeIn(delay: 200.ms),
                            const SizedBox(height: 20),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey[300],
                                  child: ClipOval(child: _buildImagePreview()),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.add_a_photo),
                                    onPressed: getImage,
                                    color: colorScheme.inverseSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed:
                                  _isAddingCategory
                                      ? null
                                      : () async {
                                        // Disable the button
                                        if (_formKey.currentState!.validate()) {
                                          //Check the image is empty or not
                                          if (_pickedFile == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Please add image",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          setState(() {
                                            _isAddingCategory =
                                                true; // Set to true when pressed
                                          });
                                          EasyLoading.show(
                                            status: 'Adding category...',
                                          );
                                          try {
                                            String name =
                                                _nameController.text.trim();
                                            String description =
                                                _descriptionController.text
                                                    .trim();
                                            Uint8List? webImageBytes;

                                            if (_pickedFile != null) {
                                              if (foundation.kIsWeb) {
                                                webImageBytes =
                                                    await _pickedFile!
                                                        .readAsBytes();
                                              }
                                            }

                                            await Provider.of<CategoryProvider>(
                                              context,
                                              listen: false,
                                            ).addCategory(
                                              name,
                                              description,
                                              _pickedFile,
                                              webImageBytes,
                                            );

                                            EasyLoading.showSuccess(
                                              'Category added successfully!',
                                            );
                                            _nameController.clear();
                                            _descriptionController.clear();
                                            setState(() {
                                              _pickedFile = null;
                                            });
                                          } catch (e) {
                                            EasyLoading.showError(
                                              "Error adding category: $e",
                                            );
                                          } finally {
                                            EasyLoading.dismiss();
                                            setState(() {
                                              _isAddingCategory =
                                                  false; //Set to false when complete or error
                                            });
                                          }
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.inverseSurface,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                              child:  Text("Add Category", style: TextStyle(color: colorScheme.primary,),),
                            ).animate().slideY(
                              begin: 1,
                              end: 0,
                              duration: 500.ms,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 4,
                    color: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: StreamBuilder<List<Category>>(
                      stream:
                          Provider.of<CategoryProvider>(
                            context,
                            listen: false,
                          ).getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text("No categories added yet.", style: TextStyle(color: colorScheme.tertiary)),
                          );
                        }

                        List<Category> categories = snapshot.data!;

                        return Wrap(
                          children:
                              categories
                                  .map(
                                    (category) =>
                                        CategoryListItem(category: category),
                                  )
                                  .toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          themeProvider.toggleTheme();
        },
        child: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      ),
    );
  }
}

class CategoryListItem extends StatefulWidget {
  final Category category;

  const CategoryListItem({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryListItem> createState() => _CategoryListItemState();
}

class _CategoryListItemState extends State<CategoryListItem> {
  late bool _isShow;

  @override
  void initState() {
    super.initState();
    _isShow = widget.category.isShow;
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondary,
      margin: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.category.imageUrl.isNotEmpty)
                Image.network(
                  widget.category.imageUrl,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Text(
                "Name: ${widget.category.name}",
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.tertiary),
              ),
              Text(
                "Description: ${widget.category.description.length > 50 ? widget.category.description.substring(0, 50) + '...' : widget.category.description}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.tertiary),
              ),
              Text(
                "Created At: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.category.createdAt)}",
                style: TextStyle(color: colorScheme.tertiary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: colorScheme.tertiary),
                    onPressed: () {
                      _showEditDialog(context, widget.category);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(
                        context,
                        widget.category.id,
                      );
                    },
                  ),
                 IconButton(
  icon: Icon(
    _isShow ? Icons.visibility : Icons.visibility_off,
    color: _isShow ? Colors.green : Colors.red,
  ),
  onPressed: () async {
    final newIsShow = !_isShow;

    setState(() {
      _isShow = newIsShow;
    });

    try {
      Uint8List? webImageBytes;

      if (foundation.kIsWeb && widget.category.imageUrl.isNotEmpty) {
        try {
          // Isticmaal HttpClient si loo soo dejiyo bytes-ka webka
          final httpClient = IO.HttpClient();
          final request = await httpClient.getUrl(Uri.parse(widget.category.imageUrl));
          final response = await request.close();

          if (response.statusCode == 200) {
            webImageBytes = await foundation.consolidateHttpClientResponseBytes(response);
          } else {
            throw Exception(
              'Failed to load image. Status code: ${response.statusCode}',
            );
          }
        } catch (e) {
          print("Error fetching image bytes: $e");
          webImageBytes = null; // Set to null in case of error
        }
      }

      Category updatedCategory = Category(
        id: widget.category.id,
        name: widget.category.name,
        description: widget.category.description,
        imageUrl: widget.category.imageUrl,
        createdAt: widget.category.createdAt,
        updatedAt: DateTime.now(),
        isShow: newIsShow,
      );

      await categoryProvider.updateCategory(
        updatedCategory,
        null, // Sii File ahaan haddii aan web ahayn
        webImageBytes, // Sii webImageBytes haddii web ahay
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Category isShow status updated successfully!",
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isShow = widget.category.isShow;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating category: $e"),
        ),
      );
    }
  },
),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to get image bytes (for web)
  Future<Uint8List> _getImageBytes(String imageUrl) async {
    try {
      final byteData = await NetworkAssetBundle(Uri.parse(imageUrl)).load('');
      return byteData.buffer.asUint8List();
    } catch (e) {
      throw Exception("Error fetching image bytes: $e");
    }
  }
}

Future<void> _showEditDialog(BuildContext context, Category category) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return _EditCategoryDialog(category: category);
    },
  );
}

class _EditCategoryDialog extends StatefulWidget {
  final Category category;

  const _EditCategoryDialog({Key? key, required this.category})
    : super(key: key);

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  XFile? editPickedFile;
  Uint8List? webImageBytes;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.category.name);
    descriptionController = TextEditingController(
      text: widget.category.description,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future getEditImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
      editPickedFile = pickedFile;

      if (foundation.kIsWeb && pickedFile != null) {
        pickedFile.readAsBytes().then((value) {
          webImageBytes = value;
          setState(() {});
        });
      }
    });
  }

  Widget _buildEditImagePreview() {
    if (editPickedFile != null) {
      if (foundation.kIsWeb) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.memory(
            webImageBytes!,
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.file(
            IO.File(editPickedFile!.path),
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      if (widget.category.imageUrl.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            widget.category.imageUrl,
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Container();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 4,
      title: Text(
        "Edit Category",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.tertiary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              style: TextStyle(color: colorScheme.tertiary),
              decoration: InputDecoration(
                labelText: "Category Name",
                labelStyle: TextStyle(color: colorScheme.tertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                   borderSide: BorderSide(color: colorScheme.tertiary),
                ),
                 enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.tertiary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.tertiary),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: descriptionController,
               style: TextStyle(color: colorScheme.tertiary),
              decoration: InputDecoration(
                labelText: "Category Description",
                labelStyle: TextStyle(color: colorScheme.tertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                   borderSide: BorderSide(color: colorScheme.tertiary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.tertiary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.tertiary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getEditImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text("Pick New Image"),
            ),
            const SizedBox(height: 12.0),
            _buildEditImagePreview(),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed:
              _isUpdating
                  ? null
                  : () async {
                    String name = nameController.text.trim();
                    String description = descriptionController.text.trim();

                    if (name.isEmpty || description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Name and description cannot be empty"),
                        ),
                      );
                      return;
                    }

                    Category updatedCategory = Category(
                      id: widget.category.id,
                      name: name,
                      description: description,
                      imageUrl: widget.category.imageUrl,
                      createdAt: widget.category.createdAt,
                      updatedAt: DateTime.now(),
                      isShow: widget.category.isShow,
                    );

                    setState(() {
                      _isUpdating = true;
                    });
                    EasyLoading.show(status: 'Updating category...');

                    try {
                      await Provider.of<CategoryProvider>(
                        context,
                        listen: false,
                      ).updateCategory(
                        updatedCategory,
                        editPickedFile,
                        webImageBytes,
                      );
                      EasyLoading.showSuccess('Category updated successfully!');
                      Navigator.of(context).pop();
                    } catch (e) {
                      EasyLoading.showError("Error updating category: $e");
                    } finally {
                      EasyLoading.dismiss();
                      setState(() {
                        _isUpdating = false;
                      });
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.inverseSurface,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text("Update"),
        ),
      ],
    );
  }
}

Future<void> _showDeleteConfirmationDialog(
  BuildContext context,
  String categoryId,
) async {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: colorScheme.primary,
        title:  Text('Delete Category',style: TextStyle(color: colorScheme.tertiary)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to delete this category?',style: TextStyle(color: colorScheme.tertiary)),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              EasyLoading.show(status: 'Deleting category...');
              try {
                await Provider.of<CategoryProvider>(
                  context,
                  listen: false,
                ).deleteCategory(categoryId);
                EasyLoading.showSuccess('Category deleted successfully!');
                Navigator.of(context).pop();
              } catch (e) {
                EasyLoading.showError("Error deleting category: $e");
              } finally {
                EasyLoading.dismiss();
              }
            },
          ),
        ],
      );
    },
  );
}