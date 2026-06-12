import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';

int clampStat(int value) => value.clamp(0, 100).toInt();

DateTime utcDate(DateTime value) => value.toUtc();

class PetState {
  const PetState({
    required this.id,
    required this.name,
    required this.speciesId,
    required this.stage,
    required this.hunger,
    required this.happiness,
    required this.cleanliness,
    required this.energy,
    required this.health,
    required this.discipline,
    required this.ageHours,
    required this.careMistakes,
    required this.totalMeals,
    required this.totalSnacks,
    required this.totalCleanups,
    required this.totalMiniGameWins,
    required this.bornAtUtc,
    required this.lastUpdatedAtUtc,
    required this.lastOpenedAtUtc,
    required this.currentRoomId,
    required this.currentShellSkinId,
    required this.isSleeping,
    required this.isSick,
  });

  factory PetState.initial(DateTime nowUtc) {
    final now = utcDate(nowUtc);
    return PetState(
      id: 'pet-001',
      name: '',
      speciesId: 'cloud-sprout',
      stage: EvolutionStage.egg,
      hunger: 82,
      happiness: 76,
      cleanliness: 88,
      energy: 74,
      health: 92,
      discipline: 64,
      ageHours: 0,
      careMistakes: 0,
      totalMeals: 0,
      totalSnacks: 0,
      totalCleanups: 0,
      totalMiniGameWins: 0,
      bornAtUtc: now,
      lastUpdatedAtUtc: now,
      lastOpenedAtUtc: now,
      currentRoomId: 'warm-desk',
      currentShellSkinId: 'pink-cloud',
      isSleeping: false,
      isSick: false,
    );
  }

  final String id;
  final String name;
  final String speciesId;
  final EvolutionStage stage;
  final int hunger;
  final int happiness;
  final int cleanliness;
  final int energy;
  final int health;
  final int discipline;
  final int ageHours;
  final int careMistakes;
  final int totalMeals;
  final int totalSnacks;
  final int totalCleanups;
  final int totalMiniGameWins;
  final DateTime bornAtUtc;
  final DateTime lastUpdatedAtUtc;
  final DateTime lastOpenedAtUtc;
  final String currentRoomId;
  final String currentShellSkinId;
  final bool isSleeping;
  final bool isSick;

  PetState copyWith({
    String? id,
    String? name,
    String? speciesId,
    EvolutionStage? stage,
    int? hunger,
    int? happiness,
    int? cleanliness,
    int? energy,
    int? health,
    int? discipline,
    int? ageHours,
    int? careMistakes,
    int? totalMeals,
    int? totalSnacks,
    int? totalCleanups,
    int? totalMiniGameWins,
    DateTime? bornAtUtc,
    DateTime? lastUpdatedAtUtc,
    DateTime? lastOpenedAtUtc,
    String? currentRoomId,
    String? currentShellSkinId,
    bool? isSleeping,
    bool? isSick,
  }) {
    return PetState(
      id: id ?? this.id,
      name: name ?? this.name,
      speciesId: speciesId ?? this.speciesId,
      stage: stage ?? this.stage,
      hunger: clampStat(hunger ?? this.hunger),
      happiness: clampStat(happiness ?? this.happiness),
      cleanliness: clampStat(cleanliness ?? this.cleanliness),
      energy: clampStat(energy ?? this.energy),
      health: clampStat(health ?? this.health),
      discipline: clampStat(discipline ?? this.discipline),
      ageHours: ageHours ?? this.ageHours,
      careMistakes: careMistakes ?? this.careMistakes,
      totalMeals: totalMeals ?? this.totalMeals,
      totalSnacks: totalSnacks ?? this.totalSnacks,
      totalCleanups: totalCleanups ?? this.totalCleanups,
      totalMiniGameWins: totalMiniGameWins ?? this.totalMiniGameWins,
      bornAtUtc: utcDate(bornAtUtc ?? this.bornAtUtc),
      lastUpdatedAtUtc: utcDate(lastUpdatedAtUtc ?? this.lastUpdatedAtUtc),
      lastOpenedAtUtc: utcDate(lastOpenedAtUtc ?? this.lastOpenedAtUtc),
      currentRoomId: currentRoomId ?? this.currentRoomId,
      currentShellSkinId: currentShellSkinId ?? this.currentShellSkinId,
      isSleeping: isSleeping ?? this.isSleeping,
      isSick: isSick ?? this.isSick,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'speciesId': speciesId,
      'stage': stage.name,
      'hunger': hunger,
      'happiness': happiness,
      'cleanliness': cleanliness,
      'energy': energy,
      'health': health,
      'discipline': discipline,
      'ageHours': ageHours,
      'careMistakes': careMistakes,
      'totalMeals': totalMeals,
      'totalSnacks': totalSnacks,
      'totalCleanups': totalCleanups,
      'totalMiniGameWins': totalMiniGameWins,
      'bornAtUtc': bornAtUtc.toIso8601String(),
      'lastUpdatedAtUtc': lastUpdatedAtUtc.toIso8601String(),
      'lastOpenedAtUtc': lastOpenedAtUtc.toIso8601String(),
      'currentRoomId': currentRoomId,
      'currentShellSkinId': currentShellSkinId,
      'isSleeping': isSleeping,
      'isSick': isSick,
    };
  }

  factory PetState.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toUtc();
    return PetState.initial(now).copyWith(
      id: json['id'] as String?,
      name: json['name'] as String?,
      speciesId: json['speciesId'] as String?,
      stage: EvolutionStage.values.byName((json['stage'] as String?) ?? EvolutionStage.egg.name),
      hunger: json['hunger'] as int?,
      happiness: json['happiness'] as int?,
      cleanliness: json['cleanliness'] as int?,
      energy: json['energy'] as int?,
      health: json['health'] as int?,
      discipline: json['discipline'] as int?,
      ageHours: json['ageHours'] as int?,
      careMistakes: json['careMistakes'] as int?,
      totalMeals: json['totalMeals'] as int?,
      totalSnacks: json['totalSnacks'] as int?,
      totalCleanups: json['totalCleanups'] as int?,
      totalMiniGameWins: json['totalMiniGameWins'] as int?,
      bornAtUtc: DateTime.tryParse((json['bornAtUtc'] as String?) ?? '') ?? now,
      lastUpdatedAtUtc: DateTime.tryParse((json['lastUpdatedAtUtc'] as String?) ?? '') ?? now,
      lastOpenedAtUtc: DateTime.tryParse((json['lastOpenedAtUtc'] as String?) ?? '') ?? now,
      currentRoomId: json['currentRoomId'] as String?,
      currentShellSkinId: json['currentShellSkinId'] as String?,
      isSleeping: json['isSleeping'] as bool?,
      isSick: json['isSick'] as bool?,
    );
  }
}
