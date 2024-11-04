import 'dart:convert';

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

  bool _play = false;
  Duration _duration = const Duration();
  Duration lastTime = const Duration();

  @override
  void initState() {
    super.initState();
    _scheduleTick();
  }

  void _openFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result != null) {
      File file = File(result.files.single.path!);
      String contents = await file.readAsString();
      Map<String, dynamic> json = await jsonDecode(contents);
      setState(() {
        positionLists.add((PositionList.fromJson(json), 0.0));
      });
    }
  }

  void startTimer() {
    _play = true;
  }

  void _scheduleTick() {
    SchedulerBinding.instance.scheduleFrameCallback((timestamp) {
      frameCallback(timestamp);
    });
  }

  void stopTimer() {
    _play = false;
  }

  void frameCallback(Duration timeinfo) {
    Duration interval = timeinfo - lastTime;
    lastTime = timeinfo;

    print("frameCallback");

    if (_play) {
      // Update the countdown value and decrement by 1 second
      setState(() {
        // Update the time for each of the positionLists
        for (int i = 0; i < positionLists.length; i++) {
          if (positionLists[i].$2 < positionLists[i].$1.maxTime()) {
            positionLists[i] = (positionLists[i].$1, positionLists[i].$2 + interval.inMilliseconds / 1000.0);
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

    bool playing = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Row(
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
                        IconButton.filledTonal(
                            isSelected: _play,
                            icon: const Icon(Icons.play_arrow),
                            selectedIcon: const Icon(Icons.pause),
                            onPressed: () {
                              setState(() {
                                if (!_play) {
                                  startTimer();
                                } else {
                                  stopTimer();
                                }
                              });
                            }),
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
                                        min: positionLists[index].$1.minTime(),
                                        max: positionLists[index].$1.maxTime(),
                                        label:
                                            positionLists[index].$2.toString(),
                                        value: positionLists[index].$2.clamp(
                                            positionLists[index].$1.minTime(),
                                            positionLists[index].$1.maxTime()),
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
                  painter: PathDrawer(robots),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
