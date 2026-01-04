import 'package:flutter/material.dart';

class CancelOrderDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isCancelling; // To show loading spinner on the button

  const CancelOrderDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.isCancelling = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. RED WARNING ICON
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE), // Light Red Halo
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935), // Strong Red
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. TEXT
                Text(
                  "Cancel Order?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to cancel? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // 3. CONFIRM BUTTON (RED)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isCancelling ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935), // Red
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: isCancelling
                        ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                        : Text(
                      "Yes, Cancel Order",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 4. CANCEL BUTTON (TEXT)
                TextButton(
                  onPressed: isCancelling ? null : onCancel,
                  child: Text(
                    "No, Keep Order",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. CLOSE 'X' BUTTON (Top Right)
          Positioned(
            right: 16,
            top: 16,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.grey[400]),
              onPressed: isCancelling ? null : onCancel,
            ),
          ),
        ],
      ),
    );
  }
}