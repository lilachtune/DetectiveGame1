## DialogueData.gd
## Пример структуры данных для диалогов.
## Используй этот формат в скриптах локаций и персонажей.
##
## Каждый диалог — Dictionary со следующими полями:
##   id           : уникальная строка, например "dlg_library_sokolov_01"
##   character_id : ID персонажа (совпадает с DiaryManager.characters ключом)
##   lines        : Array[Dictionary] — список реплик
##
## Каждая реплика:
##   speaker       : отображаемое имя (строка)
##   text          : текст реплики (строка)
##   portrait_path : путь к PNG-портрету (строка, опционально)
##
## ─────────────────────────────────────────────────────────────────────────────
## Пример использования в скрипте локации:
##
##   var dialogue = DialogueData.make_dialogue(
##       "dlg_library_sokolov_01",
##       "character_03",
##       [
##           { "speaker": "Дмитрий Соколов",
##             "text":    "Добрый день. Чем могу помочь, инспектор?",
##             "portrait_path": "res://assets/characters/character_03_portrait.png" },
##           { "speaker": "Инспектор",
##             "text":    "Расскажите, где вы были в ночь убийства.",
##             "portrait_path": "" },
##           { "speaker": "Дмитрий Соколов",
##             "text":    "Я... я был здесь, в библиотеке. Один.",
##             "portrait_path": "res://assets/characters/character_03_portrait.png" },
##       ]
##   )
##   start_dialogue(dialogue)
## ─────────────────────────────────────────────────────────────────────────────
class_name DialogueData
extends RefCounted


## Создаёт словарь диалога из параметров.
static func make_dialogue(
		id: String,
		character_id: String,
		lines: Array
) -> Dictionary:
	return {
		"id":           id,
		"character_id": character_id,
		"lines":        lines,
	}


## Вспомогательный метод: создать реплику.
static func line(
		speaker:       String,
		text:          String,
		portrait_path: String = ""
) -> Dictionary:
	return {
		"speaker":       speaker,
		"text":          text,
		"portrait_path": portrait_path,
	}
