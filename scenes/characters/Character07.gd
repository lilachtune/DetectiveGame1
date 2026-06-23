## Character07.gd
## Персонаж: Антон Волков
extends "res://scripts/CharacterBase.gd"

func _setup_character() -> void:
	character_id     = "character_07"
	character_sprite = preload("res://assets/characters/character_07.png")

	## Диалоги: заполни под свой сюжет.
	## Используй DialogueData.make_dialogue() для удобства.
	dialogues = [
		{
			"id":           "dlg_07_intro",
			"character_id": "character_07",
			"lines": [
				{
					"speaker":       "Антон Волков",
					"text":          "Здравствуйте, инспектор. Чем могу помочь?",
					"portrait_path": "res://assets/characters/character_07_portrait.png"
				},
				{
					"speaker":       "Инспектор",
					"text":          "Мне нужно задать вам несколько вопросов.",
					"portrait_path": ""
				},
			]
		},
	]
