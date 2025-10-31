import 'package:flutter/material.dart';
import '../theme/app_theme_enhanced.dart';
import 'animated_widgets.dart';

// Enhanced App Bar
class EnhancedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final Widget? flexibleSpace;

  const EnhancedAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation = 0,
    this.flexibleSpace,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
      centerTitle: centerTitle,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      elevation: elevation,
      leading: leading,
      actions: actions?.map((action) {
        return Padding(
          padding: const EdgeInsets.only(right: AppThemeEnhanced.spaceSm),
          child: action,
        );
      }).toList(),
      flexibleSpace: flexibleSpace,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Enhanced Bottom Navigation
class EnhancedBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<EnhancedNavItem> items;

  const EnhancedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemeEnhanced.spaceLg,
            vertical: AppThemeEnhanced.spaceSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return BounceAnimation(
                key: ValueKey('nav_item_$index'),
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppThemeEnhanced.spaceMd,
                    vertical: AppThemeEnhanced.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppThemeEnhanced.primaryLight.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppThemeEnhanced.radiusFull,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected
                            ? AppThemeEnhanced.primaryLight
                            : Theme.of(
                                context,
                              ).iconTheme.color?.withValues(alpha: 0.6),
                        size: 24,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: AppThemeEnhanced.spaceSm),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: AppThemeEnhanced.primaryLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class EnhancedNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const EnhancedNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

// Enhanced Floating Action Button
class EnhancedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const EnhancedFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<EnhancedFAB> createState() => _EnhancedFABState();
}

class _EnhancedFABState extends State<EnhancedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 0.1,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppThemeEnhanced.primaryGradient,
                borderRadius: BorderRadius.circular(
                  AppThemeEnhanced.radiusFull,
                ),
                boxShadow: AppThemeEnhanced.shadowLg,
              ),
              child: widget.label != null
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        _controller.reverse().then((_) {
                          _controller.forward();
                        });
                        widget.onPressed();
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      icon: Icon(
                        widget.icon,
                        color: widget.foregroundColor ?? Colors.white,
                      ),
                      label: Text(
                        widget.label!,
                        style: TextStyle(
                          color: widget.foregroundColor ?? Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : FloatingActionButton(
                      onPressed: () {
                        _controller.reverse().then((_) {
                          _controller.forward();
                        });
                        widget.onPressed();
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Icon(
                        widget.icon,
                        color: widget.foregroundColor ?? Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

// Enhanced Tab Bar
class EnhancedTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final Function(int)? onTap;

  const EnhancedTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppThemeEnhanced.spaceLg),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
        child: TabBar(
          controller: controller,
          onTap: onTap,
          indicator: BoxDecoration(
            gradient: AppThemeEnhanced.primaryGradient,
            borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.6),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: tabs.asMap().entries.map((entry) {
            return Tab(
              key: ValueKey('enhanced_tab_${entry.key}'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeEnhanced.spaceSm,
                  vertical: AppThemeEnhanced.spaceXs,
                ),
                child: Text(entry.value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Enhanced Drawer
class EnhancedDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final List<EnhancedDrawerItem> items;

  const EnhancedDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
            decoration: BoxDecoration(
              gradient: AppThemeEnhanced.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: userAvatar != null
                        ? NetworkImage(userAvatar!)
                        : null,
                    child: userAvatar == null
                        ? Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceMd),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppThemeEnhanced.spaceSm,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return BounceAnimation(
                  onTap: item.onTap,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppThemeEnhanced.spaceSm,
                      vertical: AppThemeEnhanced.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: item.isSelected
                          ? AppThemeEnhanced.primaryLight.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppThemeEnhanced.radiusLg,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        item.icon,
                        color: item.isSelected
                            ? AppThemeEnhanced.primaryLight
                            : Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: item.isSelected
                              ? AppThemeEnhanced.primaryLight
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: item.isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: item.trailing,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EnhancedDrawerItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final Widget? trailing;

  const EnhancedDrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.trailing,
  });
}
