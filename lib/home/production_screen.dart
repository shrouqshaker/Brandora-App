import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:winterproject/home/data.dart'; 
import 'add_material_screen.dart'; 

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  bool _includesMaterials = true;
  bool _isSubmitting = false;  // loading state for the submit button
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final List<String> _addedMaterials = [];
  double _totalMaterialsCost = 0.0;
  double _finalPriceWithMargin = 0.0;
  
  final TextEditingController _materialQtyController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productQtyController = TextEditingController();
  final TextEditingController _manualPriceController = TextEditingController(); 
  final TextEditingController _marginController = TextEditingController();
  final TextEditingController _additionalExpensesController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();

  String? _selectedMaterial; 
  String? _errorMessage; 

  final Color primaryColor = const Color(0xFF3F51B5);
  final Color textFieldBg = const Color(0xFFF8F9FE);

  @override
void initState() {
  super.initState();

  // Load materials so the dropdown is populated
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<MaterialsData>().fetchMaterials();
  });
}
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _calculateTotalCost(MaterialsData materialsData) {
    double total = 0.0;
    for (var item in _addedMaterials) {
      List<String> parts = item.split(" - ");
      String name = parts[0];
      double qty = double.tryParse(parts[1]) ?? 0.0;

      try {
        var materialInfo = materialsData.materials.firstWhere((m) => m.name == name);
        double price = double.tryParse(materialInfo.price) ?? 0.0;
        total += (qty * price);
      } catch (e) { total += 0; }
    }
    setState(() {
      _totalMaterialsCost = total;
      _updateFinalPrice();
    });
  }

  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _profitController = TextEditingController();
  
  double _profitPercentage = 0.0;

  void _updateFinalPrice() {
    double productQty = double.tryParse(_productQtyController.text) ?? 1.0;
    if (productQty <= 0) productQty = 1.0;

    double additionalExpenses = double.tryParse(_additionalExpensesController.text) ?? 0.0;
    
    if (_includesMaterials) {
      double marginPercent = double.tryParse(_marginController.text) ?? 0.0;
      double baseCost = _totalMaterialsCost + additionalExpenses;
      setState(() {
        double totalFinalPrice = baseCost + (baseCost * (marginPercent / 100));
        _finalPriceWithMargin = totalFinalPrice / productQty;
      });
    } else {
      double costPrice = double.tryParse(_costPriceController.text) ?? 0.0;
      double profit = double.tryParse(_profitController.text) ?? 0.0;
      
      setState(() {
        double totalCost = costPrice + additionalExpenses;
        if (totalCost > 0) {
          _profitPercentage = (profit / totalCost) * 100;
        } else {
          _profitPercentage = 0.0;
        }
        _finalPriceWithMargin = (totalCost + profit) / productQty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialsData = Provider.of<MaterialsData>(context);
    final productsData = Provider.of<ProductsData>(context, listen: false);
    final availableMaterials = materialsData.getMaterialNames();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text("Production", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Color(0xFF3F51B5)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMaterialScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(child: _buildPhotoUploadSection()),
              const SizedBox(height: 30),
        
              _buildLabel("PRODUCT NAME"),
              _buildField("e.g. Polyethylene Tubing", controller: _productNameController),
              const SizedBox(height: 20),
        
              _buildLabel("BATCH QUANTITY"),
              _buildField("0", controller: _productQtyController, isNumber: true, onChanged: (_) => _updateFinalPrice()),
              const SizedBox(height: 20),
        
              _buildToggleCard(),
              const SizedBox(height: 25),
        
              if (!_includesMaterials) ...[
                _buildLabel("COST PRICE (EGP)"),
                _buildField("Total cost price", controller: _costPriceController, isNumber: true, onChanged: (_) => _updateFinalPrice()),
                const SizedBox(height: 20),
                _buildManualPricingCard(),
              ],
        
              if (_includesMaterials) ...[
                _buildMaterialsUsedCard(availableMaterials, materialsData),
                const SizedBox(height: 25),
                _buildPricingCard(),
              ],
        
              const SizedBox(height: 30),
              _buildMainButton(productsData, materialsData),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(ProductsData productsData, MaterialsData materialsData) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSubmitting
            ? null  // disable while uploading
            : () async {
                // 1. Validation for Image
                if (_image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload a product photo')));
                  return;
                }

                // 2. Validation for Name and Quantity
                if (_productNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter product name')));
                  return;
                }
                
                double productQtyToMake = double.tryParse(_productQtyController.text) ?? 0.0;
                if (productQtyToMake <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid product quantity')));
                  return;
                }

                // 3. Validation for Manual Price (When toggle is OFF)
                if (!_includesMaterials) {
                  double manualPrice = double.tryParse(_manualPriceController.text) ?? 0.0;
                  if (manualPrice <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid price for the product')));
                    return;
                  }
                }

                // 4. Validation for Materials (When toggle is ON)
                if (_includesMaterials) {
                  if (_addedMaterials.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one material or disable "Includes Materials"')));
                    return;
                  }

                  // Check stock shortage
                  List<String> missingMaterials = [];
                  for (var item in _addedMaterials) {
                    List<String> parts = item.split(" - ");
                    String matName = parts[0];
                    double qtyPerUnit = double.tryParse(parts[1]) ?? 0.0;
                    double totalNeeded = productQtyToMake * qtyPerUnit;

                    var materialInStock = materialsData.materials.firstWhere(
                      (m) => m.name.trim().toLowerCase() == matName.trim().toLowerCase(),
                    );
                    double availableQty = double.tryParse(materialInStock.quantity) ?? 0.0;

                    if (totalNeeded > availableQty) {
                      double diff = totalNeeded - availableQty;
                      missingMaterials.add("$matName (Need $diff ${materialInStock.unit} more)");
                    }
                  }

                  if (missingMaterials.isNotEmpty) {
                    _showShortageDialog(missingMaterials);
                    return; 
                  }
                }

                // 5. All valid — show loading and submit
                setState(() => _isSubmitting = true);

                String finalPrice = _finalPriceWithMargin.toStringAsFixed(2);

                final success = await productsData.addProduct(ProductModel(
                  name: _productNameController.text,
                  quantity: _productQtyController.text,
                  price: finalPrice,
                  imagePath: _image?.path,
                  usedMaterials: List.from(_addedMaterials),
                  costPrice: _costPriceController.text,
                  additionalExpenses: _additionalExpensesController.text,
                  profit: _profitController.text,
                  profitPercentage: _profitPercentage.toString(),
                ));

                // 6. Deduct materials from server if applicable
                if (success && _includesMaterials) {
                  for (var item in _addedMaterials) {
                    List<String> parts = item.split(" - ");
                    String matName = parts[0];
                    double qtyPerUnit = double.tryParse(parts[1]) ?? 0.0;
                    await materialsData.deductMaterial(matName, productQtyToMake * qtyPerUnit);
                  }
                }

                setState(() => _isSubmitting = false);

                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product Added Successfully! '), backgroundColor: Colors.green),
                  );
                  _clearFields();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(productsData.error ?? 'Failed to add product'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text("Add Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showShortageDialog(List<String> missingMaterials) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Column(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 50),
            const SizedBox(height: 10),
            Text("Stock Shortage", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("You don't have enough materials. Missing items:", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            ...missingMaterials.map((m) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.close, color: Colors.red, size: 16),
                  const SizedBox(width: 10),
                  Expanded(child: Text(m, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500, fontSize: 13))),
                ],
              ),
            )),
          ],
        ),
        actionsPadding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Got it", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFields() {
    _productNameController.clear(); 
    _productQtyController.clear(); 
    _manualPriceController.clear();
    _marginController.clear();
    _additionalExpensesController.clear();
    _costPriceController.clear();
    _profitController.clear();
    setState(() { 
      _addedMaterials.clear(); 
      _totalMaterialsCost = 0.0; 
      _finalPriceWithMargin = 0.0; 
      _profitPercentage = 0.0;
      _image = null; 
      _errorMessage = null; 
    });
  }

  Widget _buildPricingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("ADDITIONAL EXPENSES (EGP)"),
          _buildPricingField(_additionalExpensesController),
          const SizedBox(height: 15),
          _buildLabel("PROFIT MARGIN (%)"),
          _buildPricingField(_marginController),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          _buildPriceRow("Total Materials Cost", "${_totalMaterialsCost.toStringAsFixed(2)} EGP", Colors.grey),
          const SizedBox(height: 8),
          _buildPriceRow("Final Selling Price", "${_finalPriceWithMargin.toStringAsFixed(2)} EGP", primaryColor, isBold: true),
        ],
      ),
    );
  }

  Widget _buildManualPricingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("ADDITIONAL EXPENSES (EGP)"),
          _buildPricingField(_additionalExpensesController),
          const SizedBox(height: 15),
          _buildLabel("PROFIT (EGP)"),
          _buildPricingField(_profitController),
          const SizedBox(height: 10),
          Text("Calculated Margin: ${_profitPercentage.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          _buildPriceRow("Final Selling Price", "${_finalPriceWithMargin.toStringAsFixed(2)} EGP", primaryColor, isBold: true),
        ],
      ),
    );
  }

  Widget _buildPricingField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) => _updateFinalPrice(),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isBold ? 18 : 14)),
      ],
    );
  }

  Widget _buildMaterialsUsedCard(List<String> availableMaterials, MaterialsData materialsData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: textFieldBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 10),
              Text("Materials Used", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel("SELECT MATERIAL"),
          _buildMaterialDropdown(availableMaterials),
          const SizedBox(height: 15),
          _buildLabel("QUANTITY"),
          _buildField("Enter quantity", 
            controller: _materialQtyController, 
            isNumber: true,
            onChanged: (val) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
            }
          ),
          
          if (_errorMessage != null) 
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
            ),

          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              if (_selectedMaterial != null && _materialQtyController.text.isNotEmpty) {
                final selectedMatData = materialsData.materials.firstWhere((m) => m.name == _selectedMaterial);
                double availableQty = double.tryParse(selectedMatData.quantity) ?? 0.0;
                double enteredQty = double.tryParse(_materialQtyController.text) ?? 0.0;

                if (enteredQty > availableQty) {
                  setState(() {
                    _errorMessage = "Insufficient stock! Available: $availableQty ${selectedMatData.unit}";
                  });
                } else {
                  setState(() {
                    _errorMessage = null; 
                    String qty = _materialQtyController.text;
                    int existingIndex = _addedMaterials.indexWhere((item) => item.startsWith("$_selectedMaterial -"));
                    if (existingIndex != -1) {
                      _addedMaterials[existingIndex] = "$_selectedMaterial - $qty";
                    } else {
                      _addedMaterials.add("$_selectedMaterial - $qty");
                    }
                    _calculateTotalCost(materialsData);
                    _materialQtyController.clear();
                    _selectedMaterial = null;
                  });
                }
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Add Material"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              foregroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          if (_addedMaterials.isNotEmpty) ...[
            const SizedBox(height: 15),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _addedMaterials.map((material) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(material, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _addedMaterials.remove(material);
                          _calculateTotalCost(materialsData);
                        });
                      },
                      child: const Icon(Icons.close, size: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 150, height: 150,
        decoration: BoxDecoration(
          color: textFieldBg, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
        ),
        child: _image == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade400, size: 45),
          const SizedBox(height: 10),
          Text("Upload", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ]) : null,
      ),
    );
  }

  Widget _buildMaterialDropdown(List<String> availableMaterials) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMaterial,
          hint: Text(availableMaterials.isEmpty ? "No materials" : "Choose material...", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          isExpanded: true,
          items: availableMaterials.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
          onChanged: (newValue) {
            setState(() {
               _selectedMaterial = newValue;
               _errorMessage = null; 
            });
          },
        ),
      ),
    );
  }

  Widget _buildField(String hint, {TextEditingController? controller, bool isNumber = false, Function(String)? onChanged}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(18)),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF5F7FF), borderRadius: BorderRadius.circular(15)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.layers_outlined, color: primaryColor)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Includes Materials", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text("Track raw material usage", style: TextStyle(color: Colors.grey, fontSize: 11))])),
        Switch(value: _includesMaterials, onChanged: (val) => setState(() => _includesMaterials = val), activeTrackColor: primaryColor.withValues(alpha: 0.5), activeThumbColor: primaryColor),
      ]),
    );
  }
}