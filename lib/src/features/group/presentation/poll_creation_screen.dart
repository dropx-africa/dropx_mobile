import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/group/presentation/widgets/quick_add_widget.dart';

class PollCreationScreen extends StatefulWidget {
  final Function(List<String>) onPollCreated;

  const PollCreationScreen({super.key, required this.onPollCreated});

  @override
  State<PollCreationScreen> createState() => _PollCreationScreenState();
}

class _PollCreationScreenState extends State<PollCreationScreen> {
  final List<TextEditingController> _controllers = [];
  final int _maxOptions = 5;

  @override
  void initState() {
    super.initState();
    // Start with 2 empty options
    _addOption();
    _addOption();
    _addOption(); // Start with 3 fields for convenience since min is 3
  }

  void _addOption([String? initialText]) {
    if (_controllers.length >= _maxOptions) return;
    final controller = TextEditingController(text: initialText);
    controller.addListener(() {
      setState(() {}); // Rebuild to update button state
    });
    setState(() {
      _controllers.add(controller);
    });
  }

  void _removeOption(int index) {
    if (_controllers.length <= 3) return; // Prevent removing below minimum
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  void _onQuickAdd(String text) {
    // Find first empty controller or add new one
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        controller.text = text;
        // setstate called by listener
        return;
      }
    }
    // If no empty, add new
    if (_controllers.length < _maxOptions) {
      _addOption(text);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Max options reached')));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validOptionsCount = _controllers
        .where((c) => c.text.trim().isNotEmpty)
        .length;
    final bool isReady = validOptionsCount >= 3;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          "Create Poll",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        leading: const SizedBox(), // Hide back button for tab
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.darkBackground,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _controllers[index],
                            maxLength: 50,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Option",
                              hintStyle: TextStyle(color: AppColors.slate400),
                              counterText: '', // Hide character counter
                            ),
                          ),
                        ),
                      ),
                      if (_controllers.length > 3)
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => _removeOption(index),
                        ),
                    ],
                  ),
                );
              },
            ),

            // Add Option Button
            if (_controllers.length < _maxOptions)
              InkWell(
                onTap: () => _addOption(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          color: AppColors.slate500,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          "Add Option (${_controllers.length}/$_maxOptions)",
                          color: AppColors.slate500,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),
            QuickAddWidget(
              onAdd: _onQuickAdd,
              selectedOptions: _controllers.map((c) => c.text).toList(),
            ),
            const SizedBox(height: 48),

            // Create Poll Button (Dynamic State)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isReady
                    ? () {
                        final options = _controllers
                            .map((c) => c.text.trim())
                            .where((t) => t.isNotEmpty)
                            .toList();
                        widget.onPollCreated(options);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReady
                      ? AppColors.primaryOrange
                      : AppColors.slate200,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_box_outlined,
                      color: isReady ? Colors.white : AppColors.slate500,
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      isReady
                          ? "Create Poll"
                          : "Enter 3 options ($validOptionsCount/3)",
                      color: isReady ? Colors.white : AppColors.slate500,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
