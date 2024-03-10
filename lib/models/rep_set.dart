class RepSet {
  int reps;
  double weight;

  String? note;

  RepSet({required this.reps, required this.weight, this.note});

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'note': note,
    };
  }

  RepSet.fromJson(Map<String, dynamic> json)
      : reps = int.parse(json['reps'].toString()),
        weight = double.parse(json['weight'].toString()),
        note = json['note'].toString();
}
