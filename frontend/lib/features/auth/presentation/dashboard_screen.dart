import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/project_service.dart';
import 'project_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ProjectService _projectService = ProjectService();
  final TextEditingController _projectController = TextEditingController();

  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final data = await _projectService.fetchProjects();
      setState(() {
        _projects = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createProject() async {
    final name = _projectController.text.trim();
    if (name.isEmpty) return;

    await _projectService.createProject(name);
    _projectController.clear();
    Navigator.pop(context);
    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("BOQ SaaS Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome ${user?.email ?? ""}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Create Project"),
                    content: TextField(
                      controller: _projectController,
                      decoration: const InputDecoration(
                        labelText: "Project Name",
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: _createProject,
                        child: const Text("Create"),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Create New Project"),
            ),

            const SizedBox(height: 30),

            const Text(
              "Your Projects",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _projects.isEmpty
                      ? const Center(child: Text("No projects yet"))
                      : ListView.builder(
                          itemCount: _projects.length,
                          itemBuilder: (context, index) {
                            final project = _projects[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  project['name'] ?? '',
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  project['created_at']?.toString() ?? '',
                                  softWrap: true,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProjectDetailScreen(
                                        projectId: project['id'],
                                        projectName: project['name'] ?? '',
                                      ),
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