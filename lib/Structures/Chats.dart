import 'User.dart';

class ChatMessage{
  int id;
  final String content;
  final String imageUrl;
  final User sender;
  final User recipient;
  final int timestamp;
  bool get hasImage => imageUrl != null;
  bool shown;



  ChatMessage({id, content,imageUrl,sender,recipient, double timestamp, shown = false}) : this.id = id, this.content = content, this.imageUrl = imageUrl, this.sender = sender, this.recipient = recipient, this.timestamp = timestamp.toInt(), this.shown = shown;

  ChatMessage.fromMap(Map m, User partner, [shown = false]): this.content = m["content"], this.id = m["chat_id"], this.imageUrl = m["image_url"], this.sender = User.getUserByID(m["sender_id"]), this.recipient = m["sender_id"] == thisUser.id ? partner : thisUser, this.timestamp = m["timestamp"].toInt(), shown = shown ;

  Map get asMap{
    return{
      "chat_id": id,
      "timestamp": timestamp,
      "sender_id": sender.id,
      "content": content,
      "image_url": imageUrl
    };
  }
}
