import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection_container.dart' as di;
import 'features/expense/presentation/bloc/expense_bloc.dart';
import 'features/expense/presentation/bloc/budget_bloc.dart';
import 'features/expense/presentation/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://pngeuqhpxxcfarptwnon.supabase.co',
    anonKey: 'sb_publishable_Im0frfFd05BVUd8mXf2Njg_smeNtknZ',
  );

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ExpenseBloc>()),
        BlocProvider(create: (_) => di.sl<BudgetBloc>()),
      ],
      child: MaterialApp(
        title: 'Personal Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark
          ),
        ),
        home: const MainPage(),
      ),
    );
  }
}
