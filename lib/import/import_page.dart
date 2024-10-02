import 'package:flutter/material.dart';
import 'package:inference/header.dart';
import 'package:inference/import/public_model.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, animationDuration: Duration.zero, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: Header(false),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: PublicModelPage()
      ),
    );
  }
}
