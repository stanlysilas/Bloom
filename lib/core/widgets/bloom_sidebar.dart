import 'package:bloom/core/widgets/bloom_buttons.dart';
import 'package:bloom/features/profile/profile_screen.dart';
import 'package:bloom/models/user_model.dart';
import 'package:bloom/services/firebase/user_profile_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BloomSidebar extends StatefulWidget {
  final Function(int index) onItemSelected;
  final int selectedIndex;
  const BloomSidebar(
      {super.key, required this.onItemSelected, required this.selectedIndex});

  @override
  State<BloomSidebar> createState() => _BloomSidebarState();
}

class _BloomSidebarState extends State<BloomSidebar> {
  bool extended = true;
  void _openCreateModal() {
    switch (widget.selectedIndex) {
      case 3:
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          useSafeArea: true,
          builder: (_) => TypesOfObjects(),
        );
        break;
      case 1:
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          useSafeArea: true,
          builder: (_) => GoalObjectsModalSheet(),
        );
        break;
      case 2:
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (_) => _EntriesSheet(),
        );
        break;
      default:
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          useSafeArea: true,
          builder: (_) => TypesOfObjects(),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_SidebarItem> items = [
      _SidebarItem(
        icon: Icon(Icons.home, size: 20),
        title: Text('Home', overflow: TextOverflow.ellipsis),
        index: 0,
        selectedIndex: widget.selectedIndex,
        onItemSelected: widget.onItemSelected,
        extended: extended,
        suffixIcon: null,
      ),
      _SidebarItem(
        icon: Icon(Icons.task, size: 20),
        title: Text('Goals', overflow: TextOverflow.ellipsis),
        index: 1,
        selectedIndex: widget.selectedIndex,
        onItemSelected: widget.onItemSelected,
        extended: extended,
        suffixIcon: null,
      ),
      _SidebarItem(
        icon: Icon(Icons.widgets, size: 20),
        title: Text('Objects', overflow: TextOverflow.ellipsis),
        index: 2,
        selectedIndex: widget.selectedIndex,
        onItemSelected: widget.onItemSelected,
        extended: extended,
        suffixIcon: null,
      ),
      _SidebarItem(
        icon: Icon(Icons.calendar_month, size: 20),
        title: Text('Calendar', overflow: TextOverflow.ellipsis),
        index: 3,
        selectedIndex: widget.selectedIndex,
        onItemSelected: widget.onItemSelected,
        extended: extended,
        suffixIcon: null,
      ),
      _SidebarItem(
        icon: Icon(Icons.settings, size: 20),
        title: Text('Settings', overflow: TextOverflow.ellipsis),
        index: 4,
        selectedIndex: widget.selectedIndex,
        onItemSelected: widget.onItemSelected,
        extended: extended,
        suffixIcon: null,
      ),
    ];

    return AnimatedContainer(
      width: extended ? 256 : 72,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(16), bottomRight: Radius.circular(16))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: BloomIconButton(
                    onTap: () => setState(() => extended = !extended),
                    icon: Icon(
                      Icons.menu_open,
                      size: 20,
                    )),
              ),
              if (extended) const Spacer(),
              if (extended)
                Expanded(
                  child: BloomIconButton(
                    onTap: () => _openCreateModal(),
                    icon: Icon(
                      Icons.add,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          SingleChildScrollView(
              child: Column(
            children: items,
          )),
          const Spacer(),
          _SidebarProfileButton(
            extended: extended,
          )
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final Icon icon;
  final Widget title;
  final Icon? suffixIcon;
  final int index;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool extended;
  const _SidebarItem(
      {required this.icon,
      required this.title,
      required this.suffixIcon,
      required this.index,
      required this.selectedIndex,
      required this.onItemSelected,
      required this.extended});

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    final isSelected = widget.index == widget.selectedIndex;
    final backgroundColor = isSelected
        ? color.surfaceContainer
        : _hovered
            ? color.surfaceContainer
            : color.surfaceContainer.withValues(alpha: 0.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onItemSelected(widget.index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
              color: backgroundColor, borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 6,
            children: [
              widget.icon,
              if (widget.extended) Expanded(child: widget.title),
              if (widget.suffixIcon != null && !widget.extended)
                widget.suffixIcon!,
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarProfileButton extends StatelessWidget {
  final bool extended;
  const _SidebarProfileButton({required this.extended});

  @override
  Widget build(BuildContext context) {
    final userProfileService = UserProfileService();

    return StreamBuilder<UserModel?>(
      stream: userProfileService.watchUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        return _SidebarProfileContent(
          user: snapshot.data!,
          extended: extended,
        );
      },
    );
  }
}

class _SidebarProfileContent extends StatefulWidget {
  final bool extended;
  final UserModel user;
  const _SidebarProfileContent({required this.user, required this.extended});

  @override
  State<_SidebarProfileContent> createState() => _SidebarProfileContentState();
}

class _SidebarProfileContentState extends State<_SidebarProfileContent> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    final extended = widget.extended;
    final backgroundColor = _hovered
        ? color.surfaceContainer
        : color.surfaceContainer.withValues(alpha: 0.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProfileScreen(
                isImageNetwork: widget.user.isImageNetwork,
                profilePicture: widget.user.profilePicture,
                userName: widget.user.userName,
                uid: widget.user.uid,
                email: widget.user.email,
                mode: ProfileMode.display))),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 6,
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.user.profilePicture,
                  height: 28,
                  width: 28,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return Skeletonizer(child: SizedBox(height: 28, width: 28));
                  },
                ),
              ),
              if (extended)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.userName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.user.email,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: color.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class _EntriesSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Expanded(child: TypesOfEntries()),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
