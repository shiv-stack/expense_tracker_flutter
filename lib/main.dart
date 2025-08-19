import 'package:expensely_app/Screens/HomeScreen.dart';
import 'package:expensely_app/Screens/Welcome_Screen.dart';
import 'package:expensely_app/bloc/expense_bloc.dart';
import 'package:expensely_app/bloc/expense_event.dart';
import 'package:expensely_app/constants/colors.dart';
import 'package:expensely_app/constants/methods.dart';
import 'package:expensely_app/models/category_model.dart';
import 'package:expensely_app/models/transaction.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hive_flutter/adapters.dart';

import 'services/shared_prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await SharedPrefService.init();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  await Hive.openBox<Transaction>('transactionsBox');
  await initializeDefaultCategories();

  final savedName = SharedPrefService.getData("userName"); // ⬅️ Get instance

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ExpenseBloc()..add(LoadTransactions())),
      ],
      child: MyApp(savedName: savedName),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? savedName;

  const MyApp({
    super.key,
    required this.savedName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expensely App',
      theme: ThemeData(
          fontFamily: "Poppins",
          scaffoldBackgroundColor: offWhiteColor,
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, primaryContainer: Colors.white),
          bottomSheetTheme: BottomSheetThemeData(backgroundColor: offWhiteColor),
          useMaterial3: true,
          dialogTheme: DialogThemeData(backgroundColor: Colors.white)),
      home: savedName == null ? WelcomeScreen() : MainScreen(),
    );
  }
}
