class RepSet {
  int reps;
  double weight;

  String? note;

  bool completed = false;

  RepSet({required this.reps, required this.weight, this.note});
  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'note': note,
      'completed': completed,
    };
  }

  RepSet.fromJson(Map<String, dynamic> json)
      : reps = int.parse(json['reps'].toString()),
        weight = double.parse(json['weight'].toString()),
        note = json['note'].toString() {
    // Handle completed status if it exists in the JSON
    if (json.containsKey('completed')) {
      completed = json['completed'] == true;
    }
  }
}
