## DiaryManager.gd
## Дневник: хранит информацию об открытых локациях,
## персонажах, уликах и диалогах.
extends Node

# ─── Данные ──────────────────────────────────────────────────────────────────

## Открытые локации (массив ID)
var discovered_locations: Array[String] = []

## Персонажи: { char_id -> CharacterRecord }
## CharacterRecord = {
##   name, surname, info, motive, alibi, photo_path,
##   interrogations: Array[String], discovered: bool
## }
var characters: Dictionary = {}

## Улики: { evidence_id -> EvidenceRecord }
## EvidenceRecord = {
##   title, description, location_found, circumstances, discovered: bool
## }
var evidence: Dictionary = {}

## История диалогов: { dialogue_id -> DialogueRecord }
## DialogueRecord = {
##   character_id: String,
##   lines: Array[{ speaker, text, portrait_path }],
##   completed: bool
## }
var dialogue_history: Dictionary = {}

# ─── Сигналы ──────────────────────────────────────────────────────────────────
signal diary_updated
signal character_discovered(char_id: String)
signal evidence_found(evidence_id: String)
signal dialogue_completed(dialogue_id: String)

# ─── Инициализация ────────────────────────────────────────────────────────────

func _ready() -> void:
	_init_characters()
	_init_evidence()


func _init_characters() -> void:
	## Заготовка: 10 персонажей. Заполни данные под свой сюжет.
	var data := [
		{ "name": "Виктор",    "surname": "Ларин",     "info": "Хозяин особняка, 58 лет." },
		{ "name": "Марина",    "surname": "Ларина",    "info": "Жена хозяина, 45 лет." },
		{ "name": "Дмитрий",   "surname": "Соколов",   "info": "Дворецкий, служит 20 лет." },
		{ "name": "Елена",     "surname": "Чернова",   "info": "Горничная, 30 лет." },
		{ "name": "Игорь",     "surname": "Петров",    "info": "Деловой партнёр, 50 лет." },
		{ "name": "Светлана",  "surname": "Орлова",    "info": "Племянница, 25 лет." },
		{ "name": "Антон",     "surname": "Волков",    "info": "Охранник поместья, 35 лет." },
		{ "name": "Наталья",   "surname": "Белова",    "info": "Повар, 40 лет." },
		{ "name": "Сергей",    "surname": "Громов",    "info": "Садовник, 55 лет." },
		{ "name": "Алиса",     "surname": "Зайцева",   "info": "Гость, подруга племянницы, 24 года." },
	]
	for i in data.size():
		var id := "character_%02d" % (i + 1)
		characters[id] = {
			"name":          data[i]["name"],
			"surname":       data[i]["surname"],
			"info":          data[i]["info"],
			"motive":        "(мотив будет раскрыт по сюжету)",
			"alibi":         "(алиби будет установлено по сюжету)",
			"photo_path":    "res://assets/characters/%s.png" % id,
			"interrogations": [],
			"discovered":    false,
		}


func _init_evidence() -> void:
	## Заготовка: 10 улик. Заполни под свой сюжет.
	for i in range(1, 11):
		var id := "evidence_%02d" % i
		evidence[id] = {
			"title":          "Улика %d" % i,
			"description":    "Подробное описание улики %d." % i,
			"location_found": "Локация X",
			"circumstances":  "Обстоятельства обнаружения улики %d." % i,
			"discovered":     false,
		}


# ─── Открытие элементов ───────────────────────────────────────────────────────

func discover_location(location_id: String) -> void:
	if location_id not in discovered_locations:
		discovered_locations.append(location_id)
		diary_updated.emit()


func discover_character(char_id: String) -> void:
	if char_id in characters and not characters[char_id]["discovered"]:
		characters[char_id]["discovered"] = true
		character_discovered.emit(char_id)
		diary_updated.emit()


func find_evidence(evidence_id: String) -> void:
	if evidence_id in evidence and not evidence[evidence_id]["discovered"]:
		evidence[evidence_id]["discovered"] = true
		evidence_found.emit(evidence_id)
		diary_updated.emit()


func add_interrogation(char_id: String, text: String) -> void:
	if char_id in characters:
		characters[char_id]["interrogations"].append(text)
		diary_updated.emit()


## Регистрирует диалог (до его завершения).
func register_dialogue(dialogue_id: String, character_id: String, lines: Array) -> void:
	if dialogue_id not in dialogue_history:
		dialogue_history[dialogue_id] = {
			"character_id": character_id,
			"lines":        lines,
			"completed":    false,
		}


## Отмечает диалог как завершённый — появляется в дневнике.
func complete_dialogue(dialogue_id: String) -> void:
	if dialogue_id in dialogue_history:
		dialogue_history[dialogue_id]["completed"] = true
		dialogue_completed.emit(dialogue_id)
		diary_updated.emit()


# ─── Геттеры ──────────────────────────────────────────────────────────────────

func get_discovered_characters() -> Array:
	return characters.keys().filter(func(id): return characters[id]["discovered"])

func get_discovered_evidence() -> Array:
	return evidence.keys().filter(func(id): return evidence[id]["discovered"])

func get_completed_dialogues() -> Array:
	return dialogue_history.keys().filter(func(id): return dialogue_history[id]["completed"])

func get_dialogues_for_character(char_id: String) -> Array:
	return dialogue_history.keys().filter(
		func(id): return dialogue_history[id]["character_id"] == char_id \
			and dialogue_history[id]["completed"]
	)


# ─── Сохранение / Загрузка ────────────────────────────────────────────────────

func get_save_data() -> Dictionary:
	return {
		"discovered_locations": discovered_locations,
		"characters":           characters,
		"evidence":             evidence,
		"dialogue_history":     dialogue_history,
	}


func load_save_data(data: Dictionary) -> void:
	discovered_locations = Array(data.get("discovered_locations", []), TYPE_STRING, "", null)

	var saved_chars: Dictionary = data.get("characters", {})
	for cid in saved_chars:
		if cid in characters:
			characters[cid].merge(saved_chars[cid], true)

	var saved_ev: Dictionary = data.get("evidence", {})
	for eid in saved_ev:
		if eid in evidence:
			evidence[eid].merge(saved_ev[eid], true)

	var saved_dh: Dictionary = data.get("dialogue_history", {})
	dialogue_history.merge(saved_dh, true)


func reset() -> void:
	discovered_locations = []
	dialogue_history     = {}
	_init_characters()
	_init_evidence()
