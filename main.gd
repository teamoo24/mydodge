extends Node

# モブ（敵）のシーンをエクスポート変数として定義
@export var mob_scene: PackedScene

# スコア（得点）を保持する変数
var score

# シーン準備時に呼ばれる。今は何も処理していない
func _ready():
	pass

# ゲームオーバー時の処理
func game_over():
	# スコアタイマーを停止
	$ScoreTimer.stop()
	# モブ（敵）タイマーを停止
	$MobTimer.stop()
	# ゲームオーバー画面を表示
	$HUD.show_game_over()
	# 全てのモブ（敵）を削除
	get_tree().call_group("mobs","queue_free")
	# 音楽を停止
	$Music.stop()
	# 死亡時のサウンドを再生
	$DeathSound.play()

# 新しいゲーム開始時の処理
func new_game():
	# スコアを初期化
	score = 0
	# プレイヤーを初期位置に移動して開始
	$Player.start($StartPosition.position)
	# スタートタイマー開始
	$StartTimer.start()
	# スコア表示を更新
	$HUD.update_score(score)
	# 準備メッセージを表示
	$HUD.show_message("Get Ready")
	# ゲーム音楽を再生
	$Music.play()

# スコアタイマータイムアウト時の処理
func _on_score_timer_timeout():
	# スコアを1加算
	score += 1
	# スコア表示を更新
	$HUD.update_score(score)

# スタートタイマータイムアウト時の処理
func _on_start_timer_timeout():
	# モブ（敵）タイマー開始
	$MobTimer.start()
	# スコアタイマー開始
	$ScoreTimer.start()

# モブタイマータイムアウト時の処理
func _on_mob_timer_timeout():
	# モブ（敵）を生成
	var mob = mob_scene.instantiate()
	# モブの出現位置を取得
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	# ランダムな位置に設定
	mob_spawn_location.progress_ratio = randf()

	# モブの移動方向を計算
	var direction = mob_spawn_location.rotation + PI / 2

	# モブの座標を設定
	mob.position = mob_spawn_location.position
	# 移動方向にランダム性を加える
	direction += randf_range(-PI / 4, PI / 4)
	# モブの回転を設定
	mob.rotation = direction

	# モブの速度をランダムで設定
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	# 移動方向に合わせて速度ベクトルを回転
	mob.linear_velocity = velocity.rotated(direction)

	# シーンにモブ（敵）を追加
	add_child(mob)