class_name HUD extends CanvasLayer

@onready var high_score:int = 1
@onready var peak_score:int = 1
@onready var score:int = 1:
	get:
		return score
	set(value):
		if value < 0:
			score = 0
		else:
			score = value
		if score > peak_score:
			peak_score = score
		$HUD/MarginContainer/Label.text = "Score: %d/%d" % [score, peak_score]
	
func game_over(show=true):
	if high_score < peak_score:
		high_score = peak_score
		$HUD/GameOverBox/ScoreLabel.text = "New High Score: %d" % high_score
	else:
		$HUD/GameOverBox/ScoreLabel.text = "Score: %d | High Score: %d" % [peak_score, high_score]
	$HUD/GameOverBox.visible = show

func reset():
	game_over(false)
	peak_score = 1
	score = 1
