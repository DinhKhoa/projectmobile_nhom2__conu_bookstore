import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';

class NotificationDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final bool isConfirm;
  final VoidCallback? onConfirm;

  const NotificationDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.notifications,
    this.color = AppColors.primary,
    this.isConfirm = false,
    this.onConfirm,
  });

  static void showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return NotificationDialog(
          title: 'Lỗi Hệ Thống!',
          message: message,
          icon: Icons.priority_high,
        );
      },
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });
        return NotificationDialog(
          title: message,
          message: '',
          icon: Icons.check,
        );
      },
    );
  }

  static void showConfirm(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => NotificationDialog(
        title: title,
        message: message,
        icon: Icons.help_outline,
        isConfirm: true,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications, color: AppColors.primary, size: 40),
                Positioned(
                  top: 11,
                  child: Icon(icon, color: Colors.white, size: 14, weight: 900),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.primary, fontSize: 18),
              ),
            ],
            if (isConfirm) ...[
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
