import 'package:flutter/material.dart';

/// [TableCalendar] widget for [SliverPersistentHeader] as a Persistent [AppBar].
class CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget Function(BuildContext, double) childBuilder;

  CalendarHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.childBuilder,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return childBuilder(context, shrinkOffset);
  }

  @override
  bool shouldRebuild(CalendarHeaderDelegate oldDelegate) {
    return oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.childBuilder != childBuilder;
  }
}
