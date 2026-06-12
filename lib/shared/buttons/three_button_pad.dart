import 'package:flutter/material.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';

class ThreeButtonPad extends StatefulWidget {
  const ThreeButtonPad({
    required this.onLeft,
    required this.onCenter,
    required this.onRight,
    super.key,
  });

  final VoidCallback onLeft;
  final VoidCallback onCenter;
  final VoidCallback onRight;

  @override
  State<ThreeButtonPad> createState() => _ThreeButtonPadState();
}

class _ThreeButtonPadState extends State<ThreeButtonPad> {
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PadButton(
          label: 'Left',
          symbol: '<',
          pressed: _pressedIndex == 0,
          onTapDown: () => setState(() => _pressedIndex = 0),
          onTapUp: () => setState(() => _pressedIndex = null),
          onPressed: widget.onLeft,
        ),
        _PadButton(
          label: 'OK',
          symbol: 'OK',
          pressed: _pressedIndex == 1,
          onTapDown: () => setState(() => _pressedIndex = 1),
          onTapUp: () => setState(() => _pressedIndex = null),
          onPressed: widget.onCenter,
          large: true,
        ),
        _PadButton(
          label: 'Right',
          symbol: '>',
          pressed: _pressedIndex == 2,
          onTapDown: () => setState(() => _pressedIndex = 2),
          onTapUp: () => setState(() => _pressedIndex = null),
          onPressed: widget.onRight,
        ),
      ],
    );
  }
}

class _PadButton extends StatelessWidget {
  const _PadButton({
    required this.label,
    required this.symbol,
    required this.pressed,
    required this.onTapDown,
    required this.onTapUp,
    required this.onPressed,
    this.large = false,
  });

  final String label;
  final String symbol;
  final bool pressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 62.0 : 52.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTapDown: (_) => onTapDown(),
        onTapCancel: onTapUp,
        onTapUp: (_) => onTapUp(),
        child: Semantics(
          button: true,
          label: label,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              fixedSize: Size(size, size),
              shape: const CircleBorder(),
              backgroundColor: pressed ? AppColors.shadowMauve : AppColors.lavenderButton,
              elevation: pressed ? 0 : 4,
            ),
            child: Text(symbol),
          ),
        ),
      ),
    );
  }
}
