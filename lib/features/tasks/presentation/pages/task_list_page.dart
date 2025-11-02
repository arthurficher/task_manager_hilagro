import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_hilagro/features/splash/presentation/widgets/title_task.dart';
import 'package:task_manager_hilagro/features/tasks/domain/entities/task.dart';
import 'package:task_manager_hilagro/features/tasks/presentation/providers/task_provider.dart';
import 'package:task_manager_hilagro/features/auth/presentation/providers/auth_provider.dart' as custom_auth;
import 'package:uuid/uuid.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  int count = 0;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<custom_auth.AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        print('Inicializando TaskProvider con usuario: ${authProvider.currentUser!.uid}');
        taskProvider.setCurrentUser(authProvider.currentUser!.uid);
      } else {
        print('Usuario no encontrado en AuthProvider');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    
    return Consumer2<TaskProvider, custom_auth.AuthProvider>(
      builder: (context, taskProvider, authProvider, _) {
        if (authProvider.currentUser != null && taskProvider.currentUserId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            taskProvider.setCurrentUser(authProvider.currentUser!.uid);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mis Tareas'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Total: ${taskProvider.taskList.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(height: height, width: width, taskProvider: taskProvider),
                Expanded(
                    child: _TaskList(
                  height: height,
                  width: width,
                )),
              ],
            ),
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showNewTaskModal(context, height, width),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          ),
        );
      },
    );
  }

  void _showNewTaskModal(BuildContext context, double height, double width) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _NewTaskModal(
          height: height,
          width: width,
          uuid: _uuid,
        ),
      ),
    );
  }
}

class _NewTaskModal extends StatelessWidget {
  _NewTaskModal({
    required this.width,
    required this.height,
    required this.uuid,
    this.onTaskCreated,
  });

  final _controller = TextEditingController();
  final void Function(Task task)? onTaskCreated;
  final double width;
  final double height;
  final Uuid uuid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.032,
        vertical: height * 0.023,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(width * 0.04)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const TitleTask(text: 'Nueva Tarea'),
          SizedBox(height: height * 0.026),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(width * 0.016)),
                hintText: 'Descripción de la Tarea'),
          ),
          SizedBox(height: height * 0.026),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  context.read<TaskProvider>().addNewTask(_controller.text.trim());
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tarea "${_controller.text.trim()}" agregada'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.035, vertical: height * 0.030),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleTask(
            text: 'Tareas',
          ),
          Expanded(child: Consumer<TaskProvider>(
            builder: (_, provider, __) {
              print('TaskProvider Debug:');
              print('- Current User ID: ${provider.currentUserId}');
              print('- Total tasks in list: ${provider.taskList.length}');
              print('- Filtered tasks: ${provider.taskList.length}');
              print('- Pending tasks: ${provider.pendingTasks.length}');
              print('- Completed tasks: ${provider.completedTasks.length}');
              
              final completedTasks = provider.completedTasks;
              final pendingTasks = provider.pendingTasks;

              if (provider.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando tareas...'),
                    ],
                  ),
                );
              }

              if (provider.taskList.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay tareas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Presiona + para agregar una nueva tarea',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Sección de Tareas Pendientes
                    if (pendingTasks.isNotEmpty) ...[
                      SizedBox(height: height * 0.02),
                      const Center(child: TitleTask(text: 'Pendientes')),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, index) => _buildDismissibleTask(
                          context, 
                          pendingTasks[index], 
                          provider
                        ),
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemCount: pendingTasks.length,
                      ),
                    ],
                    
                    // Sección de Tareas Completadas
                    if (completedTasks.isNotEmpty) ...[
                      SizedBox(height: height * 0.03),
                      const Center(child: TitleTask(text: 'Completadas')),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, index) => _buildDismissibleTask(
                          context, 
                          completedTasks[index], 
                          provider
                        ),
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemCount: completedTasks.length,
                      ),
                    ],
                    
                    if (pendingTasks.isEmpty && completedTasks.isNotEmpty) 
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Center(
                          child: Text(
                            '¡Felicidades! No tienes tareas pendientes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.height,
    required this.width,
    required this.taskProvider,
  });

  final double height;
  final double width;
  final TaskProvider taskProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: height * 0.04,
          top: height * 0.02,
        ),
        child: Column(
          children: [
            const TitleTask(
              text: 'Completa tus tareas',
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              'Pendientes: ${taskProvider.pendingTasks.length} | Completadas: ${taskProvider.completedTasks.length}',
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
}

Widget _buildDismissibleTask(BuildContext context, Task task, TaskProvider provider) {
  return Dismissible(
    key: Key(task.id.toString()),
    direction: DismissDirection.endToStart,
    background: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(21),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 30),
          SizedBox(height: 4),
          Text(
            'Eliminar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    confirmDismiss: (direction) async {
      return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Estás seguro de eliminar "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    },
    onDismissed: (_) {
      provider.removeTask(task);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarea "${task.title}" eliminada'),
          duration: const Duration(seconds: 2),
        ),
      );
    },
    child: _TaskItem(
      task,
      onTap: () => provider.onTaskDoneChange(task),
    ),
  );
}

class _TaskItem extends StatelessWidget {
  const _TaskItem(this.task, {this.onTap});
  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            color: task.done ? Colors.grey.shade100 : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                Icon(
                  task.done
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank,
                  color: task.done
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: task.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.done ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
