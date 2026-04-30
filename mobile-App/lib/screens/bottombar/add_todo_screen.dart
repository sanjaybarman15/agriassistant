import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitx/providers/task_provider.dart';
import '../../../utils/theme_constants.dart';
import 'package:intl/intl.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({Key? key}) : super(key: key);

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isHabit = true;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ThemeConstants.primaryBlack,
              onPrimary: Colors.white,
              onSurface: ThemeConstants.primaryBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ThemeConstants.primaryBlack,
              onPrimary: Colors.white,
              onSurface: ThemeConstants.primaryBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _createItem() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final String? timeString = _selectedTime != null 
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : null;
    
    if (_isHabit) {
      taskProvider.addHabit(
        _titleController.text, 
        _descriptionController.text,
        time: timeString,
      );
    } else {
      taskProvider.addTask(
        _titleController.text, 
        _descriptionController.text,
        date: DateFormat('yyyy-M-d').format(_selectedDate),
        time: timeString,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_isHabit ? 'Habit' : 'Task'} created successfully!')),
    );

    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedTime = null;
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundPrimary,
      appBar: AppBar(
        title: Text('Add Item',
            style: ThemeConstants.headingStyle.copyWith(
              color: ThemeConstants.textSecondary,
            )),
        backgroundColor: ThemeConstants.primaryBlack,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What do you want to track?',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Toggle Section
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ThemeConstants.primaryBlack.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isHabit = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isHabit ? ThemeConstants.primaryBlack : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Habit',
                            style: TextStyle(
                              color: _isHabit ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isHabit = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isHabit ? ThemeConstants.primaryBlack : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Task',
                            style: TextStyle(
                              color: !_isHabit ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            _buildLabel('Title'),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('e.g., Morning Run'),
            ),
            
            const SizedBox(height: 24),
            
            _buildLabel('Description (Optional)'),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: _inputDecoration('Describe your goal...'),
            ),
            
            const SizedBox(height: 24),

            Row(
              children: [
                if (!_isHabit) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Date'),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ThemeConstants.primaryBlack.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20, color: Colors.black54),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM d, yyyy').format(_selectedDate),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Time'),
                      InkWell(
                        onTap: () => _selectTime(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ThemeConstants.primaryBlack.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 20, color: Colors.black54),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTime?.format(context) ?? 'Set Time',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _createItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryBlack,
                  foregroundColor: ThemeConstants.primaryWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isHabit ? 'Create Habit' : 'Create Task',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26),
      filled: true,
      fillColor: ThemeConstants.primaryBlack.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(20),
    );
  }
}
