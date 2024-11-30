import 'package:flutter/material.dart';
import 'package:moapp_toto/widgets/botttom_nav_bar.dart';

int _currentIndex = 3;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, String>> notifications = [
    {'title': '찌르기 알림', 'subtitle': '코딩의 정석씨가 당신을 찔렀습니다', 'timestamp': '5분 전'},
    {
      'title': '새로운 팔로워가 있습니다.',
      'subtitle': '김씨가 당신을 팔로우 합니다.',
      'timestamp': '1시간 전'
    },
    {'title': '미션 성공!', 'subtitle': '투투 티켓을 수령했습니다.', 'timestamp': '어제'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(notification['title']!),
            direction: DismissDirection.horizontal,
            background: Container(
              color: Colors.white,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onDismissed: (direction) {
              setState(() {
                notifications.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('알림이 삭제되었습니다.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.notifications),
                ),
                title: Text(notification['title']!),
                subtitle: Text(
                    '${notification['subtitle']} • ${notification['timestamp']}'),
                onTap: () {
                  // 알림 클릭 시 동작
                  print('알림 클릭: ${notification['title']}');
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          print("Selected tab: $index");
        },
        notificationCount: notifications.length, // 알림 갯수 전달
      ),
    );
  }
}
