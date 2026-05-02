import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/habit.dart';
import '../utils/database_helper.dart';

// Events
abstract class HabitEvent {}
class LoadHabits extends HabitEvent {}
class AddHabit extends HabitEvent { final Habit habit; AddHabit(this.habit); }
class UpdateHabit extends HabitEvent { final Habit habit; UpdateHabit(this.habit); }
class DeleteHabit extends HabitEvent { final int id; DeleteHabit(this.id); }
class ToggleHabitComplete extends HabitEvent { final Habit habit; final DateTime date; ToggleHabitComplete(this.habit, this.date); }
class ArchiveHabit extends HabitEvent { final int id; final bool archive; ArchiveHabit(this.id, this.archive); }
class ReorderHabits extends HabitEvent { final int oldIndex; final int newIndex; ReorderHabits(this.oldIndex, this.newIndex); }

// States
abstract class HabitState {}
class HabitInitial extends HabitState {}
class HabitLoading extends HabitState {}
class HabitLoaded extends HabitState {
  final List<Habit> activeHabits;
  final List<Habit> archivedHabits;
  final List<Habit> todayTasks;
  
  HabitLoaded({
    required this.activeHabits,
    required this.archivedHabits,
    required this.todayTasks,
  });
}

// Bloc
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  HabitBloc() : super(HabitInitial()) {
    on<LoadHabits>(_onLoadHabits);
    on<AddHabit>(_onAddHabit);
    on<UpdateHabit>(_onUpdateHabit);
    on<DeleteHabit>(_onDeleteHabit);
    on<ToggleHabitComplete>(_onToggleHabitComplete);
    on<ArchiveHabit>(_onArchiveHabit);
    on<ReorderHabits>(_onReorderHabits);
  }

  Future<void> _onLoadHabits(LoadHabits event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    final allHabits = await DatabaseHelper.instance.getHabits();
    final activeHabits = allHabits.where((h) => h.isActive && !h.isArchived).toList();
    final archivedHabits = allHabits.where((h) => h.isArchived).toList();
    
    // Get today's tasks (habits that need to be done today)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final todayTasks = activeHabits.where((habit) {
      // Check if habit is not completed today
      return !habit.completedDays.contains(todayDate.millisecondsSinceEpoch);
    }).toList();
    
    emit(HabitLoaded(
      activeHabits: activeHabits,
      archivedHabits: archivedHabits,
      todayTasks: todayTasks,
    ));
  }

  Future<void> _onAddHabit(AddHabit event, Emitter<HabitState> emit) async {
    await DatabaseHelper.instance.insertHabit(event.habit);
    add(LoadHabits());
  }

  Future<void> _onUpdateHabit(UpdateHabit event, Emitter<HabitState> emit) async {
    await DatabaseHelper.instance.updateHabit(event.habit);
    add(LoadHabits());
  }

  Future<void> _onDeleteHabit(DeleteHabit event, Emitter<HabitState> emit) async {
    await DatabaseHelper.instance.deleteHabit(event.id);
    add(LoadHabits());
  }

  Future<void> _onToggleHabitComplete(ToggleHabitComplete event, Emitter<HabitState> emit) async {
    final dateMillis = event.date.millisecondsSinceEpoch;
    List<int> newCompletedDays = List.from(event.habit.completedDays);
    
    if (newCompletedDays.contains(dateMillis)) {
      newCompletedDays.remove(dateMillis);
    } else {
      newCompletedDays.add(dateMillis);
    }
    
    final updatedHabit = event.habit.copyWith(
      completedDays: newCompletedDays,
      currentCount: newCompletedDays.length,
    );
    await DatabaseHelper.instance.updateHabit(updatedHabit);
    add(LoadHabits());
  }

  Future<void> _onArchiveHabit(ArchiveHabit event, Emitter<HabitState> emit) async {
    final habits = await DatabaseHelper.instance.getHabits();
    final habit = habits.firstWhere((h) => h.id == event.id);
    final updatedHabit = habit.copyWith(isArchived: event.archive);
    await DatabaseHelper.instance.updateHabit(updatedHabit);
    add(LoadHabits());
  }

  Future<void> _onReorderHabits(ReorderHabits event, Emitter<HabitState> emit) async {
    if (state is HabitLoaded) {
      final currentState = state as HabitLoaded;
      final newList = List<Habit>.from(currentState.activeHabits);
      final item = newList.removeAt(event.oldIndex);
      newList.insert(event.newIndex, item);
      
      // Update order in database
      for (int i = 0; i < newList.length; i++) {
        await DatabaseHelper.instance.updateHabit(newList[i]);
      }
      add(LoadHabits());
    }
  }
}