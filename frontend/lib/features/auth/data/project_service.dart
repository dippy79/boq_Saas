import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchProjects() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('projects')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createProject(String name) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('projects').insert({
      'name': name,
      'user_id': user.id,
    });
  }

  Future<List<Map<String, dynamic>>> fetchProjectItems(String projectId) async {
    final response = await _supabase
        .from('project_items')
        .select('*')
        .eq('project_id', projectId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addProjectItem(String projectId, Map<String, dynamic> item) async {
    await _supabase.from('project_items').insert({
      ...item,
      'project_id': projectId,
    });
  }

  Future<void> deleteProjectItem(int itemId) async {
    await _supabase.from('project_items').delete().eq('id', itemId);
  }
}
