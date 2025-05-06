class RepSet {
  int reps;
  double weight;

  String? note;
  int? restBetweenSets; // in seconds
  int? restAfterSet;
  bool completed = false;

  RepSet(
      {required this.reps,
      required this.weight,
      this.note,
      this.restBetweenSets,
      this.restAfterSet});

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'note': note,
      'restBetweenSets': restBetweenSets,
      'restAfterSet': restAfterSet
    };
  }

  RepSet.fromJson(Map<String, dynamic> json)
      : reps = int.parse(json['reps'].toString()),
        weight = double.parse(json['weight'].toString()),
        note = json['note']?.toString(),
        restBetweenSets = json['restBetweenSets'] != null
            ? int.parse(json['restBetweenSets'].toString())
            : null,
        restAfterSet = json['restAfterSet'] != null
            ? int.parse(json['restAfterSet'].toString())
            : null;
}
