import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;

  const NumericKeypad({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    this.onBiometric,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var j = 1; j <= 3; j++)
                    _buildKey(context, '${i * 3 + j}'),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onBiometric != null)
                _buildActionKey(context, Icons.fingerprint, onBiometric!)
              else
                const SizedBox(width: 72, height: 72),
              _buildKey(context, '0'),
              _buildActionKey(context, Icons.backspace_outlined, onDelete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(BuildContext context, String number) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onKeyPress(number);
      },
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(BuildContext context, IconData icon, VoidCallback action) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        action();
      },
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        child: Icon(icon, size: 28, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
      ),
    );
  }
}
