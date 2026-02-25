import 'package:flutter/material.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(projectName),
      ),
      body: Center(
        child: Text(
          "Project ID: $projectId",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
