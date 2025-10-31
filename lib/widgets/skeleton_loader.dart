import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme_enhanced.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surface,
      highlightColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.1),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppThemeEnhanced.radiusSm),
        ),
      ),
    );
  }
}

class ExpenseCardSkeleton extends StatelessWidget {
  const ExpenseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppThemeEnhanced.spaceLg,
        vertical: AppThemeEnhanced.spaceXs,
      ),
      padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
        boxShadow: AppThemeEnhanced.shadowSm,
      ),
      child: Row(
        children: [
          const SkeletonLoader(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(
              Radius.circular(AppThemeEnhanced.radiusMd),
            ),
          ),
          const SizedBox(width: AppThemeEnhanced.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 120, height: 16),
                const SizedBox(height: AppThemeEnhanced.spaceXs),
                const SkeletonLoader(width: 80, height: 14),
                const SizedBox(height: AppThemeEnhanced.spaceXs),
                const SkeletonLoader(width: 60, height: 12),
              ],
            ),
          ),
          const SizedBox(width: AppThemeEnhanced.spaceMd),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLoader(width: 80, height: 18),
              SizedBox(height: AppThemeEnhanced.spaceXs),
              SkeletonLoader(width: 60, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class BalanceCardSkeleton extends StatelessWidget {
  const BalanceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppThemeEnhanced.spaceLg),
      padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radius2xl),
        boxShadow: AppThemeEnhanced.shadowLg,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 100, height: 16),
                  SizedBox(height: AppThemeEnhanced.spaceXs),
                  SkeletonLoader(width: 80, height: 14),
                ],
              ),
              SkeletonLoader(width: 40, height: 40),
            ],
          ),
          SizedBox(height: AppThemeEnhanced.spaceLg),
          SkeletonLoader(width: 200, height: 32),
          SizedBox(height: AppThemeEnhanced.spaceLg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 60, height: 14),
                    SizedBox(height: AppThemeEnhanced.spaceXs),
                    SkeletonLoader(width: 80, height: 18),
                  ],
                ),
              ),
              SizedBox(width: AppThemeEnhanced.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 60, height: 14),
                    SizedBox(height: AppThemeEnhanced.spaceXs),
                    SkeletonLoader(width: 80, height: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
        boxShadow: AppThemeEnhanced.shadowSm,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 32, height: 32),
              SkeletonLoader(width: 20, height: 20),
            ],
          ),
          SizedBox(height: AppThemeEnhanced.spaceMd),
          SkeletonLoader(width: 80, height: 24),
          SizedBox(height: AppThemeEnhanced.spaceXs),
          SkeletonLoader(width: 100, height: 14),
          SizedBox(height: AppThemeEnhanced.spaceXs),
          SkeletonLoader(width: 60, height: 12),
        ],
      ),
    );
  }
}
