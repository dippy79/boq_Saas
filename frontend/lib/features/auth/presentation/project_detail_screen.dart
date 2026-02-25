import 'package:flutter/material.dart';
import '../data/project_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final ProjectService _projectService = ProjectService();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final data = await _projectService.fetchProjectItems(widget.projectId);
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addItem() async {
    final name = _itemNameController.text.trim();
    final quantity = _quantityController.text.trim();
    final unit = _unitController.text.trim();
    final rate = _rateController.text.trim();

    if (name.isEmpty || quantity.isEmpty) return;

    await _projectService.addProjectItem(widget.projectId, {
      'name': name,
      'quantity': double.tryParse(quantity) ?? 0,
      'unit': unit,
      'rate': double.tryParse(rate) ?? 0,
    });

    _itemNameController.clear();
    _quantityController.clear();
    _unitController.clear();
    _rateController.clear();

    Navigator.pop(context);
    _loadItems();
  }

  Future<void> _deleteItem(int itemId) async {
    await _projectService.deleteProjectItem(itemId);
    _loadItems();
  }

  double get _totalAmount {
    double total = 0;
    for (var item in _items) {
      final quantity = (item['quantity'] ?? 0).toDouble();
      final rate = (item['rate'] ?? 0).toDouble();
      total += quantity * rate;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Amount Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "₹${_totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Add Item Button
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Add Item"),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _itemNameController,
                            decoration: const InputDecoration(
                              labelText: "Item Name",
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Quantity",
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              labelText: "Unit (e.g., sqft, pcs)",
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _rateController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Rate (₹)",
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: _addItem,
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
            ),
            const SizedBox(height: 30),
            const Text(
              "Project Items",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Items List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? const Center(child: Text("No items yet"))
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final total = ((item['quantity'] ?? 0).toDouble() *
                                    (item['rate'] ?? 0).toDouble())
                                .toStringAsFixed(2);
                            return Card(
                              child: ListTile(
                                title: Text(
                                  item['name'] ?? '',
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  "Qty: ${item['quantity']} ${item['unit']} × ₹${item['rate']} = ₹$total",
                                  softWrap: true,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteItem(item['id']),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
