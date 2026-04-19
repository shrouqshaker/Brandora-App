import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winterproject/home/data.dart';
import 'package:winterproject/home/add_material_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int selectedTab = 1;
  final Color primaryColor = const Color(0xFF3F51B5);

 @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<MaterialsData>(context, listen: false).fetchMaterials();
  });
}

  @override
  Widget build(BuildContext context) {
    final materialsData = Provider.of<MaterialsData>(context);
    final materials = materialsData.materials;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 30),
              
              const Text(
                "Inventory\nManagement",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E232C),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Track materials and monitor stock\nlevels in real-time.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),

              _buildTabs(),
              const SizedBox(height: 24),

              Expanded(
                child: selectedTab == 1
                    ? materialsData.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildMaterialsList(materials, materialsData)
                    : _buildEmptyState(
                        selectedTab == 0 ? "Overview" : "Analytics",
                        "Information will appear here soon.",
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: selectedTab == 1 ? _buildFloatingButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMaterialsList(List<MaterialModel> materials, MaterialsData materialsData) {
    if (materials.isEmpty) {
      return const Center(
        child: Text(
          "No materials added yet.\nClick the button below to start.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final item = materials[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMaterialScreen(
                  materialToEdit: item,
                  index: index,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.inventory_2, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "Stock: ${item.quantity} ${item.unit}",
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${item.price} ج.م",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: primaryColor,
                        fontSize: 16
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () => materialsData.removeMaterial(index),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        Text(
          "Brandora",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
        ),
        IconButton(
          onPressed: () =>
              Provider.of<MaterialsData>(context, listen: false).fetchMaterials(),
          icon: Icon(Icons.refresh, color: primaryColor),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabItem("Overview", 0),
          _tabItem("Materials", 1),
          _tabItem("Analytics", 2),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Container(
      height: 55,
      width: 210,
      margin: const EdgeInsets.only(bottom: 10),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMaterialScreen()),
          );
        },
        backgroundColor: primaryColor,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add New Material",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildEmptyState(String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 50, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(sub, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}