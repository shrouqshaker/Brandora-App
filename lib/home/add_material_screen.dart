import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:winterproject/home/data.dart'; 

class AddMaterialScreen extends StatefulWidget {
  final MaterialModel? materialToEdit;
  final int? index;

  const AddMaterialScreen({super.key, this.materialToEdit, this.index});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final Color primaryColor = const Color(0xFF3F51B5);
  final Color fieldBackgroundColor = const Color(0xFFF8F9FD);
  
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController priceController;
  String? selectedUnit;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.materialToEdit?.name ?? "");
    quantityController = TextEditingController(text: widget.materialToEdit?.quantity ?? "");
    priceController = TextEditingController(text: widget.materialToEdit?.price ?? "");
    selectedUnit = widget.materialToEdit?.unit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E232C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.materialToEdit == null ? "Add New Material" : "Edit Material",
          style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("MATERIAL NAME"),
              _buildTextField(hint: "e.g. Recycled Granules", controller: nameController),
              
              const SizedBox(height: 24),
        
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("QUANTITY"),
                        _buildTextField(
                          hint: "e.g. 2500", 
                          controller: quantityController, 
                          isNumber: true,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("UNIT"),
                        _buildDropdown(),
                      ],
                    ),
                  ),
                ],
              ),
        
              const SizedBox(height: 24),
        
              _buildLabel("UNIT PRICE (\$)"),
              _buildTextField(
                hint: "e.g. 5.80", 
                controller: priceController, 
                isNumber: true,
                prefix: const Icon(Icons.attach_money, size: 18, color: Color(0xFF3F51B5)),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              ),
        
              const SizedBox(height: 30),
        
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "All fields are required for inventory synchronization",
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ],
              ),
        
              const SizedBox(height: 30),
        
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final String name = nameController.text.trim();
                    final String qtyStr = quantityController.text.trim();
                    final String priceStr = priceController.text.trim();
        
                    if (name.isNotEmpty &&
                        qtyStr.isNotEmpty &&
                        selectedUnit != null &&
                        priceStr.isNotEmpty) {
                      
                      if (double.tryParse(qtyStr) == null || double.tryParse(priceStr) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter valid numbers for quantity and price'), backgroundColor: Colors.orange),
                        );
                        return;
                      }
        
                      final materialsData = Provider.of<MaterialsData>(context, listen: false);
                      
                      final newMaterial = MaterialModel(
                        name: name,
                        quantity: qtyStr,
                        unit: selectedUnit!,
                        price: priceStr,
                      );
        
                      bool success = false;
                      if (widget.materialToEdit == null) {
                        success = await materialsData.addMaterial(newMaterial);
                      } else {
                        success = await materialsData.updateExistingMaterial(widget.index!, newMaterial);
                      }
                      
                      if (!context.mounted) return;

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Material Saved Successfully! '), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(materialsData.error ?? 'Failed to save material'), backgroundColor: Colors.red),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.materialToEdit == null ? "Save Material" : "Update Material",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8391A1),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint, 
    required TextEditingController controller, 
    bool isNumber = false, 
    Widget? prefix,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: prefix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fieldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedUnit,
          hint: const Text("Select unit", style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          items: ["kg",  "piece", "liter", "meter"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => selectedUnit = newValue),
        ),
      ),
    );
  }
}