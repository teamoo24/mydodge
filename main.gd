extends Node
@export var mob_scene: PackedScene  # モブ（敵）のシーンをエクスポート変数として定義
var score  # スコア（得点）を保持する変数

func _ready():
	pass  # シーン準備時に呼ばれる。今は何も処理していない

func game_over():
	$ScoreTimer.stop()  # スコアタイマーを停止
	$MobTimer.stop()    # モブ（敵）タイマーを停止
	$HUD.show_game_over()  # ゲームオーバー画面を表示
	get_tree().call_group("mobs","queue_free")  # 全てのモブ（敵）を削除
	$Music.stop()  # 音楽を停止
	$DeathSound.play()  # 死亡時のサウンドを再生

func new_game():
	score = 0  # スコアを初期化
	$Player.start($StartPosition.position)  # プレイヤーを初期位置に移動して開始
	$StartTimer.start()  # スタートタイマー開始
	$HUD.update_score(score)  # スコア表示を更新
	$HUD.show_message("Get Ready")  # 準備メッセージを表示
	$Music.play()  # ゲーム音楽を再生

func _on_score_timer_timeout():
	score += 1  # スコアを1加算
	$HUD.update_score(score)  # スコア表示を更新

func _on_start_timer_timeout():
	$MobTimer.start()    # モブ（敵）タイマー開始
	$ScoreTimer.start()  # スコアタイマー開始

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()  # モブ（敵）を生成
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")  # モブの出現位置を取得
	mob_spawn_location.progress_ratio = randf()  # ランダムな位置に設定

	var direction = mob_spawn_location.rotation + PI / 2  # モブの移動方向を計算

	mob.position = mob_spawn_location.position  # モブの座標を設定
	direction += randf_range(-PI / 4, PI / 4)   # 移動方向にランダム性を加える
	mob.rotation = direction  # モブの回転を設定

	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)  # モブの速度をランダムで設定
	mob.linear_velocity = velocity.rotated(direction)  # 移動方向に合わせて速度ベクトルを回転

	add_child(mob)  # シーンにモブ（敵）を追加