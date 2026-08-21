# Battle Pass Flutter

Экран боевого пропуска по Figma-макету «БП / Главная» с тремя демонстрационными состояниями: премиум не куплен, премиум куплен с доступными наградами, максимальный уровень. Макет в Figma имеет размер `2320x1080` и альбомную ориентацию; приложение принудительно запускается только в горизонтальном полноэкранном режиме. UI собран живыми Flutter-виджетами, а Figma-ассеты сохранены локально в `assets/figma`.

## Требования и запуск

- Flutter stable, Dart `^3.11.5`.
- Установить зависимости: `flutter pub get`.
- Запустить: `flutter run`.
- Проверки: `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`.

## Что реализовано

- Feature-first структура `lib/app`, `lib/core`, `lib/features/battle_pass`, `lib/features/tasks`.
- `flutter_bloc` + `BattlePassCubit` для загрузки, смены demo-сценария, покупки премиума, выбора и получения наград.
- Mock repository с искусственной задержкой и фиксированным сезоном без сети.
- Горизонтальная шкала наград, статусы `locked / available / received`, premium/free дорожки, max-level состояние.
- Экран «Задания» с отдельной страницей, кнопкой назад и стилем основного экрана.

## Переключение состояний

На главном экране сделайте долгое нажатие на заголовок сезона «Дай пять!». Откроется bottom sheet с режимами:

- `premiumLocked` - премиум не приобретен;
- `premiumUnlocked` - премиум приобретен;
- `maxLevel` - максимальный уровень.

## Архитектура

Доменные модели лежат в `features/battle_pass/domain/models`, доступ к данным идет через `BattlePassRepository`, mock-реализация находится в `data/repositories`. Виджеты не содержат бизнес-логики получения наград: они вызывают методы Cubit.

Повторяющиеся цвета и ассеты вынесены в `core/theme` и `core/constants`. Шрифт Geologica из Figma не поставлялся как файл, поэтому использован системный fallback `Arial`; это осознанное допущение без нелегальной загрузки шрифта.

## Анимации

Есть `AnimatedSwitcher` при смене сценария, `AnimatedContainer` для выделения выбранной награды, плавный прогресс через `CircularProgressIndicator`, feedback кнопок и карточек через Material ink effects.

## Ограничения и допущения

- Полная выгрузка Figma subtree была усечена инструментом из-за большого количества ассетов; сохранены ключевые изображения главного состояния и reference export.
- Иконки частично реализованы Material Icons там, где экспорт Figma был избыточен для тестового экрана.
- Ориентация макета альбомная; приложение фиксирует `landscapeLeft` и `landscapeRight`, включает immersive fullscreen, а canvas масштабируется через `BoxFit.cover`, чтобы занимать весь экран.
- Экран «Задания» реализован как рабочая стилизованная версия, без отдельного Cubit, потому что отдельной бизнес-логики нет.

## Использование ИИ

ИИ использовался для анализа структуры задачи, подготовки архитектурного каркаса, декомпозиции UI, проверки пограничных сценариев, помощи с тестами и документацией. Итоговая реализация, архитектурные решения и проверка результата контролировались разработчиком.

## Proto-схема

```proto
rpc BattlePass {
  message Reward {
    int32 id "Уникальный id награды";
    RewardType type "Тип награды, включая unknown";
    string title = 96 "Отображаемое название";
    string assetPath = 256 "Локальный путь к изображению, optional";
    int32 amount "Количество";
    BattlePassTrack track "free или premium";
    RewardStatus status "locked, available, received";
  }

  message Level {
    int32 number "Номер уровня";
    int32 requiredXp "Опыт, необходимый для уровня";
    repeated Reward freeRewards max 4 "Бесплатные награды";
    repeated Reward premiumRewards max 4 "Премиальные награды";
  }

  message Season {
    string id = 64 "Id сезона";
    string title = 64 "Название сезона";
    timestamp startsAt "Дата начала";
    timestamp endsAt "Дата окончания";
    int32 maxLevel "Максимальный уровень";
    repeated Level levels max 100 "Уровни боевого пропуска";
  }

  message Progress {
    int32 currentLevel "Текущий уровень";
    int32 currentXp "Текущий опыт";
    int32 nextLevelXp "Опыт до следующего уровня";
  }

  outgoing Show {
    Season season "Активный сезон";
    Progress progress "Текущий прогресс";
    PremiumStatus premiumStatus "Состояние премиума";
    BattlePassDemoMode demoMode "Демонстрационный сценарий";
    int32 selectedRewardId "Выбранная награда, optional";
  }
}
```
# matreshka_test
