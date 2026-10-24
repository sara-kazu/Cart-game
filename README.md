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

## Surface / VS Code / GitHubで編集する

ZIPのフォルダーはGitHubと連携しません。GitをインストールしてVS Codeを再起動し、以下の手順でクローンしてください。
既にZIP側で編集した場合は、そのファイルを別に保存してからクローン先へ反映してください。

1. VS Codeで Ctrl+Shift+P → `Git: Clone` を選ぶ。
2. `https://github.com/sara-kazu/Cart-game.git` を入力する。
3. ZIPの展開先とは別の親フォルダーを選び、クローン後に「開く」。
4. GitHubの認証が表示されたら、自分のアカウントでログインする。
5. ワークスペースを信頼してよいか聞かれたら、このリポジトリの内容を確認して信頼する。
6. 推奨拡張機能「Godot Tools」をインストールする。拡張機能画面の検索欄で `@recommended` と入力しても見つかる。

VS Codeの「ターミナル → タスクの実行」から、次のタスクを選べます。

- `Godot: エディターを開く`
- `Godot: ゲームを実行`
- `Godot: 自動テスト`

実行時にGodotの場所を聞かれます。ダウンロード済みのGodot 4の `.exe` のフルパスを、引用符を付けずに入力してください。
例: `C:\Tools\Godot\Godot_v4.6.3-stable_win64.exe` （実際のファイル名・保存先に合わせて変更）。
PATHに登録済みなら `godot` のままで実行できます。Godot本体はこの設定では自動インストールされません。
Godot Toolsの入力補助は、同じプロジェクトをGodotエディターでも開いて利用します。

### 日々の保存と同期

- 作業開始前：ソース管理の「…」→「プル」でGitHubの変更を取得する。
- 編集後：Ctrl+Sでローカル保存し、Godotで動作を確認する。
- GitHubへ保存：ソース管理でファイル横の「+」→メッセージ入力→「コミット」→「プッシュ」。
- 他のPCやクラウドでの変更を取り込む：「プル」。未保存・未コミットの変更がある場合は、先に保存とコミットを行う。

コミット時に名前とメールを求められた場合は、VS Codeのターミナルで以下を実行します。
`--global` を付けないため、このクローンだけの設定になります。値は自分のものに置き換えてください。

```sh
git config user.name "自分のGitHub名"
git config user.email "自分のGitHubメールまたはnoreplyアドレス"
```

GitHubに保存されるのはプッシュした変更です。Ctrl+Sだけではクラウドと同期されません。
GodotはVS Codeで編集しているクローンと同じ `project.godot` を開いてください。
