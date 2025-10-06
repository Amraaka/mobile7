import 'package:flutter/material.dart';
import 'package:mobile7/views/plan_creator_screen.dart';
import './models/plan.dart';
import './plan_provider.dart';

void main() => runApp(const MasterPlanApp());

class MasterPlanApp extends StatelessWidget {
  const MasterPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialPlans = <Plan>[const Plan(name: 'My Plan', tasks: [])];
    return PlanProvider(
      notifier: ValueNotifier<List<Plan>>(initialPlans),
      child: MaterialApp(
        title: 'State management app',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: PlanCreatorScreen(),
      ),
    );
  }
}
