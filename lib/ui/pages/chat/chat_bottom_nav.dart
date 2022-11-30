import 'package:chat_babakcode/constants/app_constants.dart';
import 'package:chat_babakcode/constants/config.dart';
import 'package:chat_babakcode/models/room.dart';
import 'package:chat_babakcode/models/user.dart';
import 'package:chat_babakcode/providers/chat_provider.dart';
import 'package:chat_babakcode/providers/global_setting_provider.dart';
import 'package:chat_babakcode/providers/login_provider.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/search_user_provider.dart';
import '../../widgets/app_text.dart';

class ChatBottomNavComponent extends StatelessWidget {
  final Room room;

  const ChatBottomNavComponent({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final globalSetting = context.read<GlobalSettingProvider>();
    final ImagePicker _imagePicker = ImagePicker();

    var _width = MediaQuery.of(context).size.width;
    if (_width > 960) {
      _width -= 260;
    }
    if (_width > 600) {
      _width -= 340;
    }
    return Card(
      elevation: 20,
      margin: EdgeInsets.zero,
      color: globalSetting.isDarkTheme
          ? AppConstants.textColor[900]
          : AppConstants.textColor[50],
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        children: [
          false // check blocked
              ? const Card(
                  margin: EdgeInsets.zero,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Text('Chat Ended'),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Consumer<SearchUserProvider>(
                      builder: (_, searchSignProvider, __) {
                        return searchSignProvider.atSign == null
                            ? const SizedBox()
                            : searchSignProvider.loading
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Container(
                                    constraints: const BoxConstraints(
                                        maxHeight: 350, minHeight: 0),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        User user =
                                            searchSignProvider.usersList[index];
                                        return ListTile(
                                          onTap: () {
                                            chatProvider.chatController.text =
                                                chatProvider.chatController.text
                                                    .replaceAll(
                                                        searchSignProvider
                                                            .atSign!,
                                                        ' @${user.username} ');

                                            searchSignProvider
                                                .onDetectionFinished();
                                          },
                                          title: Text(user.username ?? ''),
                                          trailing: Text(user.name ?? 'guest'),
                                        );
                                      },
                                      itemCount:
                                          searchSignProvider.usersList.length,
                                    ),
                                    color: Colors.white,
                                  );
                      },
                    ),
                    _chatInput(context),
                    Center(child: SizedBox(child: Divider(height: 1, color: globalSetting
                        .isDarkTheme
                    ? AppConstants
                        .textColor[600]
                      : AppConstants
                        .textColor[100])),),
                    Offstage(
                      offstage: !chatProvider.showEmoji,
                      child: SizedBox(
                        height: 300,
                        child: EmojiPicker(
                          onEmojiSelected: (category, emoji) =>
                              chatProvider.onEmojiSelected(emoji),
                          onBackspacePressed: chatProvider.onBackspacePressed,
                          config: Config(
                            columns: 8,
                            emojiSizeMax: 32,
                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            initCategory: Category.RECENT,
                            bgColor: globalSetting.isDarkTheme
                                ? AppConstants.textColor[900]!
                                : AppConstants.textColor[50]!,
                            indicatorColor: Colors.blue,
                            iconColor: Colors.grey,
                            iconColorSelected: Colors.blue,
                            backspaceColor: Colors.blue,
                            skinToneDialogBgColor: Colors.white,
                            skinToneIndicatorColor: Colors.grey,
                            enableSkinTones: true,
                            showRecentsTab: true,
                            recentsLimit: 100,
                            tabIndicatorAnimDuration: kTabScrollDuration,
                            categoryIcons: const CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL,
                          ),
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: !chatProvider.showShareFile,
                      child: MasonryGridView(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6.0),
                        gridDelegate:
                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _width ~/ 260),
                        children: [
                          if (LoginProvider.platform == 'android' ||
                              LoginProvider.platform == 'ios')
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 5),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                leading: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: const SizedBox(
                                      height: 36,
                                      width: 36,
                                      child: Icon(Icons.camera)),
                                ),
                                title: const AppText("Camera"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minLeadingWidth: 30,
                                onTap: () async {
                                  final image = await _imagePicker.pickImage(
                                      source: ImageSource.camera,
                                      maxHeight: 512,
                                      imageQuality: 60);
                                  if (image != null) {}
                                },
                                trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16),
                                tileColor: globalSetting.isDarkTheme
                                    ? AppConstants.textColor[800]
                                    : AppConstants.scaffoldLightBackground,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 5),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              leading: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: const SizedBox(
                                    height: 36,
                                    width: 36,
                                    child: Icon(Icons.image_rounded)),
                              ),
                              title: const AppText("Image"),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minLeadingWidth: 30,
                              onTap: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                );

                                if (result?.files.isNotEmpty ?? false) {
                                  print(result);
                                  for (PlatformFile file in result!.files) {
                                    // var item = File(file.path!);
                                    chatProvider.emitFile(file, 'photo');
                                  }
                                }
                              },
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16),
                              tileColor: globalSetting.isDarkTheme
                                  ? AppConstants.textColor[800]
                                  : AppConstants.scaffoldLightBackground,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 5),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              leading: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: const SizedBox(
                                    height: 36,
                                    width: 36,
                                    child: Icon(
                                        Icons.video_camera_back_rounded)),
                              ),
                              title: const AppText("Video"),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minLeadingWidth: 30,
                              onTap: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.video,
                                );
                              },
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16),
                              tileColor: globalSetting.isDarkTheme
                                  ? AppConstants.textColor[800]
                                  : AppConstants.scaffoldLightBackground,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 5),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              leading: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: const SizedBox(
                                    height: 36,
                                    width: 36,
                                    child: Icon(Icons.audio_file_rounded)),
                              ),
                              title: const AppText("Audio"),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minLeadingWidth: 30,
                              onTap: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.audio,
                                );
                              },
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16),
                              tileColor: globalSetting.isDarkTheme
                                  ? AppConstants.textColor[800]
                                  : AppConstants.scaffoldLightBackground,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 5),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              leading: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: const SizedBox(
                                    height: 36,
                                    width: 36,
                                    child: Icon(Icons.attachment_rounded)),
                              ),
                              title: const AppText("Document"),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minLeadingWidth: 30,
                              onTap: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.any,
                                );
                              },
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16),
                              tileColor: globalSetting.isDarkTheme
                                  ? AppConstants.textColor[800]
                                  : AppConstants.scaffoldLightBackground,
                            ),
                          ),
                        ],
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  _chatInput(BuildContext context) {

    final chatProvider = context.read<ChatProvider>();
    final globalSetting = context.read<GlobalSettingProvider>();
    final searchAtSignUserProvider = context.read<SearchUserProvider>();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Card(
            elevation: 0,
            margin: const EdgeInsets.all(6),
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(14)),
            clipBehavior:
            Clip.antiAliasWithSaveLayer,
            child: InkWell(
              onTap: chatProvider.emojiToggle,
              child: const SizedBox(
                  height: 36,
                  width: 36,
                  child: Icon(Icons
                      .emoji_emotions_outlined)),
            ),
          ),
          // AnimatedSize(
          //   duration:
          //       const Duration(milliseconds: 300),
          //   curve: Curves.fastOutSlowIn,
          //   child: Container(
          //     child: chatProvider.showSendChat
          //         ? null
          //         : Card(
          //             elevation: 0,
          //             color: globalSetting
          //                     .isDarkTheme
          //                 ? AppConstants
          //                     .textColor[900]
          //                 : AppConstants
          //                     .scaffoldLightBackground,
          //             margin: const EdgeInsets
          //                 .symmetric(vertical: 6),
          //             shape: RoundedRectangleBorder(
          //                 borderRadius:
          //                     BorderRadius.circular(
          //                         14)),
          //             clipBehavior: Clip
          //                 .antiAliasWithSaveLayer,
          //             child: InkWell(
          //               onTap: chatProvider
          //                   .emojiToggle,
          //               child: const SizedBox(
          //                   height: 36,
          //                   width: 36,
          //                   child: Icon(Icons
          //                       .emoji_food_beverage_outlined)),
          //             ),
          //           ),
          //   ),
          // ),
          Expanded(
            child: DetectableTextField(
              detectionRegExp: detectionRegExp(
                  hashtag: false,
                  atSign: true,
                  url: true)!,
              minLines: 1,
              onDetectionFinished:
              searchAtSignUserProvider
                  .onDetectionFinished,
              onDetectionTyped:
              searchAtSignUserProvider
                  .onDetectionTyped,
              focusNode: chatProvider.chatFocusNode,
              controller: chatProvider.chatController,
              keyboardType: TextInputType.multiline,
              textInputAction:
              TextInputAction.newline,
              maxLines: 6,
              decoration: const InputDecoration(
                  hintText: "Message",
                  border: InputBorder.none),
            ),),

          AnimatedSize(
            duration:
            const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            child: Container(
              child: chatProvider.showSendChat
                  ? null
                  : Card(
                elevation: 0,
                color: globalSetting
                    .isDarkTheme
                    ? AppConstants
                    .textColor[600]
                    : AppConstants
                    .scaffoldLightBackground,
                margin: const EdgeInsets
                    .all(6),
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                        14)),
                clipBehavior: Clip
                    .antiAliasWithSaveLayer,
                child: InkWell(
                  onTap: chatProvider
                      .shareFileToggle,
                  child: const SizedBox(
                    height: 36,
                    width: 36,
                    child: Icon(Icons
                        .attach_file_outlined,),),
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () => chatProvider.emitText(room),
            onLongPress: () => chatProvider.recordStart(),
            onLongPressEnd: (s) =>
                chatProvider.recordStop(context, room),
            // child: Card(
            //   color: globalSetting
            //       .isDarkTheme
            //       ? AppConstants
            //       .textColor[900]
            //       : AppConstants
            //       .scaffoldLightBackground,
            //   shape: RoundedRectangleBorder(
            //       borderRadius:
            //       BorderRadius.circular(
            //           18)),
            //   clipBehavior: Clip.antiAliasWithSaveLayer,
            //   child: Padding(
            //     padding: const EdgeInsets.all(13.0),
            //     child: AnimatedSwitcher(
            //       duration: const Duration(milliseconds: 600),
            //       child: Icon(chatProvider.showSendChat
            //           ? Icons.send
            //           : Icons.keyboard_voice_rounded),
            //     ),
            //   ),
            // ),
            child: Card(
              elevation: 0,
              color: globalSetting
                  .isDarkTheme
                  ? AppConstants
                  .textColor[50]
                  : AppConstants
                  .textColor[800],
              margin: const EdgeInsets
                  .all(2),
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      14)),
              clipBehavior: Clip
                  .antiAliasWithSaveLayer,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(chatProvider.showSendChat
                      ? Icons.send
                      : Icons.keyboard_voice_rounded,
                    color:  globalSetting
                        .isDarkTheme
                        ? AppConstants.textColor[800]:AppConstants.textColor[200],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
