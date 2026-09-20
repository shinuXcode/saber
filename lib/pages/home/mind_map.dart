import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:saber/data/file_manager/file_manager.dart';

class MindMapNode {
  MindMapNode({required this.id, required this.text, this.parentId});

  final String id;
  String text;
  String? parentId;

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'parentId': parentId};
  static MindMapNode fromJson(Map<String, dynamic> json) => MindMapNode(
    id: json['id'] as String,
    text: json['text'] as String,
    parentId: json['parentId'] as String?,
  );
}

class MindMapPage extends StatefulWidget {
  const MindMapPage({super.key});
  @override
  State<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends State<MindMapPage> {
  final nodes = <MindMapNode>[
    MindMapNode(id: 'root', text: 'Main idea'),
  ];
  final storagePath = '/_sadab_mind_map.json';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final file = FileManager.getFile(storagePath);
    if (!await file.exists()) return;
    try {
      final decoded = jsonDecode(await file.readAsString()) as List;
      final loaded = decoded.map((e) => MindMapNode.fromJson(e as Map<String, dynamic>)).toList();
      if (loaded.isNotEmpty && mounted) setState(() { nodes..clear()..addAll(loaded); });
    } catch (_) {}
  }

  Future<void> _save() async {
    final file = FileManager.getFile(storagePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(nodes.map((e) => e.toJson()).toList()));
  }

  Future<void> _addNode({String? parentId}) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add mind-map node'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Node')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.isEmpty) return;
    setState(() => nodes.add(MindMapNode(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      parentId: parentId ?? nodes.first.id,
    )));
    await _save();
  }

  Future<void> _rename(MindMapNode node) async {
    final controller = TextEditingController(text: node.text);
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename node'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.isEmpty) return;
    setState(() => node.text = text);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final children = <String, List<MindMapNode>>{};
    for (final node in nodes) {
      children.putIfAbsent(node.parentId ?? '', () => []).add(node);
    }

    Widget branch(MindMapNode node, {int depth = 0}) {
      final nodeChildren = children[node.id] ?? const <MindMapNode>[];
      return Padding(
        padding: EdgeInsets.only(left: depth * 28.0, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: Icon(depth == 0 ? Icons.hub : Icons.account_tree_outlined),
                title: Text(node.text),
                onTap: () => _rename(node),
                trailing: Wrap(
                  children: [
                    IconButton(onPressed: () => _addNode(parentId: node.id), icon: const Icon(Icons.add)),
                    IconButton(onPressed: node.id == 'root' ? null : () async {
                      setState(() => nodes.removeWhere((n) => n.id == node.id));
                      await _save();
                    }, icon: const Icon(Icons.delete_outline)),
                  ],
                ),
              ),
            ),
            for (final child in nodeChildren) branch(child, depth: depth + 1),
          ],
        ),
      );
    }

    final root = nodes.where((n) => n.parentId == null).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Map'),
        actions: [
          IconButton(onPressed: () => _addNode(), tooltip: 'Add node', icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Local-first mind map. Changes stay on this device.'),
          const SizedBox(height: 16),
          for (final node in root) branch(node),
        ],
      ),
    );
  }
}
