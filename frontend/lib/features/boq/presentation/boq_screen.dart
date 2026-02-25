import 'package:flutter/material.dart';
import '../data/boq_service.dart';

class BoqScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const BoqScreen({super.key, required this.projectId, required this.projectName});

  @override
  State<BoqScreen> createState() => _BoqScreenState();
}

class _BoqScreenState extends State<BoqScreen> {
  final BoqService _boqService = BoqService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  // Controllers for add item form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _boqService.fetchItems(widget.projectId);
      setState(() {
        _items = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching items: $e"), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  double get total {
    double sum = 0;
    for (var item in _items) {
      final qty = item['quantity'] ?? 0;
      final rate = item['rate'] ?? 0;
      sum += qty * rate;
    }
    return sum;
  }

  Future<void> _addItem() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final qty = double.tryParse(_qtyController.text.trim()) ?? 0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0;

    if (name.isEmpty || qty <= 0 || rate <= 0) return;

    try {
      await _boqService.addItem(
        projectId: widget.projectId,
        name: name,
        description: desc,
        quantity: qty,
        rate: rate,
      );
      _nameController.clear();
      _descController.clear();
      _qtyController.clear();
      _rateController.clear();
      await _fetchItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding item: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      await _boqService.deleteItem(id);
      await _fetchItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting item: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Add item form
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Item Name"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _qtyController,
                          decoration: const InputDecoration(labelText: "Quantity"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _rateController,
                          decoration: const InputDecoration(labelText: "Rate"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _addItem,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                    child: const Text("Add Item"),
                  ),
                  const SizedBox(height: 20),

                  // Item list
                  Expanded(
                    child: _items.isEmpty
                        ? const Center(child: Text("No items added yet."))
                        : ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                child: ListTile(
                                  title: Text(item['item_name'] ?? ''),
                                  subtitle: Text("Qty: ${item['quantity']} x Rate: ${item['rate']}"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteItem(item['id'].toString()),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Total
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "Total: $total",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
