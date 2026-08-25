import '../../presentation/models/pause_menu_section.dart';

final class MockPauseNotificationsRepository {
  const MockPauseNotificationsRepository();

  Set<PauseMenuSection> loadNotificationSections() {
    return const {PauseMenuSection.calendar};
  }
}
