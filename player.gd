# プレイヤーキャラクターの基本ノード。2D空間での当たり判定を管理。
extends Area2D

# プレイヤーが何かに当たったときに発信されるシグナル。
signal hit

# プレイヤーの移動速度（エディタから変更可能）。
@export var speed: float = 400

# 画面サイズを保存する変数。
var screen_size

# ノードがシーンに追加されたときに呼ばれる初期化関数。
func _ready():
	# ゲーム画面のサイズを取得。
	screen_size = get_viewport().size
	# プレイヤーを非表示にする。ゲーム開始時は見えないようにする。
	hide()

# 毎フレーム呼ばれる関数。プレイヤーの状態を更新する。
func _process(delta):
	# プレイヤーの移動速度ベクトル（初期化）。
	var velocity = Vector2.ZERO

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
		# アニメーション再生
		$AnimatedSprite2D.play()
	else:
		# 移動していない時はアニメーション停止
		$AnimatedSprite2D.stop()

	# 実際にプレイヤーを移動させる
	position += velocity * delta
	# 画面の端を超えないようにする
	position.x = clamp(position.x, 0, screen_size.x)

	# アニメーションの切り替えと向きの調整
	if velocity.x != 0:
		# 横移動アニメーション
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# 左に移動なら反転
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		# 縦移動アニメーション
		$AnimatedSprite2D.animation = "up"
		# 下に移動なら上下反転
		$AnimatedSprite2D.flip_v = velocity.y > 0

# プレイヤーが他の物体（敵や障害物など）と接触したときに呼ばれる
func _on_body_entered(_body):
	# プレイヤーを非表示に
	hide()
	# シグナル発信（例：ライフ減少などに利用）
	hit.emit()
	# 当たり判定を無効化
	$CollisionShape2D.set_deferred("disabled", true)

# プレイヤーを指定位置に表示してゲームを開始する
func start(pos):
	# 指定された位置に移動
	position = pos
	# プレイヤーを表示
	show()
	# 当たり判定を有効化
	$CollisionShape2D.disabled = false