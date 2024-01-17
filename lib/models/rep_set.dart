class RepSet {
  int reps;
  double weight;

  String? note;

  RepSet({required this.reps, required this.weight, this.note});

  RepSet.fromJson(Map<String, dynamic> json)
      : reps = int.parse(json['reps']),
        weight = double.parse(json['weight'].toString()),
        note = json['note'];
}
