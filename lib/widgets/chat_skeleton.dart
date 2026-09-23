import 'package:flutter/material.dart';
import 'package:skillpay/theme/app_theme.dart';

/// Animated shimmer container for skeleton loading
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.baseColor,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
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
        final opacity = 0.35 + (_controller.value * 0.45);
        final base = widget.baseColor ?? Colors.grey.shade300;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: base.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for Chat Messages screen
class ChatMessagesSkeleton extends StatelessWidget {
  const ChatMessagesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildBubble(width: 170, height: 42, isMe: false),
        _buildBubble(width: 240, height: 56, isMe: true),
        _buildBubble(width: 130, height: 38, isMe: false),
        _buildBubble(width: 210, height: 48, isMe: true),
        _buildBubble(width: 260, height: 60, isMe: false),
        _buildBubble(width: 180, height: 42, isMe: true),
        _buildBubble(width: 220, height: 48, isMe: false),
        _buildBubble(width: 150, height: 40, isMe: true),
      ],
    );
  }

  Widget _buildBubble({
    required double width,
    required double height,
    required bool isMe,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ShimmerBox(
          width: width,
          height: height,
          borderRadius: 16,
          baseColor: isMe ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
    );
  }
}

/// Skeleton loader for Conversations list screen
class ConversationListSkeleton extends StatelessWidget {
  final int count;

  const ConversationListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => Row(
        children: [
          const ShimmerBox(width: 52, height: 52, borderRadius: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 140, height: 14, borderRadius: 4),
                SizedBox(height: 8),
                ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const ShimmerBox(width: 40, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}
