import 'package:expensely_app/Screens/HomeScreen.dart';
import 'package:expensely_app/Screens/Welcome_Screen.dart';
import 'package:expensely_app/bloc/expense_bloc.dart';
import 'package:expensely_app/bloc/expense_event.dart';
import 'package:expensely_app/models/category_model.dart';
import 'package:expensely_app/models/transaction.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hive_flutter/adapters.dart';

import 'services/shared_prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryModelAdapter()); 
  await Hive.openBox<Transaction>('transactionsBox');

  final prefsService = await SharedPrefsService.getInstance();
  final savedName = prefsService.getUserName(); // ⬅️ Get instance

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ExpenseBloc()..add(LoadTransactions())),

        
      ],
      child: MyApp(prefsService: prefsService, savedName: savedName),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPrefsService prefsService;
  final String? savedName;

  const MyApp({
    super.key,
    required this.savedName,
    required this.prefsService,
  }); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expensely App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: savedName == null
          ? WelcomeScreen(
              prefsService: prefsService,
            )
          : HomeScreen(userName: savedName!), 
    );
  }
}
