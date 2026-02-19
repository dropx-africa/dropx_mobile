import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/order/presentation/widgets/thank_you_dialog.dart';

class RatingSheet extends StatefulWidget {
  const RatingSheet({super.key});

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpaces.v24,
          const AppText(
            "Rate your Order",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          AppSpaces.v8,
          const AppText(
            "How was your experience with Mama Put's Kitchen?",
            color: Colors.grey,
          ),
          AppSpaces.v24,

          // Star Rating
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.warningAmber,
                    size: 40,
                  ),
                );
              }),
            ),
          ),
          AppSpaces.v32,

          // Comment Input
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Write a review...",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryOrange),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          AppSpaces.v24,

          // Submit Button
          CustomButton(
            text: "Submit Review",
            backgroundColor: _rating > 0
                ? AppColors.primaryOrange
                : Colors.grey.shade300,
            textColor: Colors.white,
            onPressed: () {
              if (_rating > 0) {
                Navigator.pop(context); // Close sheet
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const ThankYouDialog(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
