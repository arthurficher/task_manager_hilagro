import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_hilagro/features/auth/presentation/providers/auth_provider.dart' as custom_auth;
import 'package:task_manager_hilagro/features/tasks/presentation/providers/task_provider.dart';
import 'package:task_manager_hilagro/features/auth/presentation/pages/login_page.dart';
import 'package:task_manager_hilagro/features/tasks/domain/entities/task.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<custom_auth.AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        taskProvider.setCurrentUser(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: const Color(0xFF40B7AD),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Consumer2<custom_auth.AuthProvider, TaskProvider>(
        builder: (context, authProvider, taskProvider, _) {
          if (authProvider.status == custom_auth.AuthStatus.unauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(authProvider),
                const SizedBox(height: 20),
                _buildStatsCard(taskProvider),
                const SizedBox(height: 20),
                _buildTodayTasksSection(taskProvider),
                const SizedBox(height: 20),
                _buildWeekTasksSection(taskProvider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: const Color(0xFF40B7AD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWelcomeCard(custom_auth.AuthProvider authProvider) {
    final now = DateTime.now();
    final timeOfDay = now.hour < 12 ? 'Buenos días' : 
                     now.hour < 18 ? 'Buenas tardes' : 'Buenas noches';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF40B7AD), Color(0xFF2E8B7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeOfDay,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              authProvider.currentUser?.email?.split('@')[0] ?? 'Usuario',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(now),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'es');
      return formatter.format(date);
    } catch (e) {
      try {
        final fallbackFormatter = DateFormat('EEEE, d MMMM yyyy');
        return fallbackFormatter.format(date);
      } catch (e2) {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    try {
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDatePicker(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildStatsCard(TaskProvider taskProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Hoy',
                    taskProvider.todayTasks.length.toString(),
                    Colors.blue,
                    Icons.today,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Esta semana',
                    taskProvider.weekTasks.length.toString(),
                    Colors.orange,
                    Icons.date_range,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Completadas',
                    taskProvider.completedTasks.length.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTodayTasksSection(TaskProvider taskProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tareas de Hoy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${taskProvider.todayTasks.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            taskProvider.todayTasks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No hay tareas para hoy',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: taskProvider.todayTasks.length > 3 ? 3 : taskProvider.todayTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = taskProvider.todayTasks[index];
                      return _buildTaskItem(task, taskProvider);
                    },
                  ),
            if (taskProvider.todayTasks.length > 3)
              TextButton(
                onPressed: () {},
                child: Text('Ver todas (${taskProvider.todayTasks.length})'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekTasksSection(TaskProvider taskProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tareas de la Semana',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${taskProvider.weekTasks.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            taskProvider.weekTasks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No hay tareas para esta semana',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: taskProvider.weekTasks.length > 5 ? 5 : taskProvider.weekTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = taskProvider.weekTasks[index];
                      return _buildTaskItem(task, taskProvider);
                    },
                  ),
            if (taskProvider.weekTasks.length > 5)
              TextButton(
                onPressed: () {},
                child: Text('Ver todas (${taskProvider.weekTasks.length})'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task, TaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: task.done ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.done ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => taskProvider.onTaskDoneChange(task),
            child: Icon(
              task.done ? Icons.check_circle : Icons.circle_outlined,
              color: task.done ? Colors.green : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: task.done ? TextDecoration.lineThrough : null,
                    color: task.done ? Colors.grey : Colors.black87,
                  ),
                ),
                if (task.dueDate != null)
                  Text(
                    _formatTime(task.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nueva Tarea'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(_formatDatePicker(selectedDate)),
                      leading: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      Provider.of<TaskProvider>(context, listen: false)
                          .addNewTask(
                            titleController.text.trim(), 
                            descriptionController.text.trim(),
                            selectedDate,
                          );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF40B7AD),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    final authProvider = Provider.of<custom_auth.AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                taskProvider.clearTasks();
                authProvider.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}