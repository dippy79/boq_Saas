import 'package:flutter/material.dart';
import '../../auth/data/auth_service.dart';
import '../../boq/presentation/boq_screen.dart';
import '../data/projects_service.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final AuthService _authService = AuthService();
  final ProjectsService _projectsService = ProjectsService();

  bool _isLoading = false;
  List<Map<String, dynamic>> _projects = [];

  final TextEditingController _projectNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return;

      final projects = await _projectsService.fetchProjects(userId);
      setState(() => _projects = projects);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching projects: $e"), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createProject() async {
    final name = _projectNameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return;

      await _projectsService.createProject(userId, name);
      _projectNameController.clear();
      await _fetchProjects();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating project: $e"), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  void _openProject(Map<String, dynamic> project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BoqScreen(
          projectId: project['id'].toString(),
          projectName: project['project_name'] ?? 'Project',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Projects"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Create new project
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _projectNameController,
                    decoration: const InputDecoration(
                      labelText: "New Project Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createProject,
                  child: const Text("Create"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Projects list
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _projects.isEmpty
                    ? const Center(child: Text("No projects found."))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _projects.length,
                          itemBuilder: (context, index) {
                            final project = _projects[index];
                            return Card(
                              child: ListTile(
                                title: Text(project['project_name'] ?? 'Project'),
                                subtitle: Text("ID: ${project['id']}"),
                                onTap: () => _openProject(project),
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
