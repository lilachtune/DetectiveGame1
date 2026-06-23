## Character06.gd
## Персонаж: Светлана Орлова
extends "res://scripts/CharacterBase.gd"

func _setup_character() -> void:
	character_id     = "character_06"
	character_sprite = preload("res://assets/characters/character_06.png")

	## Диалоги: заполни под свой сюжет.
	## Используй DialogueData.make_dialogue() для удобства.
	dialogues = [
		{
			"id":           "dlg_06_intro",
			"character_id": "character_06",
			"lines": [
				{
					"speaker":       "Светлана Орлова",
					"text":          "Здравствуйте, инспектор. Чем могу помочь?",
					"portrait_path": "res://assets/characters/character_06_portrait.png"
				},
				{
					"speaker":       "Инспектор",
					"text":          "Мне нужно задать вам несколько вопросов.",
					"portrait_path": ""
				},
			]
		},
	]
