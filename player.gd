extends Area2D  # プレイヤーキャラクターの基本ノード。2D空間での当たり判定を管理。
signal hit  # プレイヤーが何かに当たったときに発信されるシグナル。

@export var speed: float = 400  # プレイヤーの移動速度（エディタから変更可能）。
var screen_size  # 画面サイズを保存する変数。

func _ready():
	screen_size = get_viewport().size  # ゲーム画面のサイズを取得。
	# ノードがシーンに追加されたときに呼ばれる初期化関数。
	hide()  # プレイヤーを非表示にする。ゲーム開始時は見えないようにする。

func _process(delta):
	# 毎フレーム呼ばれる関数。プレイヤーの状態を更新する。
	var velocity = Vector2.ZERO  # プレイヤーの移動速度ベクトル（初期化）。

	# 入力に応じて移動方向を決定。
	if Input.is_action_pressed("move_right"):
		velocity.x += 1  # 右に移動
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1  # 左に移動
	if Input.is_action_pressed("move_down"):
		velocity.y += 1  # 下に移動
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1  # 上に移動

	if velocity.length() > 0:
		# ベクトルの正規化と速度の適用
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()  # アニメーション再生
	else:
		$AnimatedSprite2D.stop()  # 移動していない時はアニメーション停止

	# 実際にプレイヤーを移動させる
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)  # 画面の端を超えないようにする

	# アニメーションの切り替えと向きの調整
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"  # 横移動アニメーション
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0  # 左に移動なら反転
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"  # 縦移動アニメーション
		$AnimatedSprite2D.flip_v = velocity.y > 0  # 下に移動なら上下反転

func _on_body_entered(_body):
	# プレイヤーが他の物体（敵や障害物など）と接触したときに呼ばれる
	hide()  # プレイヤーを非表示に
	hit.emit()  # シグナル発信（例：ライフ減少などに利用）
	$CollisionShape2D.set_deferred("disabled", true)  # 当たり判定を無効化

func start(pos):
	# プレイヤーを指定位置に表示してゲームを開始する
	position = pos  # 指定された位置に移動
	show()  # プレイヤーを表示
	$CollisionShape2D.disabled = false  # 当たり判定を有効化