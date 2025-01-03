import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:moapp_toto/models/notification_entity.dart';
import 'package:moapp_toto/models/toto_entity.dart';
import 'package:moapp_toto/models/user_entity.dart';
import 'package:moapp_toto/provider/toto_provider.dart';
import 'package:moapp_toto/provider/user_provider.dart';
import 'package:moapp_toto/screens/add/location_select_screen.dart';
import 'package:moapp_toto/screens/add/tag_friends_screen.dart';
import 'package:moapp_toto/screens/add/widgets/animated_btn_widget.dart';
import 'package:moapp_toto/screens/add/widgets/text_form_filed_widget.dart';
import 'package:moapp_toto/screens/add/widgets/image_picker_widget.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:moapp_toto/utils/date_format.dart';
import 'package:moapp_toto/utils/emotions.dart';
import 'package:provider/provider.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController textController = TextEditingController();
  bool isAnalysisPage = false;
  bool isAddMode = false;
  bool isEditMode = false;
  MoodOption? selectedMood;
  LocationResult? selectedLocation;
  ToToEntity? currentToto;
  dynamic _selectedImage;
  List<Map<String, String>> selectedFriends = []; // 닉네임과 UID를 함께 저장

  void navigateToTagFriendsPage() async {
    // TagFriendsPage에서 선택된 친구의 UID와 nickname 리스트를 가져옴
    final selectedFriendDetails =
        await Navigator.push<List<Map<String, String>>>(
      context,
      MaterialPageRoute(builder: (context) => const TagFriendsPage()),
    );

    if (selectedFriendDetails != null) {
      setState(() {
        selectedFriends = selectedFriendDetails; // 선택된 친구의 닉네임 및 UID 목록
      });
    }
  }

  void _pickImage(dynamic image) async {
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  bool _isStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isStarted) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      UserProvider up = Provider.of(context, listen: false);

      if (args?['toto'] != null) {
        isAnalysisPage = true;
        isEditMode = true;
        currentToto = args?['toto'];
        textController =
            TextEditingController(text: currentToto?.description ?? "");

        _initializeTaggedFriends();
      }
      _isStarted = true;
    }
  }

  Future<void> _initializeTaggedFriends() async {
    if (currentToto?.taggedFriends != null) {
      selectedFriends = await Future.wait(
        currentToto!.taggedFriends!.map((friendId) async {
          if (friendId != null && friendId.isNotEmpty) {
            DocumentSnapshot friendDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(friendId)
                .get();
            if (friendDoc.exists) {
              return {
                'uid': friendId,
                'nickname': friendDoc['nickname'] ?? "",
                'email': friendDoc['email'] ?? "",
              };
            }
          }
          return {
            'nickname': friendId ?? "",
          };
        }),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider up = context.watch();
    TotoProvider tp = context.watch();

    if (!isEditMode && !isAnalysisPage) {
      ToToEntity? todayToto = tp.t
              .where((element) =>
                  element.creator == up.currentUser?.uid &&
                  isToday(element.created?.toDate()))
              .isNotEmpty
          ? tp.t.firstWhere((element) =>
              element.creator == up.currentUser?.uid &&
              isToday(element.created?.toDate()))
          : null;
      if (todayToto != null && !isAddMode) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('오늘의 AI 리액션'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 70.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 400,
                    child: Column(
                      children: [
                        if (todayToto.imageUrlLink != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                todayToto.imageUrlLink!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              // color: Colors.grey[300],
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  todayToto.aiReaction ??
                                      '투투를 기반으로 기분을 분석 중입니다.',
                                  style: const TextStyle(
                                    fontSize: 15,
                                  )),
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 48),
                  CustomAnimatedButton(
                    key: const ValueKey(2),
                    text: "투투 수정하러가기",
                    onPressed: () async {
                      Navigator.popAndPushNamed(context, "/add",
                          arguments: {"toto": todayToto});
                      // showDialog(
                      //   context: context,
                      //   builder: (BuildContext context) {
                      //     return AlertDialog(
                      //       title: Text(
                      //         "투투 수정",
                      //         style: const TextStyle(
                      //             fontSize: 20, fontWeight: FontWeight.w500),
                      //       ),
                      //       content: Text('투투를 수정하시겠습니까?\n티켓 포인트 ***p가 소모됩니다.'),
                      //       actions: [
                      //         TextButton(
                      //           onPressed: () {
                      //             Navigator.pop(context);
                      //           },
                      //           child: const Text('취소',
                      //               style: TextStyle(
                      //                   color: Color.fromARGB(
                      //                       255, 133, 133, 133))),
                      //         ),
                      //         TextButton(
                      //           onPressed: () {
                      //             Navigator.pop(context);
                      //             Navigator.popAndPushNamed(context, "/add",
                      //                 arguments: {"toto": todayToto});
                      //           },
                      //           child: Text("수정",
                      //               style: TextStyle(color: Colors.blue)),
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // );
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    "투투는 하루에 한번만 작성할 수 있습니다",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                      "마지막 작성: ${convertTimestampToKoreanDateTime(todayToto.created)}")
                ],
              ),
            ),
          ),
        );
      }
    }

    ToToEntity? toto = tp.findId(currentToto?.id ?? "unknown ID");

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 투투'),
        actions: isAnalysisPage
            ? [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    // 저장 버튼 클릭 시 동작 추가
                    if (toto == null) {
                      print("Save ToTo is null. Something wrong!");
                      return;
                    }

                    // Calculate New Point used
                    if (isEditMode) {
                      final pointNeeded = textController.text.length;
                      final pointNeedToTakeAway =
                          max(pointNeeded - toto.pointUsed, 0);
                      print("Need $pointNeedToTakeAway more points");
                      up.ue?.removePoint(pointNeedToTakeAway);
                    }

                    final taggedFriendUids =
                        selectedFriends.map((friend) => friend['uid']).toList();
                    ToToEntity t = ToToEntity(
                        id: toto.id,
                        name: toto.name,
                        description:
                            isEditMode ? textController.text : toto.description,
                        creator: toto.creator,
                        liked: toto.liked,
                        created: toto.created,
                        modified: toto.modified,
                        imageUrl: toto.imageUrl,
                        location: selectedLocation ?? toto.location,
                        emotion: selectedMood ?? toto.emotion,
                        taggedFriends: taggedFriendUids,
                        pointUsed:
                            max(textController.text.length, toto.pointUsed));
                    await t.save();

                    // Send notification
                    taggedFriendUids.forEach((id) {
                      if (id == null) return;
                      NotificationEntity(
                              id: null,
                              code: "taggedPost",
                              from: up.ue,
                              to: UserEntry(uid: id, gender: null),
                              title: "게시물에 태깅되었습니다.",
                              message: "${up.ue?.nickname}님이 당신을 게시물에 태깅했습니다.")
                          .save();
                    });
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/", (Route<dynamic> route) => false);
                    }
                  },
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: isAnalysisPage
                ? _buildAnalysisPage(context)
                : _buildWritingPage(context),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: isAnalysisPage
                    ? null
                    : CustomAnimatedButton(
                        key: const ValueKey(2),
                        text: "투투 등록하기",
                        onPressed: () async {
                          ToToEntity? newT;
                          ToToEntity toto = ToToEntity.empty(
                              creator: up.currentUser?.uid ?? "");

                          // Point used
                          final pointUsed = textController.text.length;

                          // 포인트 차감
                          up.ue?.removePoint(pointUsed);

                          if ((_selectedImage == null) &&
                              (textController.text.trim().isEmpty)) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('알림'),
                                  content: const Text('이미지 또는 설명이 필요합니다.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('확인'),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          // Save Logic
                          if (_selectedImage == null) {
                            newT = ToToEntity(
                                // id: product.id,
                                name: "",
                                description: textController.text,
                                creator: toto.creator,
                                created: toto.created,
                                modified: toto.modified,
                                imageUrl: toto.imageUrl,
                                liked: toto.liked,
                                pointUsed: pointUsed);
                            await newT.save();
                          } else {
                            newT = await ToToEntity.createWithImageFile(
                                id: toto.id,
                                name: "",
                                description: textController.text,
                                creator: toto.creator,
                                created: toto.created,
                                modified: toto.modified,
                                imageFile: _selectedImage!,
                                liked: toto.liked,
                                pointUsed: pointUsed);
                          }

                          // 페이지 state 변경
                          setState(() {
                            isAnalysisPage = true;
                            currentToto = newT;
                            isAddMode = true;
                          });
                        },
                      ),
              ),
            ),
          ),
          if (isAnalysisPage) _buildPersistentBottomSheet(context),
        ],
      ),
    );
  }

  Widget _buildWritingPage(BuildContext context) {
    UserProvider up = context.watch();
    return Padding(
      key: const ValueKey(1),
      padding: const EdgeInsets.only(top: 50),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
            child: Column(
              children: [
                ImagePickerWidget(parentPickImage: _pickImage),
                CustomTextFormField(
                  hintText: "오늘은 어떤 날인가요?",
                  controller: textController,
                  maxLength: up.ue?.point ?? 0,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisPage(BuildContext context) {
    TotoProvider tp = context.watch<TotoProvider>();
    UserProvider up = context.watch();

    ToToEntity? toto = tp.findId(currentToto?.id ?? "unknown ID");
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.only(top: 16),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mood와 Location 정보
                Row(
                  children: [
                    if (toto?.emotion != null || selectedMood != null)
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: Chip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedMood?.emoji ??
                                      toto?.emotion?.emoji ??
                                      "",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    selectedMood?.name ??
                                        toto?.emotion?.name ??
                                        "",
                                    style: const TextStyle(
                                      // color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                )
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (toto?.location?.placeName != null ||
                        selectedLocation != null)
                      Flexible(
                        child: Container(
                          child: Chip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  // color: Colors.black,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    selectedLocation?.placeName ??
                                        toto?.location?.placeName ??
                                        "",
                                    style: const TextStyle(
                                      // color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                )
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // 태그된 친구들 (Mood와 Location 아래로 이동)
                if (selectedFriends.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              minHeight: 45,
                              maxHeight: 45, // Height 고정
                              maxWidth: 200, // Width 제한
                            ),
                            child: Chip(
                              avatar: Icon(
                                Icons.tag,
                                // color: Colors.grey[700],
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white!
                                    : Colors.grey[700],
                                size: 16,
                              ),
                              label: Text(
                                // nickname만 추출하여 표시
                                selectedFriends
                                    .map((friend) =>
                                        friend['nickname']) // nickname 추출
                                    .join(', '), // 콤마로 구분
                                style: const TextStyle(
                                  // color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),

                // AI 분석 결과
                const SizedBox(height: 16),
                // Text(toto?.id ?? "Unknown ID"),
                if (!isEditMode)
                  Column(
                    children: [
                      const Text(
                        "오늘의 AI 리액션",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        // height: 140,
                        decoration: BoxDecoration(
                          // color: Colors.grey[300],
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]!
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedTextKit(
                              key: ValueKey(toto?.aiReaction),
                              totalRepeatCount: 1,
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  toto?.aiReaction ?? '투투를 기반으로 기분을 분석 중입니다.',
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                  ),
                                  speed: const Duration(milliseconds: 100),
                                ),
                              ],
                              pause: const Duration(milliseconds: 500),
                              displayFullTextOnTap: false,
                              stopPauseOnTap: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (isEditMode)
                  Column(
                    children: [
                      CustomTextFormField(
                        hintText: "오늘은 어떤 날인가요?",
                        controller: textController,
                        maxLines: 4,
                        maxLength: (toto?.pointUsed ?? 0) + (up.ue?.point ?? 0),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersistentBottomSheet(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0,
      maxChildSize: 0.4,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              ListTile(
                leading: const Icon(Icons.mood),
                title: const Text('기분'),
                onTap: () async {
                  MoodOption? mood = await _navigateToMoodPage(context);
                  if (mood != null) {
                    print("선택된 기분: ${mood.name}");
                    setState(() {
                      selectedMood = mood;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('위치 추가'),
                onTap: () async {
                  LocationResult? locationResult =
                      await _navigateToLocationPage(context);
                  if (locationResult != null) {
                    // print("선택된 기분: ${mood.name}");
                    setState(() {
                      selectedLocation = locationResult;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('사람 태그'),
                onTap: () {
                  navigateToTagFriendsPage();
                  // print('Returning selectedFriends: $selectedFriends');
                  // Navigator.pop(context, selectedFriends);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<MoodOption?> _navigateToMoodPage(BuildContext context) async {
    return Navigator.push<MoodOption>(
      context,
      MaterialPageRoute(
        builder: (context) => MoodSelectionPage(),
      ),
    );
  }

  Future<LocationResult?> _navigateToLocationPage(BuildContext context) async {
    return Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationSelectionPage(),
      ),
    );
  }

  // void navigateToTagFriendsPage() async {
  //   // TagFriendsPage에서 선택된 친구들의 UID 리스트를 가져옴
  //   final selectedUids = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const TagFriendsPage()),
  //   );

  //   if (selectedUids != null && selectedUids is List<String>) {
  //     // 친구들의 UID를 기반으로 닉네임을 가져옴
  //     List<String> selectedFriendNames = [];
  //     for (var uid in selectedUids) {
  //       DocumentSnapshot friendDoc =
  //           await FirebaseFirestore.instance.collection('users').doc(uid).get();

  //       if (friendDoc.exists) {
  //         selectedFriendNames.add(friendDoc['nickname']); // 닉네임 추가
  //       }
  //     }

  //     // 상태 업데이트
  //     setState(() {
  //       this.selectedFriends = selectedFriendNames; // 선택된 친구의 닉네임 목록
  //     });
  //   }
  // }
}

class MoodSelectionPage extends StatelessWidget {
  const MoodSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<MoodOption> moodOptions = MoodOption.moodOptions;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("기분 선택"),
      ),
      body: ListView.builder(
        itemCount: moodOptions.length,
        itemBuilder: (context, index) {
          final mood = moodOptions[index];
          return ListTile(
            leading: Text(mood.emoji, style: TextStyle(fontSize: 30)),
            title: Text(mood.name),
            onTap: () {
              // 선택된 기분 이름을 반환
              Navigator.pop(context, mood);
            },
          );
        },
      ),
    );
  }
}
