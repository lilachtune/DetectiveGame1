## Character04.gd
## Персонаж: Елена Чернова
extends CharacterBase

func _setup_character() -> void:
	character_id     = "character_04"
	character_sprite = preload("res://assets/characters/character_04.png")

	## Диалоги: заполни под свой сюжет.
	## Используй DialogueData.make_dialogue() для удобства.
	dialogues = [
		{
			"id":           "dlg_04_intro",
			"character_id": "character_04",
			"lines": [
				{
					"speaker":       "Елена Чернова",
					"text":          "Здравствуйте, инспектор. Чем могу помочь?",
					"portrait_path": "res://assets/characters/character_04_portrait.png"
				},
				{
					"speaker":       "Инспектор",
					"text":          "Мне нужно задать вам несколько вопросов.",
					"portrait_path": ""
				},
			]
		},
	]
