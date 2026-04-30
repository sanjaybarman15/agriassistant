import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitx/utils/persistence_service.dart';
import 'package:habitx/providers/user_provider.dart';
import 'package:habitx/providers/task_provider.dart';
import 'package:habitx/providers/blog_provider.dart';
import 'package:habitx/utils/theme_constants.dart';
import 'package:habitx/config/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistenceService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => BlogProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return MaterialApp.router(
      title: 'HabitX',
      theme: ThemeConstants.lightTheme,
      darkTheme: ThemeData.dark(), // Basic dark theme for now
      themeMode: userProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
