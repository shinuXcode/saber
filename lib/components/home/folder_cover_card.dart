import 'package:flutter/material.dart';

class FolderCoverCard extends StatelessWidget {
  const FolderCoverCard({
    super.key,
    required this.folderName,
    required this.path,
    required this.folderCount,
    required this.noteCount,
    required this.onCreateFolder,
    required this.onCreateNote,
  });

  final String folderName;
  final String path;
  final int folderCount;
  final int noteCount;
  final VoidCallback onCreateFolder;
  final VoidCallback onCreateNote;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [scheme.primaryContainer, scheme.surfaceContainerHighest]
                  : [scheme.primaryContainer, scheme.surfaceContainerLow],
            ),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 8),
                color: scheme.shadow.withValues(alpha: 0.10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 32,
                        color: scheme.primary,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: 'Folder actions',
                      onSelected: (value) {
                        if (value == 'folder') onCreateFolder();
                        if (value == 'note') onCreateNote();
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'folder',
                          child: ListTile(
                            leading: Icon(Icons.create_new_folder),
                            title: Text('New nested folder'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'note',
                          child: ListTile(
                            leading: Icon(Icons.note_add),
                            title: Text('New note'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  folderName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatChip(
                      icon: Icons.folder_copy_outlined,
                      label: '$folderCount nested folder${folderCount == 1 ? '' : 's'}',
                    ),
                    _StatChip(
                      icon: Icons.description_outlined,
                      label: '$noteCount note${noteCount == 1 ? '' : 's'}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18, color: scheme.primary),
      label: Text(label),
      side: BorderSide(color: scheme.outlineVariant),
    );
  }
}
