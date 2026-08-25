# Battle Pass Flutter

Экран боевого пропуска по Figma-макету «БП / Главная» с четырьмя демонстрационными состояниями: премиум не куплен, премиум куплен с доступными наградами, максимальный уровень, завершенный сезон. Макет в Figma имеет размер `2320x1080` и альбомную ориентацию; приложение принудительно запускается только в горизонтальном полноэкранном режиме. UI собран живыми Flutter-виджетами, а Figma-ассеты сохранены локально в `assets/figma`.

## Требования и запуск

- Flutter stable, Dart `^3.11.5`.
- Установить зависимости: `flutter pub get`.
- Запустить: `flutter run`.
- Проверки: `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`.

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

Повторяющиеся цвета и ассеты вынесены в `core/theme` и `core/constants`. Шрифт Geologica из Figma не поставлялся как файл, поэтому использован системный fallback `Arial`; это осознанное допущение без нелегальной загрузки шрифта.

## Анимации

Есть `AnimatedSwitcher` при смене сценария, `AnimatedContainer` для выделения выбранной награды, плавный прогресс через `CircularProgressIndicator`, feedback кнопок и карточек через Material ink effects.

## Ограничения и допущения

- Полная выгрузка Figma subtree была усечена инструментом из-за большого количества ассетов; сохранены ключевые изображения главного состояния и reference export.
- Иконки частично реализованы Material Icons там, где экспорт Figma был избыточен для тестового экрана.
- Ориентация макета альбомная; приложение фиксирует `landscapeLeft` и `landscapeRight`, включает immersive fullscreen, а canvas масштабируется через `BoxFit.cover`, чтобы занимать весь экран.
- Экран «Задания» реализован как рабочая стилизованная версия. Данные заданий вынесены в отдельный `TasksRepository`, а действия Battle Pass прокидываются через callbacks.

## Использование ИИ

ИИ использовался для анализа структуры задачи, подготовки архитектурного каркаса, декомпозиции UI, проверки пограничных сценариев, помощи с тестами и документацией. Итоговая реализация, архитектурные решения и проверка результата контролировались разработчиком.

## Proto-схема

Набросок описывает данные, которые нужны для главного экрана Battle Pass, превью заданий, экрана заданий и модалки деталей награды. Синтаксис условный: важны структура, вложенность, ограничения массивов и смысл полей.

```proto
rpc BattlePass {
  enum PremiumStatus {
    locked "Премиум-прокачка не куплена";
    purchased "Премиум-прокачка куплена";
  }

  enum RewardStatus {
    locked "Награда закрыта";
    available "Награду можно забрать";
    received "Награда уже получена";
  }

  enum RewardType {
    xp "Опыт Battle Pass";
    outfit "Скин или одежда";
    currency "Валюта или очки";
    consumable "Расходник";
    vehicle "Транспорт или большой приз";
    unknown "Fallback для неизвестного типа";
  }

  enum BattlePassTrack {
    free "Бесплатная дорожка";
    premium "Премиальная дорожка";
  }

  enum RewardRarity {
    common "Обычная редкость";
    rare "Редкая награда";
    epic "Эпическая награда";
    legendary "Легендарная награда / большой приз";
  }

  message Reward {
    int32 id "Уникальный id награды";
    RewardType type "Тип награды";
    string title = 96 "Отображаемое название";
    int32 amount "Количество";
    BattlePassTrack track "free или premium";
    RewardRarity rarity "Редкость для визуального оформления карточки";
    RewardStatus status "locked, available, received";
    string assetPath = 256 "Путь к иконке/изображению награды, optional";
  }

  message Level {
    int32 number "Номер уровня";
    int32 requiredXp "Опыт, необходимый для уровня";
    repeated Reward freeRewards max 2 "Награды бесплатной дорожки";
    repeated Reward premiumRewards max 3 "Награды премиальной дорожки, включая выбор из нескольких наград";
  }

  message Season {
    string id = 64 "Id сезона";
    string title = 64 "Название сезона";
    timestamp startsAt "Дата начала сезона";
    timestamp endsAt "Дата окончания сезона";
    int32 maxLevel "Максимальный уровень";
    repeated Reward instantPremiumRewards max 3 "Награды, которые игрок получает сразу после покупки премиума";
    repeated Level levels max 200 "Уровни боевого пропуска";
  }

  message Progress {
    int32 currentLevel "Текущий уровень";
    int32 currentXp "Опыт внутри текущего уровня";
    int32 nextLevelXp "Опыт, нужный для следующего уровня";
  }

  enum TaskStatus {
    inProgress "Задание выполняется";
    readyToClaim "Задание выполнено, награду можно забрать";
    claimed "Награда за задание получена";
  }

  message Task {
    int32 id "Уникальный id задания";
    string title = 160 "Описание задания";
    string rewardTitle = 32 "Название награды за задание";
    int32 rewardAmount "Количество опыта/награды";
    int32 currentProgress "Текущий прогресс выполнения";
    int32 requiredProgress "Цель выполнения";
    string rewardAssetPath = 256 "Иконка награды";
    int32 xpBonusPercent "Процент бонуса к опыту при активном премиуме, 0 если бонуса нет";
    TaskStatus status "Состояние задания";
  }

  message RewardDetailsModal {
    Reward reward "Выбранная награда для модалки";
    repeated Reward choiceRewards max 3 "Варианты выбора, если на уровне несколько премиальных наград";
    int32 level "Уровень, на котором находится награда";
    bool premiumLocked "true, если награда требует купленный премиум";
    bool canClaim "true, если кнопка Забрать активна";
    string actionText = 32 "Текст CTA: Забрать, Получено, Прокачать, Заблокировано";
  }

  message TasksPreview {
    repeated Task tasks max 5 "Короткий список заданий для карточки на главном экране";
    int32 activeTaskIndex "Индекс активного задания в автопрокрутке";
  }

  message TasksScreen {
    Progress progress "Прогресс Battle Pass для шапки экрана заданий";
    PremiumStatus premiumStatus "Состояние премиума для CTA прокачки";
    timestamp tasksRefreshAt "Время следующего обновления заданий";
    repeated Task tasks max 12 "Список заданий на отдельном экране";
  }

  outgoing Show {
    Season season "Активный сезон";
    Progress progress "Текущий прогресс";
    PremiumStatus premiumStatus "Состояние премиума";
    int32 selectedRewardId "Выбранная награда, optional";
    repeated Task tasks max 12 "Задания, связанные с Battle Pass";
    TasksPreview tasksPreview "Данные превью заданий на главном экране";
    RewardDetailsModal rewardDetails "Данные для модалки выбранной награды, optional";
  }
}
```
