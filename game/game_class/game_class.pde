ArrayList<Boid> boids;                      // ← Boidオブジェクトを格納する可変長リスト（あとで setup() で初期化する）
ArrayList<Enemy> enemies;                   // ← Enemyオブジェクトを格納する可変長リスト（あとで setup() で初期化する）
boolean gameOver = false;                   // ← ゲームオーバー状態を示すフラグ（true になればゲーム終了処理へ）
boolean gameClear = false;                  // ← ゲームクリア状態を示すフラグ（true でクリア画面表示）
int startTime;                              // ← ゲーム開始時刻を millis() の値で保存するための変数
int surviveTime = 60 * 1000;  // 60秒    // ← 生存制限時間（ミリ秒）。60 * 1000 は 60 秒をミリ秒に換算した値

void setup() {                              // ← Processing の初期化関数。プログラム開始時に一度だけ呼ばれる
  size(800, 600);                           // ← ウィンドウサイズを幅 800px、高さ 600px に設定（描画領域を準備）

  boids = new ArrayList<Boid>();            // ← boids リストを実体化（空の ArrayList を作る）。これをしないと add() が使えない
  for (int i = 0; i < 100; i++) {           // ← 0 から 99 までのループ（合計 100 回）。Boid を複数生成するために回す
    boids.add(new Boid(random(width), random(height))); // ← 画面内のランダム位置に新しい Boid を作成してリストに追加
  }                                         // ← for ループ（Boid 生成）の終わり

  enemies = new ArrayList<Enemy>();         // ← enemies リストを実体化（空の ArrayList を作る）
  for (int i = 0; i < 3; i++) {             // ← 0 から 2 のループ（合計 3 回）。敵を 3 体生成する
    enemies.add(new Enemy(random(width), random(height))); // ← ランダム位置に Enemy を生成してリストに追加
  }                                         // ← for ループ（Enemy 生成）の終わり

  startTime = millis();                     // ← 現在のミリ秒時間を取得して startTime に保存（以降の経過時間計算の基準）
}                                           // ← setup() 関数の終わり

void draw() {                               // ← 毎フレーム呼ばれる描画・更新関数（通常 60FPS）
  background(30);                           // ← 画面全体を暗めのグレー（輝度 30）で塗りつぶす（前フレームの描画を消す）

  int elapsed = millis() - startTime;       // ← 開始からの経過ミリ秒を計算（現在の millis() から startTime を引く）
  int remain = (surviveTime - elapsed) / 1000; // ← 残り時間を秒単位で計算（ミリ秒を秒に変換して表示用にする）

  // 終了判定
  if (boids.size() == 0) {                  // ← boids リストのサイズが 0（全滅）かをチェック
    gameOver = true;                        // ← 全滅ならゲームオーバーフラグを立てる
  }                                         // ← if の終わり
  if (elapsed >= surviveTime) {             // ← 経過時間が制限時間以上になったかをチェック
    gameClear = true;                       // ← 時間切れ（生存）ならゲームクリアフラグを立てる
  }                                         // ← if の終わり

  // ゲーム終了処理
  if (gameOver || gameClear) {              // ← どちらかの終了状態であれば終了画面を描画してループを止める
    textAlign(CENTER, CENTER);              // ← テキスト描画の基準を「中央揃え（横・縦とも中央）」に設定
    fill(255);                              // ← テキストの塗り色（白）を設定
    textSize(48);                           // ← テキストのフォントサイズを 48 に設定（大きめ）

    if (gameOver) {                         // ← gameOver の場合の分岐
      text("GAME OVER", width/2, height/2); // ← 画面中央に "GAME OVER" を表示
    } else if (gameClear) {                 // ← gameOver でないが gameClear の場合
      text("CLEAR!", width/2, height/2 - 30); // ← 少し上に "CLEAR!" を表示（中央）
      textSize(32);                         // ← 次の行は小さめのフォントに変更
      text("生存Boid: " + boids.size(), width/2, height/2 + 30); // ← 画面中央下に生存 Boid 数を表示
    }                                       // ← if-else の終わり

    noLoop();                               // ← draw() のループを停止（アニメーションを止める）
    return;                                 // ← draw() の処理をここで終了（以降の更新はしない）
  }                                         // ← ゲーム終了処理の if 終わり

  // 敵の更新と描画
  for (Enemy e : enemies) {                 // ← enemies リストを順に取り出して処理する拡張 for 文（各 e は Enemy 型）
    Boid closest = null;                    // ← 敵が追跡する「最も近い Boid」を格納する変数（初期は null）
    float minDist = Float.MAX_VALUE;        // ← 最小距離を比較するための変数を非常に大きな値で初期化

    for (Boid b : boids) {                  // ← boids リストを線形探索して最も近い個体を見つける
      float d = PVector.dist(b.pos, e.pos); // ← b と e の距離を PVector.dist() で計算（ベクトル間のユークリッド距離）
      if (d < minDist) {                    // ← 今までの最小距離より近ければ更新
        minDist = d;                        // ← 新しい最小距離を保存
        closest = b;                        // ← 最も近い Boid として保存
      }                                     // ← if の終わり
    }                                       // ← 内側の for（Boid 探索）の終わり

    if (closest != null) {                  // ← もし近い Boid が見つかっていれば（null でなければ）
      e.update(closest.pos, enemies);       // ← 敵に対して update を呼び、ターゲット位置と敵リストを渡す（追跡・分散等の処理）
    }                                       // ← if の終わり

    e.show();                               // ← 敵を画面に描画（描画処理は Enemy.show() 内にある）
  }                                         // ← 外側の for（各 Enemy の処理）の終わり

  // Boidの更新と描画（逆順で削除対応）
  for (int i = boids.size() - 1; i >= 0; i--) { // ← リストの末尾から先頭へ逆順でループ（要素削除時のインデックスずれ対策）
    Boid b = boids.get(i);                  // ← インデックス i の Boid を取得

    b.update(boids, enemies, new PVector(mouseX, mouseY)); // ← Boid の行動更新を呼ぶ。仲間リスト・敵リスト・リーダー位置（マウス）を渡す
    b.show();                               // ← Boid を画面に描画（Boid.show() が描画処理を行う）

    for (Enemy e : enemies) {               // ← 各 Boid に対して敵との接触判定を行うために敵リストを走査
      if (PVector.dist(b.pos, e.pos) < e.size/2) { // ← Boid と敵の中心距離が敵の半径未満＝接触（捕食）判定
        boids.remove(i);                    // ← 接触していればその Boid をリストから削除（捕食された）
        break;                              // ← その Boid に対する敵チェックを終了して次の Boid へ（i に基づくループは逆順なので安全）
      }                                     // ← if の終わり
    }                                       // ← 敵チェック用の for の終わり
  }                                         // ← Boid 更新ループの終わり

  // 残り時間と生存数表示
  fill(255);                                // ← UI テキストの色を白に設定
  textSize(16);                             // ← UI 用テキストのサイズを 16 に設定
  textAlign(LEFT, TOP);                     // ← 左上基準でテキスト描画を行う設定（左寄せ、上寄せ）
  text("Time: " + remain, 50, 20);          // ← 画面左上に残り時間（秒）を表示。位置は (50,20)
  textAlign(RIGHT, TOP);                    // ← 次は右上基準でテキスト描画（右寄せ、上寄せ）
  text("生存Boid: " + boids.size(), width - 20, 20); // ← 画面右上に生存 Boid 数を表示。 x 座標は width-20（右端から 20px 内側）
}                                           // ← draw() 関数の終わり
