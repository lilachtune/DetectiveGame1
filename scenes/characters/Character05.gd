## Character05.gd
## Персонаж: Игорь Петров
extends CharacterBase

func _setup_character() -> void:
	character_id     = "character_05"
	character_sprite = preload("res://assets/characters/character_05.png")

	## Диалоги: заполни под свой сюжет.
	## Используй DialogueData.make_dialogue() для удобства.
	dialogues = [
		{
			"id":           "dlg_05_intro",
			"character_id": "character_05",
			"lines": [
				{
					"speaker":       "Игорь Петров",
					"text":          "Здравствуйте, инспектор. Чем могу помочь?",
					"portrait_path": "res://assets/characters/character_05_portrait.png"
				},
				{
					"speaker":       "Инспектор",
					"text":          "Мне нужно задать вам несколько вопросов.",
					"portrait_path": ""
				},
			]
		},
	]
