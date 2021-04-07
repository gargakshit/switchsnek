import 'package:flutter/material.dart';

class SwipeConfiguration {
  double verticalSwipeMaxWidthThreshold;
  double verticalSwipeMinDisplacement;
  double verticalSwipeMinVelocity;

  double horizontalSwipeMaxHeightThreshold;
  double horizontalSwipeMinDisplacement;
  double horizontalSwipeMinVelocity;

  SwipeConfiguration({
    this.verticalSwipeMaxWidthThreshold = 50,
    this.verticalSwipeMinDisplacement = 100,
    this.verticalSwipeMinVelocity = 300,
    this.horizontalSwipeMaxHeightThreshold = 50,
    this.horizontalSwipeMinDisplacement = 100,
    this.horizontalSwipeMinVelocity = 300,
  });
}

class SwipeDetector extends StatelessWidget {
  final Widget child;
  final Function() onSwipeUp;
  final Function() onSwipeDown;
  final Function() onSwipeLeft;
  final Function() onSwipeRight;
  final SwipeConfiguration swipeConfiguration;

  const SwipeDetector({
    required this.child,
    required this.onSwipeUp,
    required this.onSwipeDown,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.swipeConfiguration,
  });

  @override
  Widget build(BuildContext context) {
    DragStartDetails? startVerticalDragDetails;
    DragUpdateDetails? updateVerticalDragDetails;

    DragStartDetails? startHorizontalDragDetails;
    DragUpdateDetails? updateHorizontalDragDetails;

    return GestureDetector(
      onVerticalDragStart: (dragDetails) {
        startVerticalDragDetails = dragDetails;
      },
      onVerticalDragUpdate: (dragDetails) {
        updateVerticalDragDetails = dragDetails;
      },
      onVerticalDragEnd: (endDetails) {
        double dx = updateVerticalDragDetails!.globalPosition.dx -
            startVerticalDragDetails!.globalPosition.dx;
        double dy = updateVerticalDragDetails!.globalPosition.dy -
            startVerticalDragDetails!.globalPosition.dy;
        final velocity = endDetails.primaryVelocity!;

        //Convert values to be positive
        if (dx < 0) dx = -dx;
        if (dy < 0) dy = -dy;
        final positiveVelocity = velocity < 0 ? -velocity : velocity;

        if (dx > swipeConfiguration.verticalSwipeMaxWidthThreshold) return;
        if (dy < swipeConfiguration.verticalSwipeMinDisplacement) return;
        if (positiveVelocity < swipeConfiguration.verticalSwipeMinVelocity) {
          return;
        }

        if (velocity < 0) {
          onSwipeUp();
        } else {
          onSwipeDown();
        }
      },
      onHorizontalDragStart: (dragDetails) {
        startHorizontalDragDetails = dragDetails;
      },
      onHorizontalDragUpdate: (dragDetails) {
        updateHorizontalDragDetails = dragDetails;
      },
      onHorizontalDragEnd: (endDetails) {
        double dx = updateHorizontalDragDetails!.globalPosition.dx -
            startHorizontalDragDetails!.globalPosition.dx;
        double dy = updateHorizontalDragDetails!.globalPosition.dy -
            startHorizontalDragDetails!.globalPosition.dy;
        final velocity = endDetails.primaryVelocity!;

        if (dx < 0) dx = -dx;
        if (dy < 0) dy = -dy;
        final positiveVelocity = velocity < 0 ? -velocity : velocity;

        if (dx < swipeConfiguration.horizontalSwipeMinDisplacement) return;
        if (dy > swipeConfiguration.horizontalSwipeMaxHeightThreshold) return;
        if (positiveVelocity < swipeConfiguration.horizontalSwipeMinVelocity) {
          return;
        }

        if (velocity < 0) {
          onSwipeLeft();
        } else {
          onSwipeRight();
        }
      },
      child: child,
    );
  }
}
