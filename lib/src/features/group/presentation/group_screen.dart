import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/features/group/presentation/poll_creation_screen.dart';
import 'package:dropx_mobile/src/features/group/presentation/poll_voting_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  // 0: Creation, 1: Voting
  int _currentStep = 0;
  List<String> _createdOptions = [];

  void _onPollCreated(List<String> options) {
    setState(() {
      _createdOptions = options;
      _currentStep = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentStep == 0
          ? PollCreationScreen(onPollCreated: _onPollCreated)
          : PollVotingScreen(options: _createdOptions),
    );
  }
}
