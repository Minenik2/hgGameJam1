extends Resource
class_name QuestData

enum questTYPE {
	UNIQUE,
}

@export var quest_name: String = ""       # Name of the specifc quest
@export var quest_chain: String = ""      # name of the whole quest chain
@export var quest_type: questTYPE = questTYPE.UNIQUE
@export var next_quest: QuestData
@export var description: String = ""      # For questbook UI


# Optional: could store requirements for this stage
@export_category("Quest Specifics")
@export var required_item_name: String = ""
# below is the variable name to make it true in the dialogue state
# to use as a kind of mark as the quest is completed, between the dialogue and questManager component
@export var dialogue_state_true: Array[String] = []         # e.g., ["givenFragment1"]
