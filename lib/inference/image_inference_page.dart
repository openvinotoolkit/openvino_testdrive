import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/header.dart';
import 'package:inference/inference/batch_inference.dart';
import 'package:inference/inference/live_inference.dart';
import 'package:inference/inference/model_info.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/image_inference_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:provider/provider.dart';

class ImageInferencePage extends StatefulWidget {
  final Project project;
  const ImageInferencePage(this.project, {super.key});

  @override
  State<ImageInferencePage> createState() => _ImageInferencePageState();
}

class _ImageInferencePageState extends State<ImageInferencePage>
    with TickerProviderStateMixin {
  late TabController _tabController;


  void onBack(BuildContext context) {
    final inference = Provider.of<ImageInferenceProvider>(context, listen: false);
    if (inference.isLocked) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Batch inference'),
          content: const Text('Batch inference is running currently.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
          ],
        )
      );
    } else {
      context.go('/');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, animationDuration: Duration.zero, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<PreferenceProvider, ImageInferenceProvider>(
        lazy: false,
        create: (_) {
          final device = Provider.of<PreferenceProvider>(context, listen: false).device;
          return ImageInferenceProvider(widget.project, device);
        },
        update: (_, preferences, imageInferenceProvider) {
          if (imageInferenceProvider != null && imageInferenceProvider.device == preferences.device) {
            return imageInferenceProvider;
          }
          return ImageInferenceProvider(widget.project, preferences.device);
        },
        child: Scaffold(
          appBar: Header(true, onBack: (context) => onBack(context)),
          body: Padding(
            padding: const EdgeInsets.only(left: 58, right: 58, bottom: 30),
            child: Consumer<ProjectProvider>(builder: (context, projects, child) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModelInfo(widget.project, children: [
                    PropertyItem(
                      name: "Task",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.project.tasks.map((task) => PropertyValue(task.name)).toList()
                      )
                    ),
                  ]),
                  (
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 35, left: 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              controller: _tabController,
                              tabs: const [
                                Tab(text: "Live inference"),
                                Tab(text: "Batch inference"),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    LiveInference(widget.project),
                                    const BatchInference(),
                                  ]),
                            )
                          ],
                        ),
                      ),
                    )
                  )
                ],
              );
            }),
          ),
        ));
  }
}
