import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'package:winterproject/core/services/api_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProductsData>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsData>(context);
    const Color primaryColor = Color(0xFF3F51B5);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Brandora Store", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: productsData.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productsData.products.isEmpty
              ? const Center(
                  child: Text(
                    "No products yet.\nAdd one from Production tab.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: productsData.products.length,
              itemBuilder: (context, index) {
                final product = productsData.products[index];
                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.2,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: product.imagePath != null
                                ? Image.network(
                                    '${ApiService.baseUrl.replaceAll('/api', '')}/${product.imagePath!}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.shopping_bag, size: 50, color: primaryColor),
                                  )
                                : const Icon(Icons.shopping_bag, size: 50, color: primaryColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("\$${product.price}", style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    onPressed: () => productsData.removeProduct(product.id!),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}