class Category {
  final int? id;
  final String name;
  final String type;
  final String icon;

  Category({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        icon: json['icon'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'type': type,
        'icon': icon,
      };
}