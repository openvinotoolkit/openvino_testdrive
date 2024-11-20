import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/public_models.dart';
import 'package:inference/theme_fluent.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

String formatBytes(int bytes) {
  return "${NumberFormat("#,##0").format(bytes / pow(1024, 2))} MB";
}

class DownloadModelPage extends StatefulWidget {
  final PublicProject project;
  const DownloadModelPage({super.key, required this.project});
  @override
  _DownloadModelPageState createState() => _DownloadModelPageState();
}

class _DownloadModelPageState extends State<DownloadModelPage> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      Future.microtask(() { startDownload(); });
    }
  }

  void startDownload() async {
    final downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final router = GoRouter.of(context);
    late Map<String, String> files;

    projectProvider.addProject(widget.project);

    try {
      files = await downloadFiles(widget.project);
    } catch (e) {
      await showDialog(context: context, builder: (BuildContext context) => ContentDialog(
        title: const Text('Model was not found'),
        actions: [
          Button(
            onPressed: () {
              router.canPop() ? router.pop() : router.go('/home');
            },
            child: const Text('Close'),
          ),
        ],
      ));
      return;
    }

    try {
      await downloadProvider.queue(files, widget.project.modelInfo?.collection.token);
      await getAdditionalModelInfo(widget.project);
      projectProvider.completeLoading(widget.project);
      router.go("/models/inference", extra: widget.project);
    } catch(e) {
      if (mounted) {
        await showDialog(context: context, builder: (BuildContext context) => ContentDialog(
          title: Text('An error occurred trying to download ${widget.project.name}'),
          content: Text(e.toString()),
          actions: [
            Button(
              onPressed: () {
                router.canPop() ? router.pop() : router.go('/home');
              },
              child: const Text('Close'),
            ),
          ],
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return ScaffoldPage(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
      header: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: theme.resources.controlStrokeColorDefault,
                    width: 1.0
                )
            )
          ),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: widget.project.thumbnailImage(),
                            fit: BoxFit.fitWidth),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(widget.project.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Button(child: const Text("Close"), onPressed: () {
              GoRouter.of(context).canPop() ? GoRouter.of(context).pop() : GoRouter.of(context).go('/home');
            }),
          ],
        ),
      ),
      content: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<DownloadProvider>(builder: (context, downloadProvider, child) {
                    final stats = downloadProvider.stats;
                    return Column(
                      children: [
                        ProgressRing(
                          value: stats.percentage * 100,
                          strokeWidth: 8,
                        ),
                        SizedBox(
                            width: 140,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(formatBytes(stats.received), textAlign: TextAlign.end,),
                                  const Text("/"),
                                  Text(formatBytes(stats.total))
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Downloading model weights"),
                          )
                      ]
                    );
                  }
                ),
                )
              ],
            ),
          ),
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.resources.controlStrokeColorDefault,
                  width: 1.0,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.0),
                    child: Text("Model parameters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text("Model name", style: TextStyle(fontSize: 14),),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 4),
                    child: Text(widget.project.modelId, style: const TextStyle(fontSize: 14, color: foreground3Color),),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 16),
                    child: Text("Task", style: TextStyle(fontSize: 14),),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 4),
                    child: Text(widget.project.taskName(), style: const TextStyle(fontSize: 14, color: foreground3Color),),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
