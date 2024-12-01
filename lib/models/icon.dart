class IconDataModel {
  int? iconId;
  String iconName;
  String iconPath;

  IconDataModel({
    this.iconId,
    required this.iconName,
    required this.iconPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'icon_id': iconId,
      'icon_name': iconName,
      'icon_path': iconPath,
    };
  }

  factory IconDataModel.fromMap(Map<String, dynamic> map) {
    return IconDataModel(
      iconId: map['icon_id'],
      iconName: map['icon_name'],
      iconPath: map['icon_path'],
    );
  }
}
