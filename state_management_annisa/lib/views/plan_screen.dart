import '../models/data_layer.dart';
import 'package:flutter/material.dart';
import '../provider/plan_provider.dart';

class PlanScreen extends StatefulWidget {
  final Plan plan;
  const PlanScreen({super.key, required this.plan});

  @override
  State createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        FocusScope.of(context).requestFocus(FocusNode());
      });
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Plan>> plansNotifier = PlanProvider.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.plan.name)),
      body: ValueListenableBuilder<List<Plan>>(
        valueListenable: plansNotifier,
        builder: (context, plans, child) {
          Plan? currentPlan = plans.firstWhere((p) => p.name == widget.plan.name, orElse: () => Plan(name: '', tasks: []));

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
        int planIndex = planNotifier.value.indexWhere((p) => p.name == widget.plan.name);
        if (planIndex == -1) return; // Mencegah error jika Plan tidak ditemukan

        List<Task> updatedTasks = List<Task>.from(planNotifier.value[planIndex].tasks)
          ..add(const Task());

        planNotifier.value = List<Plan>.from(planNotifier.value)
          ..[planIndex] = Plan(
            name: widget.plan.name,
            tasks: updatedTasks,
          );

        planNotifier.notifyListeners(); // Tambahkan ini agar UI diperbarui
      },
    );
  }

  Widget _buildList(Plan plan) {
    return ListView.builder(
      controller: scrollController,
      itemCount: plan.tasks.length,
      itemBuilder: (context, index) => _buildTaskTile(plan, index, context),
    );
  }

  Widget _buildTaskTile(Plan plan, int index, BuildContext context) {
    ValueNotifier<List<Plan>> planNotifier = PlanProvider.of(context);

    return ListTile(
      leading: Checkbox(
        value: plan.tasks[index].complete,
        onChanged: (selected) {
          int planIndex = planNotifier.value.indexWhere((p) => p.name == plan.name);
          if (planIndex == -1) return;

          List<Task> updatedTasks = List<Task>.from(plan.tasks)
            ..[index] = Task(
              description: plan.tasks[index].description,
              complete: selected ?? false,
            );

          planNotifier.value = List<Plan>.from(planNotifier.value)
            ..[planIndex] = Plan(
              name: plan.name,
              tasks: updatedTasks,
            );

          planNotifier.notifyListeners(); // Tambahkan ini agar UI diperbarui
        },
      ),
      title: TextFormField(
        initialValue: plan.tasks[index].description,
        onChanged: (text) {
          int planIndex = planNotifier.value.indexWhere((p) => p.name == plan.name);
          if (planIndex == -1) return;

          List<Task> updatedTasks = List<Task>.from(plan.tasks)
            ..[index] = Task(
              description: text,
              complete: plan.tasks[index].complete,
            );

          planNotifier.value = List<Plan>.from(planNotifier.value)
            ..[planIndex] = Plan(
              name: plan.name,
              tasks: updatedTasks,
            );

          planNotifier.notifyListeners(); // Tambahkan ini agar UI diperbarui
        },
      ),
    );
  }
}
