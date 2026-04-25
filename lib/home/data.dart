import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:winterproject/core/services/api_service.dart';


// MODEL — Raw Material

class MaterialModel {
  String? id;
  String name;
  String quantity;
  String price;
  String unit;

  MaterialModel({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.unit,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id:       json['_id']?.toString(),
      name:     json['name']  ?? '',
      quantity: (json['quantity'] ?? 0).toString(),
      price:    (json['price']    ?? 0).toString(),
      unit:     json['unit']  ?? 'kg',
    );
  }

  Map<String, dynamic> toJson() => {
        'name':     name,
        'quantity': double.tryParse(quantity) ?? 0,
        'price':    double.tryParse(price)    ?? 0,
        'unit':     unit,
      };
}


// MODEL — Finished Product

class ProductModel {
  String? id;
  String name;
  String quantity;
  String price;
  String? imagePath;
  List<String> usedMaterials;
  String? costPrice;
  String? additionalExpenses;
  String? profit;
  String? profitPercentage;

  ProductModel({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.imagePath,
    this.usedMaterials = const [],
    this.costPrice,
    this.additionalExpenses,
    this.profit,
    this.profitPercentage,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id:           json['_id']?.toString(),
      name:         json['name']  ?? '',
      quantity:     (json['quantity'] ?? 0).toString(),
      price:        (json['price']    ?? 0).toString(),
      imagePath:    json['imagePath'],
      usedMaterials: List<String>.from(json['usedMaterials'] ?? []),
      costPrice:    (json['costPrice'] ?? 0).toString(),
      additionalExpenses: (json['additionalExpenses'] ?? 0).toString(),
      profit:       (json['profit'] ?? 0).toString(),
      profitPercentage: (json['profitPercentage'] ?? 0).toString(),
    );
  }
}


// PROVIDER — Materials Data

class MaterialsData extends ChangeNotifier {
  List<MaterialModel> _materials = [];
  bool _isLoading = false;
  String? _error;

  List<MaterialModel> get materials  => _materials;
  bool                get isLoading  => _isLoading;
  String?             get error      => _error;

