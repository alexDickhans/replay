import 'dart:convert';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:replay/dataStructure/positionTimestamp.dart';
import 'dataStructure/position.dart';
import 'dataStructure/positionList.dart';
import 'field_drawer.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Replay Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<(PositionList, double)> positionLists = [];
  List<List<Position>> paths = [];

  double _play_mult = 0.0;
  Duration _duration = const Duration();
  Duration lastTime = const Duration();

  List<double> savedTime = [];

  @override
  void initState() {
    super.initState();
    _scheduleTick();
  }

  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
  }

  void _openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true);
    if (result != null) {
      for (var file in result.files) {
        File f = File(file.path!);
        String contents = await f.readAsString();
        Map<String, dynamic> json = await jsonDecode(contents);
        setState(() {
          positionLists.add((PositionList.fromJson(json), 0.0));
          savedTime.add(0.0);
        });
      }
    }
  }

  void _scheduleTick() {
    SchedulerBinding.instance.scheduleFrameCallback((timestamp) {
      frameCallback(timestamp);
    });
  }

  void frameCallback(Duration timeinfo) {
    Duration interval = timeinfo - lastTime;
    lastTime = timeinfo;

    if (_play_mult != 0.0) {
      // Update the countdown value and decrement by 1 second
      setState(() {
        // Update the time for each of the positionLists
        for (int i = 0; i < positionLists.length; i++) {
          if (positionLists[i].$2 < positionLists[i].$1.maxTime()) {
            positionLists[i] = (
              positionLists[i].$1,
              positionLists[i].$2 +
                  _play_mult * interval.inMilliseconds / 1000.0
            );
          }
        }
      });
    }
    _scheduleTick();
  }

  @override
  Widget build(BuildContext context) {
    // Get the list of robots from positionLists at time t
    List<List<Position>> robots =
        positionLists.map((e) => e.$1.getPositions(e.$2)).toList();

    for (int i = 0; i < robots.length; i++) {
      if (robots[i].length == 1) {
        // check to make sure there are enough paths
        while (paths.length <= i) {
          paths.add([]);
        }

        paths[i].add(robots[i][0]);
      }
    }

    bool playing = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: DropTarget(
        onDragDone: (details) async {
          if (details.files.isNotEmpty) {
            // Go through each item and add it to the list
            for (var i = 0; i < details.files.length; i++) {
              File file = File(details.files[i].path);
              String contents = await file.readAsString();
              Map<String, dynamic> json = await jsonDecode(contents);
              setState(() {
                positionLists.add((PositionList.fromJson(json), 0.0));
                savedTime.add(0.0);
              });
            }
          }
        },
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: IconButton.filledTonal(
                                onPressed: () {
                                  // Open file
                                  _openFile();
                                },
                                icon: const Icon(Icons.add)),
                          ),
                          Expanded(
                            child: IconButton.filledTonal(
                                isSelected: _play_mult != 0.0,
                                icon: const Icon(Icons.replay),
                                selectedIcon: const Icon(Icons.pause),
                                onPressed: () {
                                  setState(() {
                                    if (_play_mult == 0.0) {
                                      _play_mult = -1.0;
                                    } else {
                                      _play_mult = 0.0;
                                    }
                                  });
                                }),
                          ),
                          Expanded(
                            child: IconButton.filledTonal(
                                isSelected: _play_mult != 0.0,
                                icon: const Icon(Icons.play_arrow),
                                selectedIcon: const Icon(Icons.pause),
                                onPressed: () {
                                  setState(() {
                                    if (_play_mult == 0.0) {
                                      _play_mult = 1.0;
                                    } else {
                                      _play_mult = 0.0;
                                    }
                                  });
                                }),
                          ),
                          Expanded(
                              child: IconButton.filledTonal(
                                  onPressed: () {
                                    setState(() {
                                      savedTime = positionLists
                                          .map((e) => e.$2)
                                          .toList();
                                    });
                                  },
                                  icon: const Icon(Icons.save))),
                          Expanded(
                              child: IconButton.filledTonal(
                                  onPressed: () {
                                    setState(() {
                                      for (int i = 0;
                                          i < positionLists.length;
                                          i++) {
                                        positionLists[i] =
                                            (positionLists[i].$1, savedTime[i]);
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.restore))),
                          Expanded(child: IconButton.filledTonal(
                              onPressed: () {
                                setState(() {
                                  paths.clear();
                                });
                              },
                              icon: const Icon(Icons.clear))),
                        ],
                      ),
                      SizedBox(
                        height: 500,
                        child: ListView.builder(
                            itemCount: positionLists.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    IconButton.filledTonal(
                                        onPressed: () {
                                          setState(() {
                                            positionLists.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete)),
                                    Expanded(
                                      child: Slider(
                                          min:
                                              positionLists[index].$1.minTime(),
                                          max:
                                              positionLists[index].$1.maxTime(),
                                          label: positionLists[index]
                                              .$2
                                              .toString(),
                                          value: positionLists[index].$2.clamp(
                                              positionLists[index].$1.minTime(),
                                              positionLists[index]
                                                  .$1
                                                  .maxTime()),
                                          onChanged: (value) {
                                            setState(() {
                                              positionLists[index] = (
                                                positionLists[index].$1,
                                                value
                                              );
                                            });
                                          }),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Image.asset("assets/empty.png"),
                  CustomPaint(
                    size: Size.infinite,
                    painter: PathDrawer(robots, paths),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
