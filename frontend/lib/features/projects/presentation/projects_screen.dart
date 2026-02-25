import 'package:flutter/material.dart';
import '../data/projects_service.dart';
import 'dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectsService _projectsService = ProjectsService();
  final TextEditingController _newProjectController = TextEditingController();

  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  bool _isCreating = false;

  String get _userId => Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final projects = await _projectsService.fetchProjects(_userId);
      setState(() {
        _projects = projects;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading projects: $e")),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _createProject() async {
    if (_newProjectController.text.trim().isEmpty) return;

    setState(() {
      _isCreating = true;
    });
    try {
      await _projectsService.createProject(_userId, _newProjectController.text.trim());
      _newProjectController.clear();
      await _loadProjects();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating project: $e")),
      );
    }
    setState(() {
      _isCreating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Projects"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Create New Project
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newProjectController,
                    decoration: const InputDecoration(
                      labelText: "New Project Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isCreating ? null : _createProject,
                  child: _isCreating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Create"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Projects List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _projects.isEmpty
                      ? const Center(child: Text("No projects yet!"))
                      : ListView.builder(
                          itemCount: _projects.length,
                          itemBuilder: (context, index) {
                            final project = _projects[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.folder, color: Colors.blue),
                                title: Text(project['project_name'] ?? "Untitled"),
                                subtitle: Text("Created at: ${project['created_at'] ?? '-'}"),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DashboardScreen(projectName: project['project_name']),
                                    ),
                                  );
                                },
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