# Matreshka RP Test Flutter

Тестовый Flutter-проект с пустым экраном игры, меню паузы и разделом Battle Pass с заданиями.Приложение сделано адаптивным для Android/iOS-смартфонов любых размеров и также прекрасно отображается на планшетах благодаря правильному использованию пакета flutter_screenutil_plus.

## ТЗ

- Flutter stable.
- Управление состоянием: `flutter_bloc` / `Cubit`.
- Без сторонних UI-китов.
- Данные моковые, без сети.
- Основной flow: экран игры -> кнопка паузы -> pause menu -> вкладки меню, где Battle Pass является отдельным разделом.

## Запуск

flutter pub get
dart run build_runner build
flutter run

## Что реализовано

- `GameRoute` - стартовый пустой экран игры с кнопкой паузы.
- `PauseShellRoute` - общий shell меню паузы с боковой навигацией.
- Полноценные route-экраны для вкладок pause menu: Event, Battle Pass, Newcomer Calendar, After Lessons, Invite Friend, Promo.
- `TasksRoute` - отдельный экран заданий внутри Battle Pass flow.
- Battle Pass: free/premium дорожки, статусы наград, выбор и получение награды, получение всех доступных наград, покупка premium, max-level/completed состояния.

## Архитектура

Проект разложен feature-first:

```text
lib/
  app/              # bootstrap, MaterialApp.router, AutoRoute config
  core/             # theme, constants, shared assets
  features/
    game/           # стартовый экран игры
    pause/          # shell меню паузы и navigation bar
    battle_pass/    # Battle Pass domain/data/presentation
    tasks/          # задания Battle Pass
    event/          # будущий полноценный экран вкладки
    newcomer_calendar/
    after_lessons/
    invite_friend/
    promo/
```

`pause` владеет общим shell и navigation bar. `battle_pass` не знает о других вкладках и отвечает только за свою бизнес-логику и UI. `tasks` вынесены отдельно, потому что это самостоятельный экран внутри Battle Pass flow.

В `battle_pass/domain` лежат модели, repository contract и use cases:

- `LoadBattlePassUseCase`
- `ComputeRewardStatusesUseCase`
- `PurchasePremiumUseCase`
- `ClaimRewardUseCase`
- `ClaimAllRewardsUseCase`

`BattlePassCubit` остается тонким presentation-координатором: загружает данные, вызывает use cases и эмитит состояние.

## Навигация

Навигация построена на AutoRoute:

```text
GameRoute /
PauseShellRoute /pause
  EventRoute event
  BattlePassRoute battle-pass
  TasksRoute battle-pass/tasks
  NewcomerCalendarRoute calendar
  AfterLessonsRoute after-lessons
  InviteFriendRoute invite-friend
  PromoRoute promo
```

Кнопка паузы на экране игры открывает `PauseShellRoute`. Крестик в Battle Pass и на экране заданий возвращает пользователя обратно на `GameRoute`.


## Данные

Данные моковые и находятся в data-слое:

- `MockBattlePassRepository`
- `MockTasksRepository`
- mock pause/profile repositories

Presentation-слой не зависит от mock-реализаций напрямую.

## Использование ИИ

ИИ использовался:
 - для первичной базы  UI которую я забрал из фигиы и после вручную правил под нее
 - генерации моковых данных
 - создание быстро папок после того как я расписал и утвердил нужную архитектуру
 - вынос асетов фото в appassets
 - анимаций
 - для простых тестов
 - для формаирования readme))
