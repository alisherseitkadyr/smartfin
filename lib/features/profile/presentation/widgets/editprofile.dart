import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

// ── Edit profile bottom sheet ──────────────────────────────────
class EditProfileSheet extends StatefulWidget {
  final String name;
  final String email;
  const EditProfileSheet({super.key, required this.name, required this.email});

  @override
  State<EditProfileSheet> createState() => EditProfileSheetState();
}

class EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Edit profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text('Full name', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: const InputDecoration(hintText: 'Your name'),
            ),
            const SizedBox(height: 16),
            Text('Email', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              controller: TextEditingController(text: widget.email),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              decoration: const InputDecoration(
                hintText: 'Email cannot be changed',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


