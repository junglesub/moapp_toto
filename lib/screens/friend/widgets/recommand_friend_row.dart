import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:moapp_toto/models/notification_entity.dart';
import 'package:moapp_toto/models/user_entity.dart';
import 'package:moapp_toto/provider/user_provider.dart';
import 'package:moapp_toto/screens/friend/widgets/find_friend.dart';
import 'package:provider/provider.dart';

class RecommandFriendRow extends StatefulWidget {
  final List<UserEntry?> friends;
  const RecommandFriendRow({Key? key, required this.friends}) : super(key: key);

  @override
  State<RecommandFriendRow> createState() => _RecommandFriendRowState();
}

class _RecommandFriendRowState extends State<RecommandFriendRow> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    UserProvider up = context.watch();
    return Column(
      children: [
        CarouselSlider(
          items: widget.friends.map((friend) {
            if (friend == null) return Container();
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    up.ue?.addFollowing(friend.uid);
                    NotificationEntity(
                            id: null,
                            code: "addFriend",
                            from: up.ue,
                            to: friend,
                            title: "새로운 팔로워가 있습니다.",
                            message: "${up.ue?.nickname}님이 당신을 팔로우 합니다.")
                        .save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${friend.nickname ?? friend.uid} 팔로우 시작')),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person, size: 48),
                          const SizedBox(height: 8),
                          Text(friend.nickname ?? friend.email ?? friend.uid),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
          carouselController: _controller,
          options: CarouselOptions(
            height: 200.0,
            enableInfiniteScroll: false,
            enlargeCenterPage: false,
            viewportFraction: 0.4,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.friends.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
