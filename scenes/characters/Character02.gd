## Character02.gd
## Персонаж: Марина Ларина
extends CharacterBase

func _setup_character() -> void:
	character_id     = "character_02"
	character_sprite = preload("res://assets/characters/character_02.png")

	## Диалоги: заполни под свой сюжет.
	## Используй DialogueData.make_dialogue() для удобства.
	dialogues = [
		{
			"id":           "dlg_02_intro",
			"character_id": "character_02",
			"lines": [
				{
					"speaker":       "Марина Ларина",
					"text":          "Здравствуйте, инспектор. Чем могу помочь?",
					"portrait_path": "res://assets/characters/character_02_portrait.png"
				},
				{
					"speaker":       "Инспектор",
					"text":          "Мне нужно задать вам несколько вопросов.",
					"portrait_path": ""
				},
			]
		},
	]
