## Character03.gd
## Персонаж: Дмитрий Соколов
extends CharacterBase

func _setup_character() -> void:
	character_id     = "character_03"
	character_sprite = preload("res://assets/characters/character_03.png")

	## Диалоги: заполни под свой сюжет.
	## Используй DialogueData.make_dialogue() для удобства.
	dialogues = [
		{
			"id":           "dlg_03_intro",
			"character_id": "character_03",
			"lines": [
				{
					"speaker":       "Дмитрий Соколов",
					"text":          "Здравствуйте, инспектор. Чем могу помочь?",
					"portrait_path": "res://assets/characters/character_03_portrait.png"
				},
				{
					"speaker":       "Инспектор",
					"text":          "Мне нужно задать вам несколько вопросов.",
					"portrait_path": ""
				},
			]
		},
	]
