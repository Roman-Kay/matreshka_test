import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../pause/presentation/models/pause_menu_section.dart';
import '../../../pause/presentation/widgets/pause_navigation_panel.dart';

@RoutePage()
class NewcomerCalendarPage extends StatelessWidget {
  const NewcomerCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PauseNavigationPanel(section: PauseMenuSection.calendar);
  }
}
