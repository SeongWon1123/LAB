enum EvolutionStage { egg, baby, child, teen, adult, special }

enum InventoryItemType { food, snack, shellSkin, room, keepsake }

enum DiaryEntryType { hatch, care, growth, mood, system }

enum CareAction { feedMeal, feedSnack, cleanRoom, startSleep, wakeUp, playMiniGameResult }

extension EvolutionStageLabel on EvolutionStage {
  String get label {
    return switch (this) {
      EvolutionStage.egg => 'Egg',
      EvolutionStage.baby => 'Baby',
      EvolutionStage.child => 'Child',
      EvolutionStage.teen => 'Teen',
      EvolutionStage.adult => 'Adult',
      EvolutionStage.special => 'Special',
    };
  }
}

extension CareActionLabel on CareAction {
  String get label {
    return switch (this) {
      CareAction.feedMeal => 'Meal',
      CareAction.feedSnack => 'Snack',
      CareAction.cleanRoom => 'Clean',
      CareAction.startSleep => 'Sleep',
      CareAction.wakeUp => 'Wake',
      CareAction.playMiniGameResult => 'Play',
    };
  }
}
