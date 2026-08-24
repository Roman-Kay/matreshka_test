import '../../../../core/constants/app_assets.dart';

enum PauseMenuSection {
  event(
    label: 'Ивент',
    iconAsset: AppAssets.navEvent,
    iconLabelSpacing: 7,
    placeholderText: 'Событие скоро начнется',
  ),
  battlePass(
    label: 'Battle Pass',
    iconAsset: AppAssets.navBattlePass,
    iconLabelSpacing: 11,
  ),
  calendar(
    label: 'Календарь\nновичка',
    iconAsset: AppAssets.navCalendar,
    placeholderText: 'Ежедневные бонусы появятся здесь',
  ),
  afterLessons(
    label: 'После\nуроков',
    iconAsset: AppAssets.navAfter,
    placeholderText: 'Активности после уроков пока закрыты',
  ),
  inviteFriend(
    label: 'Пригласи\nдруга',
    iconAsset: AppAssets.navInvite,
    placeholderText: 'Приглашения друзей будут доступны позже',
  ),
  promo(
    label: 'Промокод',
    iconAsset: AppAssets.navPromo,
    iconLabelSpacing: 4,
    placeholderText: 'Введите промокод в следующем обновлении',
  );

  const PauseMenuSection({
    required this.label,
    required this.iconAsset,
    this.iconLabelSpacing = 0,
    this.placeholderText = '',
  });

  final String label;
  final String iconAsset;
  final double iconLabelSpacing;
  final String placeholderText;
}
