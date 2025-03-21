import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:cached_network_image/cached_network_image.dart'; // Import cached_network_image
import 'package:uidesign/models/category.dart';
import 'package:uidesign/models/pdfs.dart';
import 'package:uidesign/providers/category_provider.dart';
import 'package:uidesign/providers/pdfs_provider.dart';
import 'package:image_picker/image_picker.dart';


class AddPdfScreen extends StatefulWidget {
  final PDF? pdfToEdit;
  AddPdfScreen({Key? key, this.pdfToEdit}) : super(key: key);

  @override
  _AddPdfScreenState createState() => _AddPdfScreenState();
}

class _AddPdfScreenState extends State<AddPdfScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  dynamic _pdfFile;
  Uint8List? _imageBytes;
  String? _imageUrl;
  bool _isPublished = false;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _isAddingPdf = false;
  List<PDF> _pdfList = [];
  final ImagePicker _picker = ImagePicker();

  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    if (widget.pdfToEdit != null) {
      _nameController.text = widget.pdfToEdit!.name;
      _descriptionController.text = widget.pdfToEdit!.description;
      _priceController.text = widget.pdfToEdit!.price.toString();
      _isPublished = widget.pdfToEdit!.isPublished;
      _selectedCategoryId = widget.pdfToEdit!.categoryId;
      _imageUrl = widget.pdfToEdit!.imageUrl;
    }
    _loadPdfs();

    _animationController.forward(); // Start the animation
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPdfs() async {
    Provider.of<PdfProvider>(context, listen: false).getPdfs().listen((
      List<PDF> pdfs,
    ) {
      if (mounted) {
        setState(() {
          _pdfList = pdfs;
        });
      }
    });
  }

  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      if (result.files.single.bytes != null) {
        setState(() {
          _pdfFile = result.files.single.bytes;
        });
      } else if (result.files.single.path != null) {
        setState(() {
          _pdfFile = File(result.files.single.path!);
        });
      }
    }
  }

  Future<void> _pickImageBytes() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _imageBytes = await image.readAsBytes();
      setState(() {});
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _pdfFile = null;
      _imageBytes = null;
      _imageUrl = null;
      _isPublished = false;
      _selectedCategoryId = null;
      _selectedCategoryName = null;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
     final themeProvider = Provider.of<ThemeProvider>(context);
     final ThemeData theme = themeProvider.themeData;

    final categoryProvider = Provider.of<CategoryProvider>(context);
    final pdfProvider = Provider.of<PdfProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLaptop = screenWidth > 992;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pdfToEdit == null ? 'Add PDF' : 'Edit PDF',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: theme.colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name Field
                      TextFormField(
                         style: TextStyle(color: theme.colorScheme.onSurface),
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          prefixIcon: Icon(Icons.text_fields, color: theme.colorScheme.primaryContainer,),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter name'
                                    : null,
                      ),
                      SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                         style: TextStyle(color: theme.colorScheme.onSurface),
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          prefixIcon: Icon(Icons.info, color: theme.colorScheme.primaryContainer,),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Price Field
                      TextFormField(
                         style: TextStyle(color: theme.colorScheme.onSurface),
                        controller: _priceController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Price',
                          labelStyle: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          prefixIcon: Icon(Icons.attach_money, color: theme.colorScheme.primaryContainer,),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Category Dropdown
                      StreamBuilder<List<Category>>(
                        stream: categoryProvider.getCategories(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error),);
                          }
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primaryContainer,));
                          }

                          List<Category> categories = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Category',
                              labelStyle: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              prefixIcon: Icon(Icons.category, color: theme.colorScheme.primaryContainer,),
                            ),
                            value: _selectedCategoryId,
                            items:
                                categories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category.id,
                                    child: Text(category.name, style: TextStyle(color: theme.colorScheme.onSurface),),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                                _selectedCategoryName =
                                    categories
                                        .firstWhere((cat) => cat.id == value)
                                        .name;
                              });
                            },
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Select a category'
                                        : null,
                          );
                        },
                      ),
                      SizedBox(height: 16),

                      // PDF Selection Button
                      ElevatedButton.icon(
                        onPressed: _pickPdfFile,
                        icon: Icon(Icons.attach_file, color: theme.colorScheme.onPrimary),
                        label: Text(
                          'Select PDF File',
                          style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        _pdfFile != null ? 'PDF Selected' : 'No PDF Selected',
                        style: TextStyle(fontSize: 14, color: theme.colorScheme.tertiary),
                      ),
                      SizedBox(height: 16),

                      // Image Selection Button
                      ElevatedButton.icon(
                        onPressed: _pickImageBytes,
                        icon: Icon(Icons.image, color: theme.colorScheme.onPrimary),
                        label: Text(
                          'Select Image File',
                          style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Image Preview
                      _imageBytes != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              _imageBytes!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                          : (_imageUrl != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: _imageUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) =>
                                          Center(child: CircularProgressIndicator(color: theme.colorScheme.primaryContainer,)),
                                  errorWidget:
                                      (context, url, error) =>
                                          Icon(Icons.error, color: theme.colorScheme.error,),
                                ),
                              )
                              : Text(
                                'No Image Selected',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.tertiary,
                                ),
                              )),
                      SizedBox(height: 16),

                      // Published Checkbox
                      Row(
                        children: [
                          Text('Published:', style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface)),
                          Checkbox(
                            checkColor: theme.colorScheme.onPrimary,
                            activeColor: theme.colorScheme.primaryContainer,
                            value: _isPublished,
                            onChanged: (value) {
                              setState(() {
                                _isPublished = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                         style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                           foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed:
                            _isAddingPdf
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isAddingPdf = true;
                                    });

                                    EasyLoading.show(
                                      status:
                                          widget.pdfToEdit == null
                                              ? 'Adding PDF...'
                                              : 'Updating PDF...',
                                    );

                                    try {
                                      String? imageUrl = _imageUrl;

                                      if (_imageBytes != null) {
                                        imageUrl = await pdfProvider
                                            .uploadImageBytes(_imageBytes!);

                                        if (imageUrl == null) {
                                          EasyLoading.showError(
                                            'Failed to upload image',
                                          );
                                          return;
                                        }
                                      }

                                      if (widget.pdfToEdit == null) {
                                        await pdfProvider.addPdf(
                                          name: _nameController.text,
                                          description:
                                              _descriptionController.text,
                                          price: double.parse(
                                            _priceController.text,
                                          ),
                                          categoryId: _selectedCategoryId!,
                                          pdfFile: _pdfFile,
                                          imageUrl: imageUrl,
                                          isPublished: _isPublished,
                                        );
                                      } else {
                                        await pdfProvider.updatePdf(
                                          id: widget.pdfToEdit!.id,
                                          name: _nameController.text,
                                          description:
                                              _descriptionController.text,
                                          price: double.parse(
                                            _priceController.text,
                                          ),
                                          categoryId: _selectedCategoryId!,
                                          pdfFile: _pdfFile,
                                          imageUrl: imageUrl,
                                          isPublished: _isPublished,
                                        );
                                      }

                                      EasyLoading.showSuccess(
                                        widget.pdfToEdit == null
                                            ? 'PDF Added!'
                                            : 'PDF Updated!',
                                      );
                                      _clearForm();
                                      _loadPdfs();
                                    } catch (e) {
                                      print('Error adding/updating PDF: $e');
                                      EasyLoading.showError(
                                        'Failed to add/update PDF',
                                      );
                                    } finally {
                                      setState(() {
                                        _isAddingPdf = false;
                                      });
                                      EasyLoading.dismiss();
                                    }
                                  }
                                },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            widget.pdfToEdit == null ? 'Add PDF' : 'Update PDF',
                            style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 18),
                          ),
                        ),
                      ).animate().scale(
                        
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isAddingPdf)
              Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: theme.colorScheme.primary,
        height: isLaptop ? 150 : 120,
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _pdfList.length,
          itemBuilder: (context, index) {
            PDF pdf = _pdfList[index];
            return _buildPdfCard(context, pdf, isLaptop);
          },
        ),
      ),
    );
  }

  Widget _buildPdfCard(BuildContext context, PDF pdf, bool isLaptop) {
    final themeProvider = Provider.of<ThemeProvider>(context);
     final ThemeData theme = themeProvider.themeData;

    return Container(
      width: isLaptop ? 200 : 150,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: theme.colorScheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // PDF Image (if available)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      pdf.imageUrl != null && pdf.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: pdf.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    Center(child: CircularProgressIndicator(color: theme.colorScheme.primaryContainer,)),
                            errorWidget:
                                (context, url, error) =>
                                    Icon(Icons.error, color: theme.colorScheme.error),
                          )
                          : Icon(
                            Icons.picture_as_pdf,
                            size: isLaptop ? 40 : 30,
                            color: theme.colorScheme.tertiary,
                          ),
                ),
              ),
              SizedBox(height: 8),

              // PDF Name
              Text(
                pdf.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isLaptop ? 16 : 14,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Action Buttons (Edit, Delete, Download)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Edit Button
                  IconButton(
                    icon:  Icon(Icons.edit, color: theme.colorScheme.secondaryContainer),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPdfScreen(pdfToEdit: pdf),
                        ),
                      );
                    },
                  ),

                  // Delete Button
                  IconButton(
                    icon:  Icon(Icons.delete, color: theme.colorScheme.error),
                    onPressed:
                        () => _showDeleteConfirmationDialog(context, pdf),
                  ),

                  // Download Button
                  if (pdf.fileUrl != null && pdf.fileUrl!.isNotEmpty)
                    IconButton(
                      icon:  Icon(Icons.download, color: Colors.green),
                      onPressed: () => _launchURL(pdf.fileUrl!),
                    )
                  else
                    SizedBox.shrink(), // Don't show if no file URL
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    PDF pdf,
  ) async {
     final themeProvider = Provider.of<ThemeProvider>(context);
     final ThemeData theme = themeProvider.themeData;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title:  Text('Confirm Delete', style: TextStyle(color: theme.colorScheme.onSurface),),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this PDF?', style: TextStyle(color: theme.colorScheme.onSurface),),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
               style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
               style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePdf(pdf);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePdf(PDF pdf) async {
     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final ThemeData theme = themeProvider.themeData;
    EasyLoading.show(status: 'Deleting PDF...');
    try {
      await Provider.of<PdfProvider>(context, listen: false).deletePdf(pdf.id);
      EasyLoading.showSuccess('PDF Deleted Successfully!', );
      _loadPdfs();
    } catch (e) {
      print('Error deleting PDF: $e');
      EasyLoading.showError('Failed to delete PDF',);
    } finally {
      EasyLoading.dismiss();
    }
  }
}