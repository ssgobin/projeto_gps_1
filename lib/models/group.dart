class GroupModel {
  final String id;
  final String name;
  final String leader;

  GroupModel({
    required this.id,
    required this.name,
    required this.leader,
  });

  factory GroupModel.fromMap(Map<String, dynamic> data) {
    return GroupModel(
      id: data['id'],
      name: data['name'],
      leader: data['leader'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'leader': leader,
    };
  }
}
