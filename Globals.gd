extends Node

# Global game settings
@export var score: int = 0
@export var game_started: bool = false
@export var game_speed: float = 3.0
@export var game_height: float = 15.0  # Height of the playable area
@export var min_y: float = -game_height/2
@export var max_y: float = game_height/2
@export var game_width: float = 15.0  # Width of the playable area (lane count)
@export var min_x: float = -game_width/2
@export var max_x: float = game_width/2
@export var platform_gap: float = 0.5  # Distance between platforms
@export var platform_height_diff: float = 2.0 
@export var player_lookahead: float = 50.0 # units the player can see ahead (affects platform generation)

# Sizes
@export var player_size: float = 0.75
@export var platform_base_length: float = 3.0
@export var platform_height: float = 0.5

func reset():
	game_started = false
	game_speed = 3.0
	platform_gap = 1.0  # Distance between platforms
	platform_height_diff = 2.0
	platform_base_length = 3.0
