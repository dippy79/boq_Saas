import 'package:supabase_flutter/supabase_flutter.dart';

class BoqService {
  final _client = Supabase.instance.client;

  Future<void> addItem({
    required String projectId,
    required String name,
    String? description,
    required double quantity,
    required double rate,
  }) async {
    await _client.from('boq_items').insert({
      'project_id': projectId,
      'item_name': name,
      'description': description,
      'quantity': quantity,
      'rate': rate,
    });
  }

  Future<List<Map<String, dynamic>>> fetchItems(String projectId) async {
    final response = await _client
        .from('boq_items')
        .select()
        .eq('project_id', projectId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteItem(String id) async {
    await _client.from('boq_items').delete().eq('id', id);
  }
}
