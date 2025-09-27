extends Node

# Tracks currently active quests by chain name -> current QuestData
var active_quests: Dictionary = {}          # chain_name : QuestData
var completed_quests: Dictionary = {}       # chain_name : Array of completed quest names

# Signals
signal quest_assigned(chain_name: String, quest: QuestData)
signal quest_progressed(chain_name: String, quest: QuestData)
signal quest_completed(chain_name: String)

# ------------------------------
# Assign a new quest stage (QuestData)
func assign_quest(quest: QuestData) -> void:
	if quest == null:
		return
	active_quests[quest.quest_chain] = quest
	if not completed_quests.has(quest.quest_chain):
		completed_quests[quest.quest_chain] = []
	emit_signal("quest_assigned", quest.quest_chain, quest)
	print("Assigned quest:", quest.quest_name, "Chain:", quest.quest_chain)

# ------------------------------
# Complete the current quest stage
func complete_quest_stage(quest: QuestData) -> void:
	var chain = quest.quest_chain
	if not active_quests.has(chain):
		print("No active quest for chain", chain)
		return

	# Mark this stage as completed
	completed_quests[chain].append(quest.quest_name)
	emit_signal("quest_progressed", chain, quest)
	print("Completed stage:", quest.quest_name, "of chain:", chain)

	# Advance to the next quest in the chain
	if quest.next_quest != null:
		assign_quest(quest.next_quest)
	else:
		# No next quest → chain completed
		active_quests.erase(chain)
		emit_signal("quest_completed", chain)
		print("Quest chain", chain, "completed!")

# ------------------------------
# Check if a quest is completed
func is_quest_completed(chain_name: String, quest_name: String) -> bool:
	if completed_quests.has(chain_name):
		return quest_name in completed_quests[chain_name]
	return false

# ------------------------------
# Get the currently active quest in a chain
func get_active_quest(chain_name: String) -> QuestData:
	return active_quests.get(chain_name, null)
