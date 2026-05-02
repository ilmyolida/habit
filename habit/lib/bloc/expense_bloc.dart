import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../utils/database_helper.dart';

// Events
abstract class ExpenseEvent {}
class LoadExpenses extends ExpenseEvent {}
class AddExpense extends ExpenseEvent { final Expense expense; AddExpense(this.expense); }
class DeleteExpense extends ExpenseEvent { final int id; DeleteExpense(this.id); }
class LoadExpenseCategories extends ExpenseEvent {}

// States
abstract class ExpenseState {}
class ExpenseInitial extends ExpenseState {}
class ExpenseLoading extends ExpenseState {}
class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double totalExpense;
  final double totalIncome;
  final double balance;
  
  ExpenseLoaded({
    required this.expenses,
    required this.totalExpense,
    required this.totalIncome,
    required this.balance,
  });
}
class ExpenseCategoriesLoaded extends ExpenseState {
  final List<Category> categories;
  ExpenseCategoriesLoaded(this.categories);
}

// Bloc
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<LoadExpenseCategories>(_onLoadExpenseCategories);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    final expenses = await DatabaseHelper.instance.getExpenses();
    
    double totalExpense = 0;
    double totalIncome = 0;
    
    for (var expense in expenses) {
      if (expense.isIncome) {
        totalIncome += expense.amount;
      } else {
        totalExpense += expense.amount;
      }
    }
    
    emit(ExpenseLoaded(
      expenses: expenses,
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      balance: totalIncome - totalExpense,
    ));
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    await DatabaseHelper.instance.insertExpense(event.expense);
    add(LoadExpenses());
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    await DatabaseHelper.instance.deleteExpense(event.id);
    add(LoadExpenses());
  }

  Future<void> _onLoadExpenseCategories(LoadExpenseCategories event, Emitter<ExpenseState> emit) async {
    final categories = await DatabaseHelper.instance.getCategories('expense');
    emit(ExpenseCategoriesLoaded(categories));
  }
}