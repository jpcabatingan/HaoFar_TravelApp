class ChecklistItem {
  final String text;
  bool isChecked;

  ChecklistItem({required this.text, this.isChecked = false});

  Map<String, dynamic> toJson() => {
    'text': text,
    'isChecked': isChecked,
  };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      text: json['text'],
      isChecked: json['isChecked'] ?? false,
    );
  }
}
