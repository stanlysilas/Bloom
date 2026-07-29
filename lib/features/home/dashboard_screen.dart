import 'dart:async';

import 'package:bloom/features/home/widgets/calendar_header.dart';
import 'package:bloom/features/home/widgets/overview_data.dart';
import 'package:bloom/models/dashboard_card_layout.dart';
import 'package:bloom/services/firebase/data_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  final bool isAndroid;
  const DashboardScreen({super.key, required this.isAndroid});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final dataService = DataService();
  DateTime selectedDay = DateTime.now();
  final ScrollController scrollController = ScrollController();
  Timer? _timer;
  bool displayNoInternet = false;
  Stream<DashboardData>? _dashboardStream;

  @override
  void initState() {
    super.initState();

    _dashboardStream = dataService.dashboardStream(selectedDay);

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      bool connected = await hasInternet();
      if (mounted) {
        setState(() => displayNoInternet = !connected);
      }
    });
  }

  Future<bool> hasInternet() async {
    try {
      if (kIsWeb) {
        return true;
      } else {
        final response = await http.head(Uri.parse('https://google.com'));
        return response.statusCode == 200;
      }
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: StreamBuilder<DashboardData>(
          stream: _dashboardStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            final isCompletelyEmpty = data!.isEventEmpty &&
                data.isTaskEmpty &&
                data.numberOfEntries == 0 &&
                data.numberOfHabits == 0;

            return CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: false,
                  expandedHeight: 170,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: [
                        GreetingSection(data: data),
                        OverviewSection(data: data)
                      ],
                    ),
                  ),
                ),
                CalendarHeader(
                    selectedDay: selectedDay,
                    onDayChanged: (DateTime newDate) {
                      setState(() {
                        selectedDay = newDate;
                        _dashboardStream = dataService.dashboardStream(newDate);
                      });
                    }),
                SliverList(
                    delegate: SliverChildListDelegate([
                  displayNoInternet == true
                      ? const NoInternet()
                      : isCompletelyEmpty
                          ? const EmptyContent()
                          : DashboardContent(
                              data: data, selectedDay: selectedDay)
                ]))
              ],
            );
          }),
    );
  }
}

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 14.0, right: 14.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
              height: 250,
              width: 250,
              image: AssetImage('assets/images/deviceOffline.png'),
            ),
            Text(
              'Nothing to see here',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Lost connection to the internet',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class GreetingSection extends StatefulWidget {
  final DashboardData? data;
  const GreetingSection({super.key, required this.data});

  @override
  State<GreetingSection> createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<GreetingSection> {
  final user = FirebaseAuth.instance.currentUser;
  String? profilePicture;
  String? email;
  String? userName = '';
  bool? isImageNetwork;
  bool? isFirstTime;

  @override
  void initState() {
    super.initState();
    fetchAccountData();
  }

  void fetchAccountData() async {
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      setState(() {
        profilePicture = data?['profilePicture'];
        email = data?['email'] ?? user?.email;
        userName = data?['userName'] ?? '';
        isImageNetwork = data?['isImageNetwork'];
        isFirstTime = data?['isFirstTime'] ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    final dailyProgressValue = widget.data?.dailyProgressValue ?? 0.0;
    final progressPercentage = (dailyProgressValue * 100).toStringAsFixed(0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTime.now().hour < 12
                    ? "Good morning"
                    : DateTime.now().hour < 17
                        ? "Good afternoon"
                        : "Good evening",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500),
              ),
              Text(
                userName == null || userName == ''
                    ? user!.email!.substring(0, 8)
                    : userName!,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                progressPercentage == '100' ? '✅' : '$progressPercentage%',
                style: const TextStyle(fontSize: 12),
              ),
              CircularProgressIndicator(
                value: dailyProgressValue,
                backgroundColor: color.surfaceContainer,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class OverviewSection extends StatelessWidget {
  final DashboardData? data;
  const OverviewSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Row(
        children: [
          Expanded(child: TaskData(numberOfTasks: data?.pendingTasks ?? 0)),
          Expanded(child: HabitData(numberOfHabits: data?.numberOfHabits ?? 0)),
          Expanded(
              child: SchedulesData(
                  numberOfSchedules: data?.numberOfSchedules ?? 0)),
          Expanded(
              child: EntriesData(numberOfEntries: data?.numberOfEntries ?? 0)),
        ],
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final DashboardData? data;
  final DateTime selectedDay;

  const DashboardContent({
    super.key,
    required this.data,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: DashboardCardLayout(focusedDay: selectedDay),
      ),
    );
  }
}

class EmptyContent extends StatelessWidget {
  const EmptyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 14.0, right: 14.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
              height: 250,
              width: 250,
              image: AssetImage('assets/images/allCompletedBackground.png'),
            ),
            Text(
              'Nothing to see here',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Click on the + icon to add a new object',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}
