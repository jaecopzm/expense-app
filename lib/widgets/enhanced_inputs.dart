import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme_enhanced.dart';
import 'animated_widgets.dart';

// Enhanced Text Field
class EnhancedTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int maxLines;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final bool enabled;

  const EnhancedTextField({
    super.key,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.onTap,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppThemeEnhanced.spaceSm),
        ],
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() => _isFocused = hasFocus);
                  if (hasFocus) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                },
                child: TextFormField(
                  controller: widget.controller,
                  validator: widget.validator,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  obscureText: widget.obscureText,
                  maxLines: widget.maxLines,
                  onTap: widget.onTap,
                  onChanged: widget.onChanged,
                  enabled: widget.enabled,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    prefixIcon: widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            color: _isFocused
                                ? AppThemeEnhanced.primaryLight
                                : Theme.of(
                                    context,
                                  ).iconTheme.color?.withOpacity(0.6),
                          )
                        : null,
                    suffixIcon: widget.suffixIcon,
                    filled: true,
                    fillColor: _isFocused
                        ? AppThemeEnhanced.primaryLight.withOpacity(0.05)
                        : Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeEnhanced.radiusLg,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeEnhanced.radiusLg,
                      ),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeEnhanced.radiusLg,
                      ),
                      borderSide: const BorderSide(
                        color: AppThemeEnhanced.primaryLight,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppThemeEnhanced.spaceMd,
                      vertical: AppThemeEnhanced.spaceMd,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Enhanced Category Selector
class EnhancedCategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final List<Map<String, dynamic>> categories;

  const EnhancedCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppThemeEnhanced.spaceMd),
        Wrap(
          spacing: AppThemeEnhanced.spaceMd,
          runSpacing: AppThemeEnhanced.spaceMd,
          children: categories.map((category) {
            final isSelected = selectedCategory == category['name'];
            final categoryColor = AppThemeEnhanced.getCategoryColor(
              category['name'],
            );

            return BounceAnimation(
              onTap: () => onCategorySelected(category['name']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeEnhanced.spaceMd,
                  vertical: AppThemeEnhanced.spaceSm,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppThemeEnhanced.getCategoryGradient(category['name'])
                      : null,
                  color: isSelected
                      ? null
                      : Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(
                    AppThemeEnhanced.radiusLg,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Theme.of(context).dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: isSelected ? AppThemeEnhanced.shadowSm : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'],
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).iconTheme.color,
                      size: 20,
                    ),
                    const SizedBox(width: AppThemeEnhanced.spaceSm),
                    Text(
                      category['name'],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Enhanced Quick Amount Selector
class EnhancedQuickAmountSelector extends StatelessWidget {
  final List<double> amounts;
  final Function(double) onAmountSelected;
  final String? selectedAmount;

  const EnhancedQuickAmountSelector({
    super.key,
    required this.amounts,
    required this.onAmountSelected,
    this.selectedAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Amounts',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppThemeEnhanced.spaceMd),
        Wrap(
          spacing: AppThemeEnhanced.spaceSm,
          runSpacing: AppThemeEnhanced.spaceSm,
          children: amounts.map((amount) {
            final isSelected = selectedAmount == amount.toString();

            return BounceAnimation(
              onTap: () => onAmountSelected(amount),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeEnhanced.spaceMd,
                  vertical: AppThemeEnhanced.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeEnhanced.primaryLight
                      : Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(
                    AppThemeEnhanced.radiusFull,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? AppThemeEnhanced.primaryLight
                        : Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  '\$${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Enhanced Search Bar
class EnhancedSearchBar extends StatefulWidget {
  final String? hint;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const EnhancedSearchBar({
    super.key,
    this.hint,
    this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() => _isFocused = hasFocus);
              if (hasFocus) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: _isFocused
                    ? AppThemeEnhanced.primaryLight.withOpacity(0.05)
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(
                  AppThemeEnhanced.radiusFull,
                ),
                border: Border.all(
                  color: _isFocused
                      ? AppThemeEnhanced.primaryLight
                      : Theme.of(context).dividerColor.withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  hintText: widget.hint ?? 'Search...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: _isFocused
                        ? AppThemeEnhanced.primaryLight
                        : Theme.of(context).iconTheme.color?.withOpacity(0.6),
                  ),
                  suffixIcon: widget.controller?.text.isNotEmpty == true
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            widget.controller?.clear();
                            widget.onClear?.call();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppThemeEnhanced.spaceMd,
                    vertical: AppThemeEnhanced.spaceMd,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
