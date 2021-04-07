import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:switchsnek/utils/swipe.dart';

enum Direction { UP, DOWN, RIGHT, LEFT }

class SnekScreen extends StatefulWidget {
  final bool osc;

  const SnekScreen({required this.osc});

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
  String gameOverReason = '';

  Direction direction = Direction.DOWN;

  final gridFocus = FocusNode();

  final upFocus = FocusNode();
  final downFocus = FocusNode();
  final rightFocus = FocusNode();
  final leftFocus = FocusNode();

  int score = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      calculateSize();
    });
  }

  int generateFwoodLocation(int num, List<int> snek) {
    final fwood = Random.secure().nextInt(num);

    // can't have fwood on the snek
    if (snek.contains(fwood)) {
      return generateFwoodLocation(num, snek);
    }
    return fwood;
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

      // start from 2nd row, 2nd col
      snek = List.generate(4, (i) => crossAxis + 2 + i);

      fwood = generateFwoodLocation(numSwitches, snek);
    });
  }

  void startGame() {
    FocusScope.of(context).requestFocus(gridFocus);

    upFocus.unfocus();
    downFocus.unfocus();
    leftFocus.unfocus();
    rightFocus.unfocus();

    setState(() {
      gameStarted = true;

      timer = Timer.periodic(
        const Duration(milliseconds: 200),
        (timer) {
          updateSnek();

          if (gameOver) {
            timer.cancel();
            showGameOver();
          }
        },
      );
    });
  }

  void showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(gameOverReason),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('BACK'),
          ),
        ],
      ),
    );
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
      setDirection(Direction.UP);
    } else if (keyId == downKey && direction != Direction.UP) {
      setDirection(Direction.DOWN);
    } else if (keyId == rightKey && direction != Direction.LEFT) {
      setDirection(Direction.RIGHT);
    } else if (keyId == leftKey && direction != Direction.RIGHT) {
      setDirection(Direction.LEFT);
    }
  }

  void setDirection(Direction dir) {
    setState(() {
      direction = dir;
    });
  }

  void updateSnek() {
    setState(() {
      final last = snek.last;

      final snekCopy = [...snek];
      snekCopy.removeLast();

      if (snekCopy.contains(last)) {
        gameOver = true;
        gameOverReason = 'Did you try to eat yourself?';
      } else {
        switch (direction) {
          case Direction.RIGHT:
            if ((last + 1) % crossAxisCount == 0) {
              gameOver = true;
              gameOverReason = 'You hit a wall';
            } else {
              snek.add(last + 1);
            }

            break;

          case Direction.DOWN:
            if (last > numSwitches - crossAxisCount) {
              gameOver = true;
              gameOverReason = 'You hit a wall';
            } else {
              snek.add(last + crossAxisCount);
            }

            break;

          case Direction.LEFT:
            if (last % crossAxisCount == 0) {
              gameOver = true;
              gameOverReason = 'You hit a wall';
            } else {
              snek.add(last - 1);
            }

            break;

          case Direction.UP:
            if (last < crossAxisCount) {
              gameOver = true;
              gameOverReason = 'You hit a wall';
            } else {
              snek.add(last - crossAxisCount);
            }

            break;
        }
      }

      if (last == fwood) {
        fwood = generateFwoodLocation(numSwitches, snek);
        score++;
      } else {
        if (!gameOver) {
          snek.removeAt(0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SwipeDetector(
        swipeConfiguration: SwipeConfiguration(),
        onSwipeDown: () {
          setDirection(Direction.DOWN);
        },
        onSwipeUp: () {
          setDirection(Direction.UP);
        },
        onSwipeLeft: () {
          setDirection(Direction.LEFT);
        },
        onSwipeRight: () {
          setDirection(Direction.RIGHT);
        },
        child: RawKeyboardListener(
          focusNode: gridFocus,
          onKey: processKeyboardEvent,
          child: IgnorePointer(
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              key: gridKey,
              childAspectRatio: switchWidth / switchHeight,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                numSwitches,
                (i) {
                  final index = snek.indexOf(i);
                  final isFwood = fwood == i;

                  final isHead = index == snek.length - 1;

                  return SizedBox(
                    width: switchWidth,
                    height: switchHeight,
                    child: Theme(
                      data: isFwood || isHead
                          ? ThemeData(
                              primarySwatch: isHead ? Colors.blue : Colors.red,
                            )
                          : Theme.of(context),
                      child: Switch(
                        onChanged: (_) {},
                        value: index != -1 || isFwood,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 40,
        child: gameStarted
            ? (widget.osc
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Score: $score'),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setDirection(Direction.LEFT);
                        },
                        focusNode: leftFocus,
                        child: const Icon(Icons.chevron_left_outlined),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setDirection(Direction.UP);
                        },
                        focusNode: upFocus,
                        child: const Icon(Icons.keyboard_arrow_up_outlined),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setDirection(Direction.DOWN);
                        },
                        focusNode: downFocus,
                        child: const Icon(Icons.keyboard_arrow_down_outlined),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setDirection(Direction.RIGHT);
                        },
                        focusNode: rightFocus,
                        child: const Icon(Icons.chevron_right_outlined),
                      ),
                    ],
                  )
                : Center(
                    child: Text('Score: $score'),
                  ))
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

    upFocus.dispose();
    downFocus.dispose();
    leftFocus.dispose();
    rightFocus.dispose();

    timer?.cancel();

    super.dispose();
  }
}
