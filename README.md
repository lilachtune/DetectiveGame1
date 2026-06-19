# Детективная игра — Кодовая основа (Godot 4.2+)

## Структура проекта

```
detective_game/
├── project.godot                      ← Главный файл проекта
│
├── autoload/                          ← Синглтоны (Autoload)
│   ├── GameManager.gd                 ← Управление состоянием игры
│   ├── SaveManager.gd                 ← Система сохранения
│   ├── AudioManager.gd                ← Управление звуком
│   └── DiaryManager.gd                ← Дневник: персонажи, улики, диалоги
│
├── scripts/                           ← Скрипты сцен
│   ├── MainMenu.gd                    ← Главное меню
│   ├── LocationBase.gd                ← Базовый класс локации
│   ├── CharacterBase.gd               ← Базовый класс персонажа
│   ├── DialogueBox.gd                 ← Система диалогов
│   ├── PauseMenu.gd                   ← Меню паузы (Escape)
│   ├── Diary.gd                       ← Дневник (вкладки: локации / персонажи / улики)
│   ├── Settings.gd                    ← Настройки звука
│   └── EndingTest.gd                  ← Финальный тест (кто убийца, как, зачем)
│
├── scenes/
│   ├── MainMenu.tscn                  ← Главное меню
│   └── locations/
│       ├── Location01.tscn … Location15.tscn   ← 15 локаций
│       └── Location01.gd  … Location15.gd      ← Скрипты локаций
│
├── resources/
│   └── DialogueData.gd                ← Вспомогательный класс для диалогов
│
└── assets/
    ├── characters/     ← PNG-спрайты персонажей: character_01.png … character_10.png
    ├── locations/      ← PNG-фоны локаций
    └── ui/             ← Иконки и прочие UI-элементы
```

---

## Первый запуск

### 1. Открыть проект
- Запусти Godot 4.2+ → «Import» → выбери папку `detective_game`

### 2. Настроить Autoload
`Project → Project Settings → Autoload` — добавить:

| Имя          | Путь                                |
|--------------|-------------------------------------|
| GameManager  | res://autoload/GameManager.gd        |
| SaveManager  | res://autoload/SaveManager.gd        |
| AudioManager | res://autoload/AudioManager.gd       |
| DiaryManager | res://autoload/DiaryManager.gd       |

> Важно: порядок именно такой (GameManager первый).

### 3. Настроить аудиошины
`Project → Audio` — создать три шины:
- **Master** (уже есть)
- **Music** → Send to: Master
- **SFX** → Send to: Master

### 4. Установить главную сцену
`Project → Project Settings → Application → Run → Main Scene` = `res://scenes/MainMenu.tscn`

---

## Как добавить фоновый рисунок локации

1. Положи PNG-файл в `assets/locations/`
2. Открой сцену `LocationXX.tscn`
3. Выдели узел `Background (Sprite2D)`
4. В Инспекторе → `Texture` → назначь свой PNG

---

## Как добавить персонажа на локацию

1. В редакторе открой нужную `LocationXX.tscn`
2. Выдели узел `Characters`
3. Добавь дочерний `Node2D`, назначь скрипт `CharacterBase.gd`
4. Добавь дочерние узлы:
   - `Sprite2D` — назначь PNG-спрайт персонажа
   - `Area2D` с именем `ClickArea` → добавь `CollisionShape2D`
5. В Инспекторе персонажа укажи:
   - `character_id` — например `character_03`
   - `character_sprite` — PNG-файл

---

## Как написать диалог

В скрипте локации или персонажа:

```gdscript
var dialogue = DialogueData.make_dialogue(
    "dlg_library_sokolov_01",   # уникальный ID
    "character_03",             # ID персонажа
    [
        DialogueData.line(
            "Дмитрий Соколов",
            "Добрый день. Чем могу помочь?",
            "res://assets/characters/character_03_portrait.png"
        ),
        DialogueData.line(
            "Инспектор",
            "Где вы были прошлой ночью?"
        ),
    ]
)
start_dialogue(dialogue)   # вызвать из LocationBase
```

> После завершения диалог **автоматически** появится в Дневнике → вкладка персонажа.

---

## Как добавить улику

```gdscript
# В скрипте локации при клике на объект:
DiaryManager.evidence["evidence_01"]["title"]        = "Стакан с ядом"
DiaryManager.evidence["evidence_01"]["description"]  = "Хрустальный стакан со следами яда."
DiaryManager.evidence["evidence_01"]["location_found"] = "Библиотека"
DiaryManager.evidence["evidence_01"]["circumstances"] = "Найден за книжным шкафом."
DiaryManager.find_evidence("evidence_01")   # ← открывает улику в дневнике
```

---

## Как настроить переходы между локациями

В скрипте `LocationXX.gd` в методе `_setup_location()`:

```gdscript
func _setup_location() -> void:
    # $ExitDoor — Area2D-узел в InteractiveAreas
    $InteractiveAreas/ExitDoor.input_event.connect(
        func(_v, event, _s):
            if event is InputEventMouseButton and event.pressed:
                travel_to("Location02")
    )
```

---

## Как завершить сюжет (разблокировать тест)

```gdscript
# В конце последнего диалога или триггере сюжета:
GameManager.complete_story()
# → кнопка «Тест» в Дневнике станет видимой
```

---

## Файл сохранения

Сохранение хранится в: `user://savegame.save`  
(на Windows: `%APPDATA%\Godot\app_userdata\Detective Game\`)

Сохранение **автоматически** происходит при:
- Выходе в главное меню
- Выходе из игры (через меню паузы или ПК)
- Переходе между локациями

---

## Ключевые сигналы

| Сигнал | Откуда | Когда |
|--------|--------|-------|
| `dialogue_finished(id)` | DialogueBox | Диалог завершён |
| `character_discovered(char_id)` | DiaryManager | Персонаж открыт в дневнике |
| `evidence_found(ev_id)` | DiaryManager | Улика добавлена в дневник |
| `diary_updated` | DiaryManager | Любое обновление дневника |
| `state_changed(state)` | GameManager | Смена состояния игры |

---

## Добавление персонажей (данные)

Все 10 персонажей инициализируются в `DiaryManager._init_characters()`.  
Отредактируй имена, информацию, мотивы и алиби там.

---

## Правильные ответы теста

В `EndingTest.gd` (или в инспекторе сцены) установи:
- `correct_killer_id` = `"character_03"` (например)
- `correct_method`    = `"Отравление"`
- `correct_motive`    = `"Деньги / наследство"`
