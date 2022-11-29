import 'package:chat_babakcode/providers/chat_provider.dart';
import 'package:chat_babakcode/providers/login_provider.dart';
import 'package:chat_babakcode/ui/pages/chat/chat_bottom_nav.dart';
import 'package:chat_babakcode/ui/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/chat_appbar_model.dart';
import '../../../models/room.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import 'chat_scrollable_list.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _canPop = true;

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final chatProvider = context.watch<ChatProvider>();
    final auth = context.read<Auth>();

    ChatAppBarModel chatAppBarModel = ChatAppBarModel();

    if (chatProvider.selectedRoom != null) {
      switch (chatProvider.selectedRoom!.roomType) {
        case RoomType.pvUser:
          if (chatProvider.selectedRoom!.members[0].user!.id ==
                  auth.myUser!.id &&
              chatProvider.selectedRoom!.members[1].user!.id ==
                  auth.myUser!.id) {
            chatAppBarModel
              ..roomName = 'my Messages'
              ..roomImage = auth.myUser!.profileUrl
              ..roomType = RoomType.pvUser;
            break;
          }

          User friend = chatProvider.selectedRoom!.members
              .firstWhere((element) => element.user!.id != auth.myUser!.id)
              .user!;
          chatAppBarModel
            ..roomName = friend.name
            ..roomImage = friend.profileUrl
            ..roomType = RoomType.pvUser;
          break;
        case RoomType.publicGroup:
          // TODO: Handle this case.
          break;
        case RoomType.pvGroup:
          // TODO: Handle this case.
          break;
        case RoomType.channel:
          // TODO: Handle this case.
          break;
        default:
          {}
      }
      if (_width >= 595 && Navigator.canPop(context) && _canPop) {
        Future.microtask(() {
          if (Navigator.canPop(context) && _canPop) {
            Navigator.pop(context);
            chatProvider.deselectRoom();
            _canPop = false;
          }
        });
        return const SizedBox();
      }
    }

    final _bottomNavigationBarHeight =
        (LoginProvider.platform == 'android' || LoginProvider.platform == 'ios')
            ? MediaQuery.of(context).viewPadding.vertical
            : 0;

    return WillPopScope(
      onWillPop: chatProvider.onWillPopChatPage,
      child: Scaffold(
        appBar: chatProvider.selectedRoom == null
            ? null
            : AppBar(
                leading: IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        chatProvider.deselectRoom();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_rounded)),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chatAppBarModel.roomName ?? 'guest'),
                    if (chatProvider.connectionStatus != null)
                      Text(
                        chatProvider.connectionStatus!,
                        style: const TextStyle(fontSize: 8),
                      )
                  ],
                ),
                actions: [
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.more_vert_rounded))
                ],
              ),
        body: chatProvider.selectedRoom == null
            ? const Center(child: AppText('please select chat room'))
            : SingleChildScrollView(
                reverse: true,
                controller: ScrollController(),
                physics: const NeverScrollableScrollPhysics(),
                // physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      height: MediaQuery.of(context).size.height -
                          64 -
                          AppBar().preferredSize.height -
                          _bottomNavigationBarHeight,
                      child: const ChatScrollableList(),
                    ),
                    ChatBottomNavComponent(
                      room: chatProvider.selectedRoom!,
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
