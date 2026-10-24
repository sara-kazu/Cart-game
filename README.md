# POCKET KART / Meadow Loop

Godot 4用の、スーパーファミコン風の見下ろし型2Dカートレース試作です。
画像素材・外部ライブラリ・3D描画は使いません。Compatibilityレンダラーと固定コースの描画で負荷を抑えています。

## 起動

Godot 4で `project.godot` を開いて **F6ではなくF5** で実行してください。
ターミナルでは、リポジトリ内で `godot --path .` を実行できます。

- ↑ / W：加速
- ↓ / S：減速・後退
- ← → / A D：ハンドル（走行中に旋回）
- Space：ブレーキ
- R：タイムと周回をリセット
- Esc：一時停止・再開

スタートから右へ走り、時計回りに周回します。カーブでは速度を落としてください。
東・南・西・スタートのチェックポイントを順番に通ると周回数が増えます。
草地では速度が落ち、逆走やインフィールドのショートカットでは周回が増えません。
HUDに現在のラップ、ラップタイム、最速タイム、速度（ゲーム内単位）を表示します。
走行はエンドレスで、対戦相手・音声・保存機能はまだありません。

## 検証

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/smoke.gd
```

このクラウド環境ではホームへの書き込みが制限されるため、実行前に以下を設定します。

```sh
export XDG_DATA_HOME=/tmp/cart-game-data
export XDG_CONFIG_HOME=/tmp/cart-game-config
export XDG_CACHE_HOME=/tmp/cart-game-cache
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
```

テストは加速・旋回・ブレーキ・草地の減速・2周のカウント・最速タイム・逆走・ショートカット・リセットを検証します。
古いSurface実機でのFPSやキー操作、ウィンドウ表示は別途確認してください。
Godot 4 Compatibilityを動かせるOpenGL 3.3対応のドライバーが必要です。
