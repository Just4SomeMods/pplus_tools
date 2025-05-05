Scriptname spf_gamereload extends ReferenceAlias  

spfconfigmenu Property QuestScript Auto

Event OnPlayerLoadGame()
	QuestScript.Maintenance()
EndEvent