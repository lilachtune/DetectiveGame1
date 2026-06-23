## Character10.gd
## Персонаж: Алиса Зайцева
extends "res://scripts/CharacterBase.gd"

func _setup_character() -> void:
	character_id     = "character_10"
	character_sprite = preload("res://assets/characters/character_10.png")

	## Диалоги: заполни под свой сюжет.
	## Используй DialogueData.make_dialogue() для удобства.
	dialogues = [
		{
			"id":           "dlg_10_intro",
			"character_id": "character_10",
			"lines": [
				{
					"speaker":       "Алиса Зайцева",
					"text":          "Здравствуйте, инспектор. Чем могу помочь?",
					"portrait_path": "res://assets/characters/character_10_portrait.png"
				},
				{
					"speaker":       "Инспектор",
					"text":          "Мне нужно задать вам несколько вопросов.",
					"portrait_path": ""
				},
			]
		},
	]
