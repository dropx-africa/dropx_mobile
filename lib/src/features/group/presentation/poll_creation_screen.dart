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
  }

  void _addOption([String? initialText]) {
    if (_controllers.length >= _maxOptions) return;
    setState(() {
      _controllers.add(TextEditingController(text: initialText));
    });
  }

  void _removeOption(int index) {
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
        setState(
          () {},
        ); // specific field update usually doesn't need setstate if controller is bound, but for safety
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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Option",
                              hintStyle: TextStyle(color: AppColors.slate400),
                            ),
                          ),
                        ),
                      ),
                      if (_controllers.length > 2)
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
                  // Dashed border is complex in flutter without external pkg, using solid for now or dotted decoration
                  // Simply using outline with dashed effect requires CustomPainter, keeping it simple.
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
            QuickAddWidget(onAdd: _onQuickAdd),
            const SizedBox(height: 48),

            // Create Poll Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final options = _controllers
                      .map((c) => c.text.trim())
                      .where((t) => t.isNotEmpty)
                      .toList();

                  if (options.length < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least 2 options'),
                      ),
                    );
                    return;
                  }
                  widget.onPollCreated(options);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors
                      .slate200, // Disabled look initially per design, but functional here
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_box_outlined, color: AppColors.slate500),
                    SizedBox(width: 8),
                    AppText(
                      "Create Poll (0/3 min)",
                      color: AppColors.slate500,
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
