extends VBoxContainer

var logEntries = 0
const QUEST_1 = preload("uid://7ht8jc8rlrdf")

func _ready() -> void:
	QuestManager.connect("quest_progressed",questProgressed)
	QuestManager.connect("quest_assigned",updateLogAssigned)
	QuestManager.connect("quest_completed",questCompleted)
	QuestManager.assign_quest(QUEST_1)

func updateLog(questChain: String, quest: QuestData):
	
	%questChainTitle.text = questChain
	%questTitle.text = "Log %s: %s" % [str(logEntries).pad_zeros(2), quest.quest_name]
	%RichTextLabel.text = quest.description

func questProgressed(questChain: String, quest: QuestData):
	logEntries += 1
	updateLog(questChain, quest)

func updateLogAssigned(questChain: String, quest: QuestData):
	updateLog(questChain, quest)

func questCompleted(questChain):
	%questChainTitle.text = questChain
	%questTitle.text = "Log %s: %s" % [str(logEntries).pad_zeros(2), "completed"]
	%RichTextLabel.text = "The path is written, but yours might continue through the endless dark.\nThe quest has been completed"