  // Fetch all materials from server
  Future<void> fetchMaterials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/materials');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _materials = data.map((item) => MaterialModel.fromJson(item)).toList();
      } else {
        _error = ApiService.parseError(response);
      }
    } catch (e) {
      _error = 'Connection error: $e';
      debugPrint('fetchMaterials error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new material to server
  Future<bool> addMaterial(MaterialModel material) async {
    try {
      final response = await ApiService.post('/materials', material.toJson());
      if (response.statusCode == 201) {
        await fetchMaterials();
        return true;
      } else {
        _error = ApiService.parseError(response);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: $e';
      debugPrint('addMaterial error: $e');
      notifyListeners();
      return false;
    }
  }

  // Remove a material by its list index
  Future<bool> removeMaterial(int index) async {
    if (index < 0 || index >= _materials.length) return false;
    final id = _materials[index].id;
    if (id == null) return false;

    try {
      final response = await ApiService.delete('/materials/$id');
      if (response.statusCode == 200) {
        _materials.removeAt(index);
        notifyListeners();
        return true;
      } else {
        _error = ApiService.parseError(response);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: $e';
      debugPrint('removeMaterial error: $e');
      notifyListeners();
      return false;
    }
  }

  // Update an existing material by its list index
  Future<bool> updateExistingMaterial(int index, MaterialModel updated) async {
    if (index < 0 || index >= _materials.length) return false;
    final id = _materials[index].id;
    if (id == null) return false;

    try {
      final response = await ApiService.put('/materials/$id', updated.toJson());
      if (response.statusCode == 200) {
        await fetchMaterials();
        return true;
      } else {
        _error = ApiService.parseError(response);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: $e';
      debugPrint('updateExistingMaterial error: $e');
      notifyListeners();
      return false;
    }
  }

  // ── Deduct quantity from a material (used during production) ────────────────
  Future<void> deductMaterial(String name, double qtyToDeduct) async {
    try {
      final material = _materials.firstWhere(
        (m) => m.name.trim().toLowerCase() == name.trim().toLowerCase(),
      );
      if (material.id == null) return;

      final response = await ApiService.patch(
        '/materials/${material.id}/quantity',
        {'quantityChange': -qtyToDeduct},
      );

      if (response.statusCode == 200) {
        await fetchMaterials();
      } else {
        debugPrint('deductMaterial server error: ${response.body}');
      }
    } catch (e) {
      debugPrint('deductMaterial error: $e');
    }
  }

  // ── Helper: get all material names for dropdowns ─────────────────────────────
  List<String> getMaterialNames() => _materials.map((m) => m.name).toList();
}


// PROVIDER — Products Data

class ProductsData extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products  => _products;
  bool               get isLoading => _isLoading;
  String?            get error     => _error;

  // ── Fetch all products from server ───────────────────────────────────────────
  Future<void> fetchProducts({String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String endpoint = '/products';
      if (role != null) endpoint += '?role=$role';
      
      final response = await ApiService.get(endpoint);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _products = data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        _error = ApiService.parseError(response);
      }
    } catch (e) {
      _error = 'Connection error: $e';
      debugPrint('fetchProducts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Add a product (with optional image upload as multipart) ─────────────────
  Future<bool> addProduct(ProductModel product, {Function(int)? onTotalProductsUpdate}) async {
    try {
      final fields = {
        'name':             product.name,
        'quantity':         product.quantity,
        'price':            product.price,
        'includesMaterials': product.usedMaterials.isNotEmpty ? 'true' : 'false',
        'usedMaterials':    jsonEncode(product.usedMaterials),
      };

      if (product.costPrice != null && product.costPrice!.isNotEmpty) fields['costPrice'] = product.costPrice!;
      if (product.additionalExpenses != null && product.additionalExpenses!.isNotEmpty) fields['additionalExpenses'] = product.additionalExpenses!;
      if (product.profit != null && product.profit!.isNotEmpty) fields['profit'] = product.profit!;
      if (product.profitPercentage != null && product.profitPercentage!.isNotEmpty) fields['profitPercentage'] = product.profitPercentage!;

      File? imageFile;
      if (product.imagePath != null) {
        imageFile = File(product.imagePath!);
      }

      final streamedResponse = await ApiService.postMultipart(
        '/products',
        fields: fields,
        imageFile: imageFile,
        imageFieldName: 'image',
      );

      if (streamedResponse.statusCode == 201) {
        final responseBody = await streamedResponse.stream.bytesToString();
        final body = jsonDecode(responseBody);
        
        // Return updated total products for real-time fix
        if (onTotalProductsUpdate != null && body['totalProducts'] != null) {
          onTotalProductsUpdate(body['totalProducts']);
        }

        await fetchProducts(role: 'seller'); // Refresh with seller filter
        return true;
      } else {
        // Parse error from streamed response
        final responseBody = await streamedResponse.stream.bytesToString();
        try {
          final body = jsonDecode(responseBody);
          _error = body['message'] ?? 'Failed to add product';
        } catch (_) {
          _error = 'Failed to add product (${streamedResponse.statusCode})';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: $e';
      debugPrint('addProduct error: $e');
      notifyListeners();
      return false;
    }
  }

  // ── Remove a product by its MongoDB ID ──────────────────────────────────────
  Future<bool> removeProduct(String id) async {
    try {
      final response = await ApiService.delete('/products/$id');
      if (response.statusCode == 200) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      } else {
        _error = ApiService.parseError(response);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: $e';
      debugPrint('removeProduct error: $e');
      notifyListeners();
      return false;
    }
  }
}


// PROVIDER — User Data

class UserData extends ChangeNotifier {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get role => _userProfile?['role'] ?? 'customer';
  bool get hasSelectedRole => _userProfile?['hasSelectedRole'] ?? false;

  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? get analytics => _analytics;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/users/profile');
      if (response.statusCode == 200) {
        _userProfile = jsonDecode(response.body);
        if (_userProfile?['role'] == 'seller') {
          fetchAnalytics();
        }
      } else {
        _error = ApiService.parseError(response);
      }
    } catch (e) {
      _error = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnalytics() async {
    try {
      final response = await ApiService.get('/analytics/seller');
      if (response.statusCode == 200) {
        _analytics = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('fetchAnalytics error: $e');
    }
  }

  void updateAnalyticsDirectly(int totalProducts) {
    if (_analytics != null) {
      _analytics!['totalProducts'] = totalProducts;
      notifyListeners();
    }
  }

  Future<bool> setRole(String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/users/role', {'role': role});
      if (response.statusCode == 200) {
        _userProfile = jsonDecode(response.body);
        return true;
      } else {
        _error = ApiService.parseError(response);
        return false;
      }
    } catch (e) {
      _error = 'Connection error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


// PROVIDER — Orders Data

class OrderData extends ChangeNotifier {
  List<dynamic> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders(String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/orders?role=$role');
      if (response.statusCode == 200) {
        _orders = jsonDecode(response.body);
      } else {
        _error = ApiService.parseError(response);
      }
    } catch (e) {
      _error = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder(String productId, int quantity, String name) async {
    try {
      final response = await ApiService.post('/orders', {
        'productId': productId,
        'quantity': quantity,
        'customerName': name,
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await ApiService.put('/orders/$orderId/status', {'status': status});
      if (response.statusCode == 200) {
        final updatedOrder = jsonDecode(response.body);
        final index = _orders.indexWhere((o) => o['_id'] == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('updateOrderStatus error: $e');
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await ApiService.delete('/orders/$orderId');
      if (response.statusCode == 200) {
        _orders.removeWhere((o) => o['_id'] == orderId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('cancelOrder error: $e');
      return false;
    }
  }
}