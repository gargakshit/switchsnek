import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { UP, DOWN, RIGHT, LEFT }

class SnekScreen extends StatefulWidget {
  @override
  _SnekScreenState createState() => _SnekScreenState();
}

class _SnekScreenState extends State<SnekScreen> {
  final gridKey = GlobalKey();

  int numSwitches = 20;
  int crossAxisCount = 10;
  int mainAxisCount = 2;

  final switchWidth = 59.0;
  final switchHeight = 34.0;

  List<int> snek = [];
  int fwood = 0;

  Timer? timer;
  bool gameOver = false;
  bool gameStarted = false;

  Direction direction = Direction.RIGHT;

  final gridFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      calculateSize();
    });
  }

  void calculateSize() {
    final gridSize = gridKey.currentContext!.size!;

    final crossAxis = gridSize.width ~/ switchWidth;
    final mainAxis = gridSize.height ~/ switchHeight;

    final squares = crossAxis * mainAxis;

    setState(() {
      numSwitches = squares - crossAxis - (squares % crossAxis);

      crossAxisCount = crossAxis;
      mainAxisCount = mainAxis;

      fwood = Random.secure().nextInt(numSwitches);

      // start from 2nd row, 2nd col
      snek = List.generate(4, (i) => crossAxis + 2 + i);
    });
  }

  void startGame() {
    FocusScope.of(context).requestFocus(gridFocus);

    setState(() {
      gameStarted = true;

      timer = Timer.periodic(
        const Duration(milliseconds: 200),
        (timer) {
          updateSnek();

          if (gameOver) {
            timer.cancel();
            // show the end screen
          }
        },
      );
    });
  }

  final upKey = 4295426130;
  final downKey = 4295426129;
  final leftKey = 4295426128;
  final rightKey = 4295426127;

  void processKeyboardEvent(RawKeyEvent event) {
    if (!gameStarted) {
      return;
    }

    if (event.runtimeType != RawKeyDownEvent) {
      return;
    }

    final keyId = event.logicalKey.keyId;

    if (keyId == upKey && direction != Direction.DOWN) {
      setState(() {
        direction = Direction.UP;
      });
    } else if (keyId == downKey && direction != Direction.UP) {
      setState(() {
        direction = Direction.DOWN;
      });
    } else if (keyId == rightKey && direction != Direction.LEFT) {
      setState(() {
        direction = Direction.RIGHT;
      });
    } else if (keyId == leftKey && direction != Direction.RIGHT) {
      setState(() {
        direction = Direction.LEFT;
      });
    }
  }

  void updateSnek() {
    setState(() {
      final last = snek.last;

      switch (direction) {
        case Direction.RIGHT:
          if ((last + 1) % crossAxisCount == 0) {
            gameOver = true;
          } else {
            snek.add(last + 1);
            snek.removeAt(0);
          }

          break;

        case Direction.DOWN:
          if (last > numSwitches - crossAxisCount) {
            gameOver = true;
          } else {
            snek.add(last + crossAxisCount);
            snek.removeAt(0);
          }

          break;

        case Direction.LEFT:
          if (last % crossAxisCount == 0) {
            gameOver = true;
          } else {
            snek.add(last - 1);
            snek.removeAt(0);
          }

          break;

        case Direction.UP:
          if (last < crossAxisCount) {
            gameOver = true;
          } else {
            snek.add(last - crossAxisCount);
            snek.removeAt(0);
          }

          break;

        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: gridFocus,
        onKey: processKeyboardEvent,
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          key: gridKey,
          childAspectRatio: switchWidth / switchHeight,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            numSwitches,
            (i) {
              final has = snek.contains(i);
              final isFwood = fwood == i;

              return SizedBox(
                width: switchWidth,
                height: switchHeight,
                child: Theme(
                  data: isFwood
                      ? ThemeData(
                          primarySwatch: Colors.red,
                        )
                      : Theme.of(context),
                  child: Switch(
                    onChanged: (_) {},
                    value: has || isFwood,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 40,
        child: gameStarted
            ? Container()
            : ElevatedButton(
                onPressed: () {
                  startGame();
                },
                child: const Text('START'),
              ),
      ),
    );
  }

  @override
  void dispose() {
    gridFocus.dispose();
    timer?.cancel();

    super.dispose();
  }
}
