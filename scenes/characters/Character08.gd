## Character08.gd
## Персонаж: Наталья Белова
extends "res://scripts/CharacterBase.gd"

func _setup_character() -> void:
	character_id     = "character_08"
	character_sprite = preload("res://assets/characters/character_08.png")

	## Диалоги: заполни под свой сюжет.
	## Используй DialogueData.make_dialogue() для удобства.
	dialogues = [
		{
			"id":           "dlg_08_intro",
			"character_id": "character_08",
			"lines": [
				{
					"speaker":       "Наталья Белова",
					"text":          "Здравствуйте, инспектор. Чем могу помочь?",
					"portrait_path": "res://assets/characters/character_08_portrait.png"
				},
				{
					"speaker":       "Инспектор",
					"text":          "Мне нужно задать вам несколько вопросов.",
					"portrait_path": ""
				},
			]
		},
	]
