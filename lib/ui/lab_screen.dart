import 'package:flutter/material.dart';

class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Preset Laboratory'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Zones'),
              Tab(text: 'Scales'),
              Tab(text: 'Audio'),
              Tab(text: 'Rules'),
            ],
          ),
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


