import 'package:firebase_storage/firebase_storage.dart';
import 'Accounts.dart';
import 'HelperFunctions.dart';
import 'dart:io';
import 'dart:async';
import '../Structures/Chats.dart';
import 'NetCode.dart';
import '../Structures/User.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../UI/Components/SubPageChatConvo.dart';
import '../UI/PageChat.dart';
import 'package:image/image.dart';


class FirebaseUtils{


  static final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  static String fcmToken;
  static Future<bool> initFCM() async{
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: ${message["type"]}");
        switch (message["type"]){
          case "chat_message":
            try {
              var msg;
              if (message["message"] is String){
                msg = json.decode(message["message"]);
              }else {
                msg = message["message"];
              }
              User
                  .getUserByID(msg["sender_id"])
                  .chats
                  .insert(0, new ChatMessage.fromMap(msg, thisUser));
              SubPageChatConvo.subChatPageKey.currentState?.refresh();
              PageChat.chatPageKey.currentState?.refresh();
            } catch (e) {
              print(e);
            }
            break;
          case "listing_matched":
            break;
          case "new_package":
            break;
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) {
        switch (message["type"]) {
          case "chat_message":
            try {
              var msg;
              if (message["message"] is String) {
                msg = json.decode(message["message"]);
              } else {
                msg = message["message"];
              }
              User
                  .getUserByID(msg["sender_id"])
                  .chats
                  .insert(0, new ChatMessage.fromMap(msg, thisUser));
              SubPageChatConvo.subChatPageKey.currentState?.refresh();
              PageChat.chatPageKey.currentState?.refresh();
            } catch (e) {
              print(e);
            }
            break;
          case "listing_matched":
            break;
          case "new_package":
            break;
        }
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    fcmToken = await _firebaseMessaging.getToken();
    print(fcmToken);
    NetCode.sendFCMToken(fcmToken);
    _firebaseMessaging.onTokenRefresh.listen((s){
      fcmToken = s;
      NetCode.sendFCMToken(fcmToken);
    });
    return true;
  }

  static Future<Uri> uploadImage({ File file }) async {
    //Compress image
    Image image = decodeImage(await file.readAsBytes());
    Image compressed = copyResize(image, 1000);
    File compFile = new File('$mainDir/temp.jpg');
    await compFile.writeAsBytes(encodeJpg(compressed));
    //TODO: check if logged in
    String random = getRandomString(16);
    StorageReference ref = FirebaseStorage.instance.ref().child("image_$random.jpg");
    StorageUploadTask uploadTask = ref.put(compFile);
    var url = (await uploadTask.future).downloadUrl;
    await compFile.delete();
    return url;
  }

  static Future<ChatMessage> sendMessage(ChatMessage cm) async{
    return NetCode.sendMessage(cm);
  }

  static Future<bool> setConvos() async {
    var convos = await NetCode.getConvos();
    convos.forEach((u, cm){
      if (u.chats.length == 0)
        u.chats.add(cm);
    });
    return true;
  }

  static Future<List<ChatMessage>> populateChatsFromDisk(User partner)
  async {
    try {
      String raw = await readFromFile('chats-' + partner.id.toString());
      if (raw == null || raw.isEmpty) {
        return getMessage(partner, 2147483647, true);
      } else {
        Map m = getMapByNodeFromJSON(raw);
        List<Map> msgs = m["messages"];
        var r = msgs.map((msg) => new ChatMessage.fromMap(msg, partner, true)).toList();
        r.removeAt(0); //remove the newest one
        return r;
      }
    } catch (e){
      print(e);
      return getMessage(partner, 2147483647, true);
    }
  }

  static Future<List<ChatMessage>> getMessage(User partner, int pivotChatID, bool history) async{
    var cms = NetCode.getMessage(partner, pivotChatID, history);
    return cms;

  }

}