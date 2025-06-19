class Challenge {
  String title;
  String description;
  bool isCompleted;

  Challenge({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}