import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String sender;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id'],
      text: data['text'],
      sender: data['sender'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'createdAt': createdAt,
    };
  }
}
