# Matreshka RP TEST Flutter

Экран боевого пропуска по Figma-макету «БП / Главная» с демонстрационными состояниями: премиум не куплен, премиум куплен с доступными наградами, премиум с бонусом опыта, максимальный уровень и завершенный сезон.
## Требования и запуск

- Flutter stable, Dart `^3.11.5`.
- Установить зависимости: `flutter pub get`.
- Запустить: `flutter run`.

## Что реализовано

- Feature-first структура `lib/app`, `lib/core`, `lib/features/battle_pass`, `lib/features/tasks`.
- `flutter_bloc` + `BattlePassCubit` для загрузки, смены demo-сценария, покупки премиума, выбора и получения наград.
- Mock repositories с искусственной задержкой, динамическими датами сезона и данными без сети.
- Горизонтальная шкала наград, статусы `locked / available / received`, premium/free дорожки, max-level состояние.
- Экран «Задания» с отдельной страницей, кнопкой назад и стилем основного экрана.

## Переключение состояний

На главном экране сделайте долгое нажатие на заголовок сезона «Дай пять!». Откроется bottom sheet с режимами:

- `premiumLocked` - премиум не приобретен;
- `premiumUnlocked` - премиум приобретен;
- `premiumWithXpBonus` - премиум приобретен, у заданий включен бонус `+100%` к опыту;
- `maxLevel` - максимальный уровень;
- `completed` - Battle Pass завершен.

## Архитектура

Доменные модели лежат в `features/battle_pass/domain/models` и `features/tasks/domain/models`, доступ к данным идет через `BattlePassRepository` и `TasksRepository`, mock-реализации находятся в `data/repositories`. Бизнес-логика получения наград и заданий вынесена в use cases, а presentation-виджеты получают callbacks сверху.

Повторяющиеся цвета и ассеты вынесены в `core/theme` и `core/constants`.


## Proto‑подобная схема данных (кратко)
Ниже — упрощённый proto‑набросок, показывающий ключевые структуры: сезоны, уровни, награды, состояние игрока и задания.

```proto
rpc BattlePass {
  message Reward { int32 id; string title; int32 amount; string assetPath; }
  message Level { int32 number; int32 requiredXp; repeated Reward freeRewards; repeated Reward premiumRewards; }
  message Season { string id; string title; timestamp startsAt; timestamp endsAt; int32 maxLevel; repeated Level levels; }
  message Progress { int32 currentLevel; int32 currentXp; int32 nextLevelXp; }
  message Task { int32 id; string title; int32 rewardAmount; int32 currentProgress; int32 requiredProgress; int32 xpBonusPercent; enum TaskStatus { inProgress, readyToClaim, claimed } }
  message PlayerBattlePassState { string userId; Progress progress; enum PremiumStatus { locked, purchased } premiumStatus; repeated int32 claimedRewardIds; }
  outgoing Show { Season season; PlayerBattlePassState playerState; repeated Task tasks; }
}
```


##  Как использовался ИИ
ИИ применялся: 
- для генерации наброска UI из фигмы после проходился по всем файлам и делал ровно так как фигме вручную.
- для создание папок, дал описание архитектуры название были сгенерированы
- для вынесения assets в AppAssets
- для генериции заданий и наград в моках
- для анимаций


