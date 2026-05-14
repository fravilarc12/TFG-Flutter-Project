import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/trips_repository.dart';
import '../../../domain/trip.dart';

// --- PESTAÑA 3: CONTROL DE GASTOS ---
class ExpensesTab extends ConsumerStatefulWidget {
  final String tripId;
  final Trip trip;
  const ExpensesTab({required this.tripId, required this.trip});

  @override
  ConsumerState<ExpensesTab> createState() => ExpensesTabState();
}

class ExpensesTabState extends ConsumerState<ExpensesTab> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String _selectedCategory = 'Otros';

  final List<String> _categories = [
    'Transporte',
    'Alojamiento',
    'Comida',
    'Ocio',
    'Otros'
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Transporte':
        return Icons.directions_bus;
      case 'Alojamiento':
        return Icons.hotel;
      case 'Comida':
        return Icons.restaurant;
      case 'Ocio':
        return Icons.local_activity;
      default:
        return Icons.category;
    }
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref, Trip trip) {
    final budgetController = TextEditingController(
      text: trip.budget != null ? trip.budget.toString() : '',
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Asignar Presupuesto'),
          content: TextField(
            controller: budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Presupuesto (€)',
              hintText: 'Ej. 500',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final budget =
                    double.tryParse(budgetController.text.replaceAll(',', '.'));
                if (budget != null) {
                  ref
                      .read(tripsRepositoryProvider)
                      .updateTripBudget(trip.id!, budget);
                }
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesStreamProvider(widget.tripId));

    return Column(
      children: [
        expensesAsync.when(
          data: (expenses) {
            final total = expenses.fold<double>(
                0, (sum, item) => sum + (item['amount'] ?? 0));
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x33005D90),
                      offset: Offset(0, 8),
                      blurRadius: 24)
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Gastado:",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Text("${total.toStringAsFixed(2)} €",
                            style: TextStyle(
                                color: (widget.trip.budget != null &&
                                        total > widget.trip.budget!)
                                    ? Colors.redAccent
                                    : Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.trip.budget != null
                              ? "Presupuesto: ${widget.trip.budget!.toStringAsFixed(2)} €"
                              : "Sin límite",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white70, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _showBudgetDialog(context, ref, widget.trip);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: titleController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: "Concepto",
                            hintStyle:
                                const TextStyle(color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.inputFill,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                          ))),
                  const SizedBox(width: 10),
                  SizedBox(
                      width: 90,
                      child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: "€",
                            hintStyle:
                                const TextStyle(color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.inputFill,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                          ))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Añadir"),
                    onPressed: () {
                      final amount = double.tryParse(
                          amountController.text.replaceAll(',', '.'));
                      if (titleController.text.isNotEmpty &&
                          amount != null &&
                          amount > 0) {
                        ref.read(tripsRepositoryProvider).addExpense(
                            widget.tripId,
                            titleController.text,
                            amount,
                            _selectedCategory);
                        titleController.clear();
                        amountController.clear();
                        FocusScope.of(context).unfocus();
                      } else if (amount != null && amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('El gasto debe ser mayor que 0')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: expensesAsync.when(
            data: (expenses) => ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final ex = expenses[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0x33005D90),
                    child: Icon(_getCategoryIcon(ex['category'] ?? 'Otros'),
                        color: AppColors.primary),
                  ),
                  title: Text(ex['title']),
                  subtitle: Text(ex['category'] ?? 'Otros'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("-${ex['amount']} €",
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.grey),
                        onPressed: () {
                          ref
                              .read(tripsRepositoryProvider)
                              .deleteExpense(widget.tripId, ex['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error: $e",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

