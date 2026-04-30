import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habitx/providers/task_provider.dart';
import 'package:habitx/widgets/task_item.dart';
import '../../../utils/theme_constants.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Scaffold(
          backgroundColor: ThemeConstants.backgroundPrimary,
          appBar: AppBar(
            title: Text('Calendar',
                style: ThemeConstants.headingStyle.copyWith(
                  color: ThemeConstants.textSecondary,
                )),
            backgroundColor: ThemeConstants.primaryBlack,
            elevation: 0,
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: taskProvider.focusedDay,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) =>
                      taskProvider.isSameDay(taskProvider.selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    taskProvider.updateSelectedDay(selectedDay, focusedDay);
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: ThemeConstants.primaryBlack,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: ThemeConstants.primaryYellow.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: ThemeConstants.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Tasks for this day',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: taskProvider.currentTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available_outlined,
                              size: 64,
                              color: Colors.black.withOpacity(0.1),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No tasks scheduled for this day',
                              style: TextStyle(color: Colors.black38),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: taskProvider.currentTasks.length,
                        itemBuilder: (context, index) {
                          final task = taskProvider.currentTasks[index];
                          return TaskItem(
                            task: task,
                            onToggle: (_) =>
                                taskProvider.toggleTaskCompletion(task.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
