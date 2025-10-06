import '../models/data_layer.dart';
import 'package:flutter/material.dart';
import '../plan_provider.dart';

class PlanScreen extends StatefulWidget {
  final Plan plan;
  const PlanScreen({super.key, required this.plan});
  @override
  State createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late ScrollController scrollController;
  Plan get plan => widget.plan;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        FocusScope.of(context).requestFocus(FocusNode());
      });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Plan>> plansNotifier = PlanProvider.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(plan.name)),
      body: ValueListenableBuilder<List<Plan>>(
        valueListenable: plansNotifier,
        builder: (context, plans, child) {
          final planIndex = plans.indexWhere((p) => p.name == plan.name);
          final Plan currentPlan = planIndex >= 0 ? plans[planIndex] : plan;
          return Column(
            children: [
              Expanded(child: _buildList(currentPlan)),
              SafeArea(child: Text(currentPlan.completenessMessage)),
            ],
          );
        },
      ),
      floatingActionButton: _buildAddTaskButton(context),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    ValueNotifier<List<Plan>> planNotifier = PlanProvider.of(context);
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        final String planName = plan.name;
        int planIndex = planNotifier.value.indexWhere(
          (p) => p.name == planName,
        );
        if (planIndex == -1) {
          // Add the plan to the provider with one initial task
          final initialTasks = List<Task>.from(plan.tasks)..add(const Task());
          final updatedPlans = List<Plan>.from(planNotifier.value)
            ..add(Plan(name: planName, tasks: initialTasks));
          planNotifier.value = updatedPlans;
        } else {
          final providerPlan = planNotifier.value[planIndex];
          final List<Task> updatedTasks = List<Task>.from(providerPlan.tasks)
            ..add(const Task());
          final updatedPlans = List<Plan>.from(planNotifier.value);
          updatedPlans[planIndex] = Plan(
            name: providerPlan.name,
            tasks: updatedTasks,
          );
          planNotifier.value = updatedPlans;
        }
      },
    );
  }

  Widget _buildList(Plan plan) {
    return ListView.builder(
      controller: scrollController,
      itemCount: plan.tasks.length,
      itemBuilder: (context, index) =>
          _buildTaskTile(plan.tasks[index], index, context),
    );
  }

  Widget _buildTaskTile(Task task, int index, BuildContext context) {
    ValueNotifier<List<Plan>> planNotifier = PlanProvider.of(context);
    return ListTile(
      leading: Checkbox(
        value: task.complete,
        onChanged: (selected) {
          final planName = plan.name;
          int planIndex = planNotifier.value.indexWhere(
            (p) => p.name == planName,
          );
          if (planIndex == -1) return; // Plan not found; nothing to update.
          final providerPlan = planNotifier.value[planIndex];
          final updatedTasks = List<Task>.from(providerPlan.tasks)
            ..[index] = Task(
              description: task.description,
              complete: selected ?? false,
            );
          final updatedPlans = List<Plan>.from(planNotifier.value);
          updatedPlans[planIndex] = Plan(
            name: providerPlan.name,
            tasks: updatedTasks,
          );
          planNotifier.value = updatedPlans;
        },
      ),
      title: TextFormField(
        initialValue: task.description,
        onChanged: (text) {
          final planName = plan.name;
          int planIndex = planNotifier.value.indexWhere(
            (p) => p.name == planName,
          );
          if (planIndex == -1) return; // Plan not found; nothing to update.
          final providerPlan = planNotifier.value[planIndex];
          final updatedTasks = List<Task>.from(providerPlan.tasks)
            ..[index] = Task(description: text, complete: task.complete);
          final updatedPlans = List<Plan>.from(planNotifier.value);
          updatedPlans[planIndex] = Plan(
            name: providerPlan.name,
            tasks: updatedTasks,
          );
          planNotifier.value = updatedPlans;
        },
      ),
    );
  }
}
