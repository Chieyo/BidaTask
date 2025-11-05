import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/task.dart';
import '../../../domain/enums/task_status.dart';
import '../../core/utils/date_utils.dart' as date_utils;

class TaskForm extends StatefulWidget {
  final Task? initialTask;
  final Function(Task) onSubmit;
  final VoidCallback onCancel;

  const TaskForm({
    Key? key,
    this.initialTask,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assignedToController;
  late DateTime? _selectedDate;
  late Task? _editingTask;

  @override
  void initState() {
    super.initState();
    _editingTask = widget.initialTask;
    _titleController = TextEditingController(text: _editingTask?.title ?? '');
    _descriptionController = TextEditingController(text: _editingTask?.description ?? '');
    _assignedToController = TextEditingController(text: _editingTask?.assignedTo ?? '');
    _selectedDate = _editingTask?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date and time')),
      );
      return;
    }

    final task = Task(
      id: _editingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      author: _editingTask?.author ?? 'You',
      dueDate: _selectedDate!,
      status: _editingTask?.status ?? TaskStatus.notStarted,
      isPostedByMe: true,
      assignedTo: _assignedToController.text.isNotEmpty ? _assignedToController.text : null,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
    );

    widget.onSubmit(task);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editingTask == null ? 'Add New Task' : 'Edit Task',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _assignedToController,
                decoration: const InputDecoration(
                  labelText: 'Assign To (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Due Date & Time *'
                      : 'Due: ${date_utils.formatDate(_selectedDate!)} ${date_utils.formatTime(_selectedDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context),
                tileColor: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[300]!), 
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(_editingTask == null ? 'ADD TASK' : 'SAVE CHANGES'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
