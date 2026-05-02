import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/mood.dart';
import '../models/mood_tag.dart';
import '../utils/database_helper.dart';

// Events
abstract class MoodEvent {}
class LoadMoods extends MoodEvent {}
class LoadMoodByDate extends MoodEvent { final DateTime date; LoadMoodByDate(this.date); }
class SaveMood extends MoodEvent { final MoodEntry entry; SaveMood(this.entry); }
class LoadMoodTags extends MoodEvent {}
class AddMoodTag extends MoodEvent { final String name; AddMoodTag(this.name); }
class UpdateMoodTag extends MoodEvent { final MoodTag tag; UpdateMoodTag(this.tag); }
class DeleteMoodTag extends MoodEvent { final int id; DeleteMoodTag(this.id); }
class ReorderMoodTags extends MoodEvent { final int oldIndex; final int newIndex; ReorderMoodTags(this.oldIndex, this.newIndex); }
class ToggleMoodTag extends MoodEvent { final int id; final bool isActive; ToggleMoodTag(this.id, this.isActive); }

// States
abstract class MoodState {}
class MoodInitial extends MoodState {}
class MoodLoading extends MoodState {}
class MoodLoaded extends MoodState {
  final List<MoodEntry> entries;
  final MoodEntry? todayMood;
  MoodLoaded(this.entries, this.todayMood);
}
class MoodTagsLoaded extends MoodState {
  final List<MoodTag> tags;
  MoodTagsLoaded(this.tags);
}
class MoodSaved extends MoodState {}

// Bloc
class MoodBloc extends Bloc<MoodEvent, MoodState> {
  MoodBloc() : super(MoodInitial()) {
    on<LoadMoods>(_onLoadMoods);
    on<LoadMoodByDate>(_onLoadMoodByDate);
    on<SaveMood>(_onSaveMood);
    on<LoadMoodTags>(_onLoadMoodTags);
    on<AddMoodTag>(_onAddMoodTag);
    on<UpdateMoodTag>(_onUpdateMoodTag);
    on<DeleteMoodTag>(_onDeleteMoodTag);
    on<ReorderMoodTags>(_onReorderMoodTags);
    on<ToggleMoodTag>(_onToggleMoodTag);
  }

  Future<void> _onLoadMoods(LoadMoods event, Emitter<MoodState> emit) async {
    emit(MoodLoading());
    final entries = await DatabaseHelper.instance.getMoodEntries();
    final today = DateTime.now();
    final todayMood = await DatabaseHelper.instance.getMoodEntryByDate(
      DateTime(today.year, today.month, today.day)
    );
    emit(MoodLoaded(entries, todayMood));
  }

  Future<void> _onLoadMoodByDate(LoadMoodByDate event, Emitter<MoodState> emit) async {
    emit(MoodLoading());
    final mood = await DatabaseHelper.instance.getMoodEntryByDate(event.date);
    emit(MoodLoaded([], mood));
  }

  Future<void> _onSaveMood(SaveMood event, Emitter<MoodState> emit) async {
    await DatabaseHelper.instance.insertMoodEntry(event.entry);
    emit(MoodSaved());
    add(LoadMoods());
  }

  Future<void> _onLoadMoodTags(LoadMoodTags event, Emitter<MoodState> emit) async {
    final tags = await DatabaseHelper.instance.getMoodTags();
    emit(MoodTagsLoaded(tags));
  }

  Future<void> _onAddMoodTag(AddMoodTag event, Emitter<MoodState> emit) async {
    final tags = await DatabaseHelper.instance.getMoodTags();
    final newTag = MoodTag(
      name: event.name,
      order: tags.length,
      isActive: true,
    );
    await DatabaseHelper.instance.insertMoodTag(newTag);
    add(LoadMoodTags());
  }

  Future<void> _onUpdateMoodTag(UpdateMoodTag event, Emitter<MoodState> emit) async {
    await DatabaseHelper.instance.updateMoodTag(event.tag);
    add(LoadMoodTags());
  }

  Future<void> _onDeleteMoodTag(DeleteMoodTag event, Emitter<MoodState> emit) async {
    await DatabaseHelper.instance.deleteMoodTag(event.id);
    add(LoadMoodTags());
  }

  Future<void> _onReorderMoodTags(ReorderMoodTags event, Emitter<MoodState> emit) async {
    if (state is MoodTagsLoaded) {
      final tags = List<MoodTag>.from((state as MoodTagsLoaded).tags);
      final item = tags.removeAt(event.oldIndex);
      tags.insert(event.newIndex, item);
      for (int i = 0; i < tags.length; i++) {
        await DatabaseHelper.instance.updateMoodTag(tags[i].copyWith(order: i));
      }
      add(LoadMoodTags());
    }
  }

  Future<void> _onToggleMoodTag(ToggleMoodTag event, Emitter<MoodState> emit) async {
    final tags = await DatabaseHelper.instance.getMoodTags();
    final tag = tags.firstWhere((t) => t.id == event.id);
    await DatabaseHelper.instance.updateMoodTag(tag.copyWith(isActive: event.isActive));
    add(LoadMoodTags());
  }
}

extension MoodTagCopyWith on MoodTag {
  MoodTag copyWith({
    int? id,
    String? name,
    int? order,
    bool? isActive,
  }) {
    return MoodTag(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}