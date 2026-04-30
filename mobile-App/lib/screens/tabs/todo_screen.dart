import 'package:flutter/material.dart';
import 'package:habitx/providers/task_provider.dart';
import 'package:habitx/utils/theme_constants.dart';
import 'package:habitx/widgets/task_item.dart';
import 'package:habitx/widgets/habit_item.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showCalendarDialog(BuildContext context, TaskProvider taskProvider) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5 * anim1.value, sigmaY: 5 * anim1.value),
          child: ScaleTransition(
            scale: anim1,
            child: FadeTransition(
              opacity: anim1,
              child: Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: taskProvider.focusedDay,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) =>
                        taskProvider.isSameDay(taskProvider.selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      taskProvider.updateSelectedDay(selectedDay, focusedDay);
                      Navigator.pop(context);
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: ThemeConstants.primaryBlack,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: ThemeConstants.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final double progress = _calculateProgress(taskProvider);
        final weekDays = taskProvider.getWeekDays();

        return Scaffold(
          backgroundColor: ThemeConstants.backgroundPrimary,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(context, taskProvider, progress),
                const SizedBox(height: 20),
                _buildWeekStrip(taskProvider, weekDays),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildTaskList(context, taskProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calculateProgress(TaskProvider provider) {
    final tasks = provider.currentTasks;
    final habits = provider.habits;
    if (tasks.isEmpty && habits.isEmpty) return 0.0;
    
    int completed = tasks.where((t) => t.isCompleted).length;
    completed += habits.where((h) => provider.isHabitCompleted(h.id, provider.selectedDay)).length;
    
    return completed / (tasks.length + habits.length);
  }

  Widget _buildHeader(BuildContext context, TaskProvider provider, double progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showCalendarDialog(context, provider),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(provider.selectedDay),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  provider.isSameDay(provider.selectedDay, DateTime.now()) 
                      ? 'Today' 
                      : DateFormat('EEEE, d').format(provider.selectedDay),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.primaryBlack,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: ThemeConstants.primaryBlack.withOpacity(0.05),
                  valueColor: const AlwaysStoppedAnimation<Color>(ThemeConstants.primaryBlack),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip(TaskProvider provider, List<Map<String, String>> days) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final isSelected = days[index]['isSelected'] == 'true';
          final isToday = days[index]['isToday'] == 'true';
          
          return GestureDetector(
            onTap: () {
              final weekStart = provider.focusedDay.subtract(
                Duration(days: provider.focusedDay.weekday - 1),
              );
              final selectedDate = weekStart.add(Duration(days: index));
              provider.updateSelectedDay(selectedDate, selectedDate);
              _animationController.forward(from: 0.0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? ThemeConstants.primaryBlack : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isToday && !isSelected
                    ? Border.all(color: ThemeConstants.primaryBlack, width: 1.5)
                    : isSelected ? null : Border.all(color: Colors.black12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index]['day']![0], // Single letter day
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.black38,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index]['date']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : ThemeConstants.primaryBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, TaskProvider provider) {
    if (provider.currentTasks.isEmpty && provider.habits.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (provider.habits.isNotEmpty) ...[
                _buildSectionTitle('Daily Habits'),
                ...provider.habits.map((habit) => HabitItem(
                  habit: habit,
                  isCompleted: provider.isHabitCompleted(habit.id, provider.selectedDay),
                  onToggle: (_) => provider.toggleHabitCompletion(habit.id, provider.selectedDay),
                )),
                const SizedBox(height: 32),
              ],
              if (provider.currentTasks.isNotEmpty) ...[
                _buildSectionTitle("Today's Tasks"),
                ...provider.currentTasks.map((task) => TaskItem(
                  task: task,
                  onToggle: (_) => provider.toggleTaskCompletion(task.id),
                )),
              ],
              const SizedBox(height: 80), // Space for bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: ThemeConstants.primaryBlack.withOpacity(0.4),
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 60,
              color: ThemeConstants.primaryYellow,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'All Caught Up!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeConstants.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Time to relax and recharge.',
            style: TextStyle(
              fontSize: 16,
              color: ThemeConstants.primaryBlack.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
