import 'package:flutter/material.dart';
import '../../../../core/models/section_model.dart';

class SectionFormDialog extends StatefulWidget {
  final SectionModel? section; // null for adding, provided for editing

  const SectionFormDialog({
    super.key,
    this.section,
  });

  @override
  State<SectionFormDialog> createState() => _SectionFormDialogState();
}

class _SectionFormDialogState extends State<SectionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.section != null) {
      _nameController.text = widget.section!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.section != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Section' : 'Add Section'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Section Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a section name';
            }
            return null;
          },
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final sectionData = {
      'name': _nameController.text.trim(),
    };

    Navigator.of(context).pop(sectionData);
  }
} 