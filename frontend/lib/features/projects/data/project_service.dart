import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Create a new project with authenticated user_id
  /// Throws meaningful errors for handling
  Future<void> createProject(String name) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not authenticated. Please login first.");
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception("Project name cannot be empty");
    }

    try {
      final response = await _supabase.from('projects').insert({
        'name': trimmedName,
        'user_id': user.id,
      }).select();

      if (response.isEmpty) {
        throw Exception("Failed to create project. Please try again.");
      }
    } on PostgrestException catch (e) {
      throw Exception("Database error: ${e.message}");
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all projects for the authenticated user
  /// Orders by created_at descending
  Future<List<Map<String, dynamic>>> fetchProjects() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception("Failed to fetch projects: ${e.message}");
    }
  }

  /// Get real-time stream of projects for the authenticated user
  Stream<List<Map<String, dynamic>>> watchProjects() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return Stream.error('User not authenticated');
    }

    return _supabase
        .from('projects')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Fetch all items for a specific project
  Future<List<Map<String, dynamic>>> fetchProjectItems(String projectId) async {
    if (projectId.isEmpty) {
      throw Exception("Invalid project ID");
    }

    try {
      final response = await _supabase
          .from('project_items')
          .select()
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception("Failed to fetch items: ${e.message}");
    }
  }

  /// Get real-time stream of project items
  Stream<List<Map<String, dynamic>>> watchProjectItems(String projectId) {
    if (projectId.isEmpty) {
      return Stream.error('Invalid project ID');
    }

    return _supabase
        .from('project_items')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Add a new item to a project
  Future<void> addProjectItem(String projectId, Map<String, dynamic> item) async {
    if (projectId.isEmpty) {
      throw Exception("Invalid project ID");
    }

    final name = (item['name'] as String?)?.trim();
    if (name == null || name.isEmpty) {
      throw Exception("Item name cannot be empty");
    }

    try {
      await _supabase.from('project_items').insert({
        'project_id': projectId,
        'name': name,
        'quantity': item['quantity'] ?? 0,
        'unit': item['unit'] ?? '',
        'rate': item['rate'] ?? 0,
      });
    } on PostgrestException catch (e) {
      throw Exception("Failed to add item: ${e.message}");
    }
  }

  /// Delete an item from a project
  Future<void> deleteProjectItem(int itemId) async {
    if (itemId <= 0) {
      throw Exception("Invalid item ID");
    }

    try {
      await _supabase
          .from('project_items')
          .delete()
          .eq('id', itemId);
    } on PostgrestException catch (e) {
      throw Exception("Failed to delete item: ${e.message}");
    }
  }
}

