class_name Conversation

## Plays a Dialogic timeline as a conversation: the fox — and whoever it talks to — stops and turns
## to the other, the dialogue runs (F advances it and picks the focused choice), then both carry on.
## The one place that starts a dialogue, so the NPC and the locked door don't repeat this.
## The partner needs a "talk" state of its own. F works for both sides because the stage's nodes
## see a key before the Dialogic autoload: InteractiveArea3D lets it through while the fox talks.


static func play(timeline: String, fox: Player, partner: BaseCharacter = null) -> void:
	if fox.is_talking or Dialogic.current_timeline != null:
		return    # already talking — a second press of F
	fox.start_talk(partner)
	if partner != null:
		partner.start_talk(fox)
	# F picks the focused choice too, not only Enter / Space.
	Dialogic.Choices.use_input_action = true
	Dialogic.start(timeline)
	await Dialogic.timeline_ended
	# A stage change ends the dialogue too: by then the fox may be gone.
	if is_instance_valid(fox):
		fox.finish_talk()
	if partner != null and is_instance_valid(partner):
		partner.finish_talk()
