class PetBalance {
  const PetBalance({
    this.hungerLossPerHour = 6,
    this.cleanlinessLossPerHour = 4,
    this.happinessLossPerHour = 3,
    this.awakeEnergyLossPerHour = 5,
    this.sleepEnergyGainPerHour = 12,
    this.lowHungerHealthPenalty = 10,
    this.lowCleanlinessSickHours = 6,
    this.lowHungerPenaltyHours = 8,
    this.maxOfflineHours = 48,
  });

  final int hungerLossPerHour;
  final int cleanlinessLossPerHour;
  final int happinessLossPerHour;
  final int awakeEnergyLossPerHour;
  final int sleepEnergyGainPerHour;
  final int lowHungerHealthPenalty;
  final int lowCleanlinessSickHours;
  final int lowHungerPenaltyHours;
  final int maxOfflineHours;
}
