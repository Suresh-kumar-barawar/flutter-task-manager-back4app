import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

const String kBack4AppApplicationId = String.fromEnvironment(
  'BACK4APP_APP_ID',
  defaultValue: 'yn8KRSfm9hvvLjE2AkcxEDCBnB9VO7YGozMDQfir',
);
const String kBack4AppClientKey = String.fromEnvironment(
  'BACK4APP_CLIENT_KEY',
  defaultValue: 'wjW2lTzc1WRMAjrPQICChEPGc8DnCi4RnAoWd3Ts',
);
const String kParseServerUrl = String.fromEnvironment(
  'PARSE_SERVER_URL',
  defaultValue: 'https://parseapi.back4app.com',
);
const String kLiveQueryUrl = String.fromEnvironment('PARSE_LIVE_QUERY_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Parse().initialize(
    kBack4AppApplicationId,
    kParseServerUrl,
    clientKey: kBack4AppClientKey,
    liveQueryUrl: kLiveQueryUrl.isEmpty ? null : kLiveQueryUrl,
    debug: false,
    appName: 'Task Manager Back4App',
    appVersion: '1.0.0',
    appPackageName: 'com.example.task_manager_back4app',
  );

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D6A),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF7F8F5),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE0E4DD)),
          ),
        ),
      ),
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late Future<ParseUser?> _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _loadUser();
  }

  Future<ParseUser?> _loadUser() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user?.sessionToken == null) {
      return null;
    }

    final response = await ParseUser.getCurrentUserFromServer(
      user!.sessionToken!,
    );
    return response?.success == true ? response!.result as ParseUser : null;
  }

  void _signedIn(ParseUser user) {
    setState(() {
      _currentUser = Future.value(user);
    });
  }

  void _signedOut() {
    setState(() {
      _currentUser = Future.value(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ParseUser?>(
      future: _currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return AuthScreen(onSignedIn: _signedIn);
        }

        return TaskHomeScreen(user: user, onSignedOut: _signedOut);
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onSignedIn});

  final ValueChanged<ParseUser> onSignedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isBusy = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isBusy = true);
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final user = ParseUser(email, password, email);
    final response = _isLogin ? await user.login() : await user.signUp();

    if (!mounted) {
      return;
    }

    setState(() => _isBusy = false);
    if (response.success) {
      widget.onSignedIn(response.result as ParseUser);
      return;
    }

    _showSnack(
      response.error?.message ?? 'Something went wrong. Please try again.',
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: isWide ? 5 : 0,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: isWide ? 36 : 0,
                        bottom: isWide ? 0 : 24,
                      ),
                      child: Column(
                        crossAxisAlignment: isWide
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 72,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Task Manager',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1F2925),
                            ),
                            textAlign: isWide
                                ? TextAlign.start
                                : TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Flutter CRUD app connected to Back4App for student login, cloud tasks, live updates, and secure logout.',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF52615B),
                            ),
                            textAlign: isWide
                                ? TextAlign.start
                                : TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: isWide ? 4 : 0,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isLogin ? 'Login' : 'Create account',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Student email',
                                  prefixIcon: Icon(Icons.alternate_email),
                                ),
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Enter your student email';
                                  }
                                  if (!text.contains('@') ||
                                      !text.contains('.')) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofillHints: const [AutofillHints.password],
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').length < 6) {
                                    return 'Use at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),
                              FilledButton.icon(
                                onPressed: _isBusy ? null : _submit,
                                icon: _isBusy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        _isLogin
                                            ? Icons.login
                                            : Icons.person_add_alt,
                                      ),
                                label: Text(_isLogin ? 'Login' : 'Register'),
                              ),
                              TextButton(
                                onPressed: _isBusy
                                    ? null
                                    : () => setState(() {
                                        _isLogin = !_isLogin;
                                      }),
                                child: Text(
                                  _isLogin
                                      ? 'Need an account? Register'
                                      : 'Already registered? Login',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TaskHomeScreen extends StatefulWidget {
  const TaskHomeScreen({
    super.key,
    required this.user,
    required this.onSignedOut,
  });

  final ParseUser user;
  final VoidCallback onSignedOut;

  @override
  State<TaskHomeScreen> createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  final List<ParseObject> _tasks = [];
  Timer? _refreshTimer;
  LiveQuery? _liveQuery;
  Subscription<ParseObject>? _subscription;
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _loadTasks(silent: true),
    );
    _startLiveQuery();
  }

  @override
  void dispose() {
    final subscription = _subscription;
    if (subscription != null) {
      _liveQuery?.client.unSubscribe(subscription);
    }
    _refreshTimer?.cancel();
    super.dispose();
  }

  QueryBuilder<ParseObject> _taskQuery() {
    return QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('owner', widget.user)
      ..orderByDescending('createdAt');
  }

  Future<void> _startLiveQuery() async {
    if (kLiveQueryUrl.isEmpty) {
      return;
    }

    try {
      _liveQuery = LiveQuery();
      final subscription = await _liveQuery!.client.subscribe(_taskQuery());
      _subscription = subscription;
      for (final event in LiveQueryEvent.values) {
        if (event != LiveQueryEvent.error) {
          subscription.on(event, (_) => _loadTasks(silent: true));
        }
      }
    } catch (_) {
      // Polling remains active when Live Query is not configured.
    }
  }

  Future<void> _loadTasks({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else if (mounted) {
      setState(() => _isSyncing = true);
    }

    final response = await _taskQuery().query();
    if (!mounted) {
      return;
    }

    if (response.success) {
      setState(() {
        _tasks
          ..clear()
          ..addAll((response.results ?? <ParseObject>[]).cast<ParseObject>());
        _isLoading = false;
        _isSyncing = false;
        _error = null;
      });
    } else {
      setState(() {
        _isLoading = false;
        _isSyncing = false;
        _error = response.error?.message ?? 'Unable to load tasks.';
      });
    }
  }

  Future<void> _saveTask({ParseObject? existingTask}) async {
    final result = await showDialog<TaskDraft>(
      context: context,
      builder: (_) => TaskEditorDialog(existingTask: existingTask),
    );

    if (result == null) {
      return;
    }

    final task = existingTask ?? ParseObject('Task');
    task
      ..set<String>('title', result.title)
      ..set<String>('description', result.description)
      ..set<bool>('isDone', existingTask?.get<bool>('isDone') ?? false)
      ..set<ParseUser>('owner', widget.user);

    if (existingTask == null && widget.user.objectId != null) {
      task.setACL(ParseACL(owner: widget.user));
    }

    final response = existingTask == null
        ? await task.create()
        : await task.save();
    if (!mounted) {
      return;
    }

    _showSnack(
      response.success
          ? existingTask == null
                ? 'Task created'
                : 'Task updated'
          : response.error?.message ?? 'Unable to save task.',
    );
    await _loadTasks(silent: true);
  }

  Future<void> _toggleDone(ParseObject task, bool done) async {
    task.set<bool>('isDone', done);
    final response = await task.save();
    if (!mounted) {
      return;
    }

    if (!response.success) {
      _showSnack(response.error?.message ?? 'Unable to update task.');
    }
    await _loadTasks(silent: true);
  }

  Future<void> _deleteTask(ParseObject task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
          'This will remove "${task.get<String>('title') ?? 'this task'}" from Back4App.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final response = await task.delete();
    if (!mounted) {
      return;
    }

    _showSnack(
      response.success
          ? 'Task deleted'
          : response.error?.message ?? 'Unable to delete task.',
    );
    await _loadTasks(silent: true);
  }

  Future<void> _logout() async {
    await widget.user.logout();
    if (mounted) {
      widget.onSignedOut();
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pending = _tasks
        .where((task) => task.get<bool>('isDone') != true)
        .length;
    final completed = _tasks.length - pending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _loadTasks(),
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveTask(),
        icon: const Icon(Icons.add_task),
        label: const Text('Add task'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.emailAddress ??
                          widget.user.username ??
                          'Student',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF52615B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        StatTile(
                          icon: Icons.list_alt,
                          label: 'Total',
                          value: _tasks.length.toString(),
                        ),
                        StatTile(
                          icon: Icons.radio_button_unchecked,
                          label: 'Pending',
                          value: pending.toString(),
                        ),
                        StatTile(
                          icon: Icons.check_circle_outline,
                          label: 'Done',
                          value: completed.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                ),
              )
            else if (_tasks.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No tasks yet. Tap Add task to create your first one.',
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                sliver: SliverList.separated(
                  itemCount: _tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return TaskTile(
                      task: task,
                      onChanged: (done) => _toggleDone(task, done ?? false),
                      onEdit: () => _saveTask(existingTask: task),
                      onDelete: () => _deleteTask(task),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(label, style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final ParseObject task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = task.get<String>('title') ?? 'Untitled task';
    final description = task.get<String>('description') ?? '';
    final isDone = task.get<bool>('isDone') ?? false;
    final createdAt = task.createdAt;
    final dateText = createdAt == null
        ? ''
        : DateFormat('dd MMM, h:mm a').format(createdAt.toLocal());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: isDone, onChanged: onChanged),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF52615B),
                      ),
                    ),
                  ],
                  if (dateText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(dateText, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskDraft {
  const TaskDraft({required this.title, required this.description});

  final String title;
  final String description;
}

class TaskEditorDialog extends StatefulWidget {
  const TaskEditorDialog({super.key, this.existingTask});

  final ParseObject? existingTask;

  @override
  State<TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<TaskEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingTask?.get<String>('title') ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTask?.get<String>('description') ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      TaskDraft(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit task' : 'Add task'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Enter a task title'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: Icon(isEditing ? Icons.save_outlined : Icons.add),
          label: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
