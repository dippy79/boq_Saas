import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchProjects(String userId) async {
    final response = await _client
        .from('projects')
        .select()
        .eq('user_id', userId)
        .execute();

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    final data = response.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> createProject(String userId, String projectName) async {
    final response = await _client.from('projects').insert({
      'user_id': userId,
      'project_name': projectName,
      'created_at': DateTime.now().toIso8601String(),
    }).execute();

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }
}