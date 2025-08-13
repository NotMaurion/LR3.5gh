import 'package:flutter/material.dart';

class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: const Text('Preset Laboratory'),
          bottom: const _StyledTabBar(),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Zones')),
            Center(child: Text('Scales')),
            Center(child: Text('Audio')),
            Center(child: Text('Rules')),
          ],
        ),
      ),
    );
  }
}

class _StyledTabBar extends StatelessWidget {
  const _StyledTabBar();

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFFFFC107); // bright gold/orange
    return TabBar(
      isScrollable: true,
      indicatorColor: accent,
      labelColor: accent,
      unselectedLabelColor: Colors.grey,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'Zones'),
        Tab(text: 'Scales'),
        Tab(text: 'Audio'),
        Tab(text: 'Rules'),
      ],
    );
  }
}


