// ========================= グローバル変数 =========================
// 以下はプログラム全体で使う変数を宣言している場所です。
// 各行ごとに「何を保持しているか」「型・役割」をコメントで詳しく書いています。

// 群れ（Boid 型オブジェクト）を入れる可変長リストを宣言する。
// ArrayList<Boid> 型は Boid オブジェクトを複数保持でき、実行中に追加・削除が可能。
ArrayList<Boid> boids;                     // ← 群れを管理する箱（初期化は setup() 内で行う）

// 敵（Enemy 型オブジェクト）を入れる可変長リストを宣言する。
// 複数の敵を管理するために使う。
ArrayList<Enemy> enemies;                  // ← 敵を管理する箱（初期化は setup() 内で行う）

// ゲーム状態を表すフラグ（真偽値）を宣言。
// gameOver が true だと「全滅によるゲームオーバー」と判断する。
boolean gameOver = false;                  // ← 初期値 false（ゲーム開始時は未終了状態）

// ゲームクリア（時間切れ生存）を示すフラグ。
// gameClear が true だと「制限時間まで生存してクリア」と判断する。
boolean gameClear = false;                 // ← 初期値 false（ゲーム開始時は未クリア）

// ゲーム開始時刻をミリ秒で保持する変数。
// millis() の値をここに保存して、経過時間 = millis() - startTime として利用する。
int startTime;                             // ← setup() で初期化される

// 制限時間（ミリ秒単位）を設定する。
// ここでは 60 秒を指定しているので 60 * 1000 = 60000 ミリ秒。
int surviveTime = 60 * 1000;               // ← 制限時間（ミリ秒）

// ========================= 初期設定（setup） =========================
// setup() はプログラム開始時に一度だけ呼ばれる初期化関数です。
// ウィンドウサイズや初期オブジェクト配置などをここで行います。
void setup() {                              // ← setup 関数の開始
  size(800, 600);                           // ← ウィンドウサイズを横800×縦600に設定

  // Boid リストを空の ArrayList として初期化する。
  // ここで箱を作らないと boids.add() が使えない。
  boids = new ArrayList<Boid>();            // ← boids を実際に使える状態にする

  // Boid を複数生成してリストに追加するループ（ここでは 100 匹）。
  for (int i = 0; i < 100; i++) {           // ← i を 0 から 99 まで増やすループ
    // 各 Boid を画面内のランダムな位置に配置して生成し、boids に追加する。
    // random(width) と random(height) はそれぞれ X, Y のランダム座標を返す。
    boids.add(new Boid(random(width), random(height))); // ← Boid を生成して箱に入れる
  }                                         // ← for ループの終わり

  // Enemy リストを空の ArrayList として初期化する。
  enemies = new ArrayList<Enemy>();         // ← enemies を使える箱にする

  // 敵を複数生成してリストに追加（ここでは 3 体）。
  for (int i = 0; i < 3; i++) {             // ← 敵作成ループ（0,1,2）
    // ランダムな位置に Enemy を生成して enemies リストに追加
    enemies.add(new Enemy(random(width), random(height))); // ← 敵を生成して追加
  }                                         // ← for ループの終わり

  // ゲーム開始時刻を millis() で取得して startTime に保存する。
  // 以後、経過時間 = millis() - startTime で求める。
  startTime = millis();                     // ← 時刻の基準をここで決める
}                                           // ← setup 関数の終わり

// ========================= 毎フレーム描画（draw） =========================
// draw() は毎フレーム（通常 60 FPS）呼ばれる関数で、ここで更新・描画を行う。
void draw() {                               // ← draw 関数の開始
  background(30);                           // ← 背景を暗めのグレー（値 30）で塗りつぶす

  // 経過時間（ミリ秒）を計算する。
  int elapsed = millis() - startTime;       // ← ゲーム開始からの経過ミリ秒

  // 残り時間を秒単位で計算（UI 表示用）。
  int remain = (surviveTime - elapsed) / 1000; // ← 残り秒（小数切捨て）

  // ゲーム終了条件の判定（Boid 全滅でゲームオーバー）
  if (boids.size() == 0) gameOver = true;   // ← boids.size() が 0 のとき全滅
  // 制限時間経過でゲームクリア
  if (elapsed >= surviveTime) gameClear = true; // ← 制限時間に達したらクリア

  // ゲームが終了状態（gameOver か gameClear）なら終了画面を描き、ループを止める。
  if (gameOver || gameClear) {               // ← 終了処理に入る条件
    textAlign(CENTER, CENTER);               // ← テキストを中央に配置する設定
    fill(255);                               // ← テキスト色を白にする
    textSize(48);                            // ← 大きめの文字サイズを設定

    if (gameOver) {                          // ← gameOver の場合
      text("GAME OVER", width/2, height/2); // ← 画面中央に "GAME OVER" を表示
    } else {                                 // ← gameClear の場合（gameOver でなければ）
      text("CLEAR!", width/2, height/2 - 30); // ← "CLEAR!" を少し上に表示
      textSize(32);                          // ← 生存数を小さめの文字で表示
      text("生存Boid: " + boids.size(), width/2, height/2 + 30); // ← 生存数を表示
    }

    noLoop();                                // ← draw のループを停止（アニメーション停止）
    return;                                  // ← draw 関数の処理をここで終了
  }                                          // ← 終了描画の if 終わり

  // ================= 敵の更新＆描画 =================
  // 各 Enemy ごとに「最も近い Boid を探して追う」「分散動作で他の敵と重ならないようにする」
  for (Enemy e : enemies) {                  // ← enemies リストを順に処理する拡張 for
    Boid closest = null;                     // ← 最も近い Boid を格納する変数を初期化（まだ見つかっていない）
    float minDist = Float.MAX_VALUE;         // ← 最小距離を非常に大きい値で初期化（必ず更新される）

    // 全 Boid を線形探索して最も近い Boid を見つける
    for (Boid b : boids) {                   // ← boids の各要素を順に処理
      float d = PVector.dist(b.pos, e.pos); // ← b と e の距離を計算（PVector.dist を使用）
      if (d < minDist) {                    // ← より近ければ最小値を更新
        minDist = d;                        // ← 新しい最小距離を保存
        closest = b;                        // ← 最も近い Boid を保存
      }                                      // ← if の終わり
    }                                        // ← 内部 for の終わり

    // 最も近い Boid をターゲットとして e を更新（追尾行動）
    if (closest != null) e.update(closest.pos, enemies, remain); // ← closest が null でなければ update を呼ぶ

    e.show();                                // ← 敵を画面に描画
  }                                          // ← 敵処理の for 終わり

  // ================= Boid の更新＆描画 =================
  // 削除操作（捕食）に対応するため、逆順でループ（インデックスずれを避ける）
  for (int i = boids.size() - 1; i >= 0; i--) { // ← 逆順ループ開始（最後の要素から最初へ）
    Boid b = boids.get(i);                   // ← i 番目の Boid を参照取得

    // Boid の行動更新：仲間、敵、リーダー（マウス位置）を渡す
    b.update(boids, enemies, new PVector(mouseX, mouseY), remain); // ← マウス座標を PVector にして渡す
    b.show();                                // ← Boid を描画

    // 敵との接触判定：もし Boid が敵の半径内に入っているなら捕食される（削除）
    for (Enemy e : enemies) {                // ← 全敵をチェック
      if (PVector.dist(b.pos, e.pos) < e.size/2) { // ← 距離が敵の半径未満か？
        boids.remove(i);                      // ← Boid をリストから削除（捕食された）
        break;                                // ← この Boid に対する敵チェック終了
      }                                        // ← if 終わり
    }                                          // ← 敵チェックの for 終わり
  }                                            // ← Boid 更新ループの終わり

  // ================= UI 表示（残り時間・生存数） =================
  fill(255);                                  // ← テキスト色を白に設定
  textSize(16);                               // ← UI 用の小さめの文字サイズを指定

  // 左上に残り時間を表示（"Time: N"）
  textAlign(LEFT, TOP);                       // ← テキストを左上基準に揃える
  text("Time: " + remain, 50, 20);            // ← (x=50,y=20) に残り時間を表示

  // 右上に生存 Boid 数を表示
  textAlign(RIGHT, TOP);                      // ← テキストを右上基準に揃える
  text("生存Boid: " + boids.size(), width - 20, 20); // ← 右上に生存数を表示（x=width-20）
}                                            // ← draw 関数の終わり

// ========================= Boid クラス =========================
// 群れを構成する個体（Boid）の定義。
// pos（位置）と vel（速度）を PVector で持ち、整列・結合・分離のルールを実装する。
class Boid {                                 // ← Boid クラスの開始
  PVector pos, vel;                          // ← 位置ベクトル pos、速度ベクトル vel を宣言
  float baseSpeed = 4;                       // ← 通常時の速さ（スカラー）
  float maxSpeed = 4;                        // ← 現在の最大速度（状況により変化）
  float maxForce = 0.1;                      // ← 加速度（舵）の上限。小さいほど滑らかに曲がる

  // コンストラクタ：新しい Boid を生成するときに初期位置を引数で受け取る
  Boid(float x, float y) {                   // ← コンストラクタ開始（x,y は初期座標）
    pos = new PVector(x, y);                 // ← pos を (x,y) で初期化
    vel = PVector.random2D();                // ← vel をランダムな単位ベクトルで初期化（ランダムな向き）
  }                                          // ← コンストラクタの終わり

  // update メソッド：Boid の行動を計算して位置を更新する
  // 引数：
  //  - boids : 仲間リスト（近傍計算に使用）
  //  - enemies : 敵リスト（敵回避のため）
  //  - leader : リーダー位置（ここではマウス）
  //  - remainTime : 残り時間（秒）— 速度制御に使用
  void update(ArrayList<Boid> boids, ArrayList<Enemy> enemies, PVector leader, int remainTime) { // ← update 開始
    // --- 残り時間に応じた速度変化の計算 ---
    if (remainTime <= 30 && remainTime > 10) { // ← 残り 30 秒〜11 秒の範囲
      // map(30 - remainTime, 0, 20, 0, 2) :
      //   - remainTime が 30 の時 => map(0,0,20,0,2) = 0
      //   - remainTime が 10 の時 => map(20,0,20,0,2) = 2
      // そのため maxSpeed は baseSpeed → baseSpeed + 2 の範囲で線形に増える
      maxSpeed = baseSpeed + map(30 - remainTime, 0, 20, 0, 2); // ← 緩やかに加速
    } else if (remainTime <= 10) {            // ← 残り 10 秒以下
      // pow(2, (10 - remainTime)/2.0) は指数関数的に増える（劇的な加速）
      maxSpeed = baseSpeed * pow(2, (10 - remainTime) / 2.0);  // ← 急加速（指数）
      if (maxSpeed > 12) maxSpeed = 12; // ← 安全上の上限（速度が発散しないように制限）
    } else {                                  // ← 通常時（remainTime > 30）
      maxSpeed = baseSpeed;                   // ← 通常速度に設定
    }                                         // ← 速度制御の if 終わり

    // --- 加速度（合力）を合成する ---
    PVector acc = new PVector();              // ← 加速度ベクトル acc をゼロベクトルで初期化

    // leader（マウス）へ向かうベクトルを求め、重み 1.5 をかけて acc に加える（追従性を調整）
    acc.add(seek(leader).mult(1.5));          // ← マウス追従（重みで強さを調整）

    // 敵の位置へ向かうベクトルを負の重みで加えることで「敵から逃げる」挙動を実現する
    for (Enemy e : enemies) {                 // ← 全敵についてループ
      acc.add(seek(e.pos).mult(-0.5));        // ← 敵から離れる力を -0.5 の重みで追加
    }                                         // ← for 終わり

    // 仲間と向きを揃える整列力（小さめの重み）
    acc.add(align(boids).mult(0.1));          // ← 整列力を重み 0.1 で追加

    // 群れの中心に寄せる結合力（さらに小さい重み）
    acc.add(cohesion(boids).mult(0.05));      // ← 結合力を重み 0.05 で追加

    // 近距離での衝突を避ける分離力（やや強めの重み）
    acc.add(separate(boids).mult(0.3));       // ← 分離力を重み 0.3 で追加

    // --- 速度と位置の更新（離散時間積分） ---
    vel.add(acc);                             // ← 速度に加速度を足す（v ← v + a）
    vel.limit(maxSpeed);                      // ← 速度の大きさを maxSpeed 以下に制限
    pos.add(vel);                             // ← 位置に速度を足して移動（p ← p + v）

    // --- 画面端の処理（跳ね返り） ---
    if (pos.x < 0) { pos.x = 0; vel.x *= -1; } // ← 左端を超えたら位置補正して X 成分反転
    if (pos.x > width) { pos.x = width; vel.x *= -1; } // ← 右端を超えたら補正して反転
    if (pos.y < 0) { pos.y = 0; vel.y *= -1; } // ← 上端を超えたら補正して Y 成分反転
    if (pos.y > height) { pos.y = height; vel.y *= -1; } // ← 下端を超えたら補正して反転
  }                                           // ← update の終わり

  // ========================= seek 関数 =========================
  // 指定した target 方向へ向かうための「加速度（steering）」ベクトルを返す。
  PVector seek(PVector target) {               // ← seek 開始（引数 target = 目的地）
    // 目的地方向ベクトル = target - pos（自分から目的地へのベクトル）
    // setMag(maxSpeed) でそのベクトルの大きさを現在の最大速度に揃える（desired velocity）
    PVector desired = PVector.sub(target, pos).setMag(maxSpeed); // ← 目的地への望ましい速度

    // steering = desired - current_velocity（現在速度との差分が加速度になる）
    // limit(maxForce) で急な変化を抑え、滑らかさを保つ
    return PVector.sub(desired, vel).limit(maxForce); // ← 求めた加速度を返す
  }                                              // ← seek 終了

  // ========================= align 関数 =========================
  // 周囲の仲間の平均速度に合わせるためのベクトルを返す（整列行動）。
  PVector align(ArrayList<Boid> boids) {         // ← align 開始
    PVector sum = new PVector();                 // ← 近傍の速度合計を入れるベクトルを初期化
    int cnt = 0;                                 // ← 近傍に何匹いたかを数えるカウンタ

    for (Boid o : boids) {                       // ← 全仲間をチェックするループ（O(N)）
      if (o != this) {                           // ← 自分自身は除外（this は自分のオブジェクト）
        if (dist(pos.x, pos.y, o.pos.x, o.pos.y) < 50) { // ← 範囲 50px より近い仲間だけ考慮
          sum.add(o.vel);                        // ← 近い仲間の速度ベクトルを足す
          cnt++;                                 // ← カウンタをインクリメント
        }                                        // ← 内側 if 終わり
      }                                          // ← 自分除外の if 終わり
    }                                            // ← for 終わり

    if (cnt > 0) {                               // ← 近傍が存在する場合
      // 平均速度を計算して自分の速度との差分（steering）を計算し、加速度上限で制限して返す
      return PVector.sub(sum.div(cnt).setMag(maxSpeed), vel).limit(maxForce);
    }

    return new PVector();                        // ← 近傍がなければゼロベクトルを返す
  }                                              // ← align 終了

  // ========================= cohesion 関数 =========================
  // 近くの仲間の位置の平均（群れの中心）に向かうベクトルを返す（結合行動）。
  PVector cohesion(ArrayList<Boid> boids) {      // ← cohesion 開始
    PVector sum = new PVector();                 // ← 近傍の位置合計を貯める
    int cnt = 0;                                 // ← 近傍数カウンタ

    for (Boid o : boids) {                       // ← 全仲間をチェック
      if (o != this) {                           // ← 自分は除外
        if (dist(pos.x, pos.y, o.pos.x, o.pos.y) < 70) { // ← 70px 未満の近傍のみ考慮
          sum.add(o.pos);                        // ← 近い仲間の位置を合計
          cnt++;                                 // ← カウンタ増加
        }                                        // ← if 終わり
      }                                          // ← if 終わり
    }                                            // ← for 終わり

    if (cnt > 0) return seek(sum.div(cnt));      // ← 平均位置に向かう（seek を使って滑らかに）
    return new PVector();                        // ← 近傍なしならゼロベクトル
  }                                              // ← cohesion 終了

  // ========================= separate 関数 =========================
  // 近すぎる仲間と距離を保つための回避ベクトルを返す（分離行動）。
  PVector separate(ArrayList<Boid> boids) {      // ← separate 開始
    PVector steer = new PVector();               // ← 回避力を蓄積するベクトル
    int cnt = 0;                                 // ← 近接した仲間の数を数える

    for (Boid o : boids) {                       // ← 全仲間をチェック（O(N)）
      float d = dist(pos.x, pos.y, o.pos.x, o.pos.y); // ← 自分と o の距離を計算
      if (d > 0 && d < 25) {                     // ← 自分以外でかつ 25px 未満（近すぎる）なら処理
        // 相手から自分へ向かうベクトルを作る（PVector.sub(pos, o.pos)）
        // normalize() で方向だけにして、div(d) で「近ければ強く、遠ければ弱く」効果にする
        PVector diff = PVector.sub(pos, o.pos).normalize().div(d); // ← 回避方向を計算
        steer.add(diff);                         // ← 回避ベクトルを累積
        cnt++;                                   // ← カウンタ増加
      }                                          // ← if 終わり
    }                                            // ← for 終わり

    if (cnt > 0) {                               // ← 近接した仲間がいた場合
      // 平均を取り、望ましい速度スケールに変更し、現在速度との差をとって制限をかける
      return steer.div(cnt).setMag(maxSpeed).sub(vel).limit(maxForce);
    }

    return new PVector();                        // ← 近接がなければゼロベクトルを返す
  }                                              // ← separate 終了

  // ========================= 描画（show） =========================
  void show() {                                  // ← show 開始（Boid を画面に描く）
    // vel.heading() は速度ベクトルの向きを返す（ラジアン）。
    // HALF_PI を足すのは三角形の向き合わせのための補正。
    float theta = vel.heading() + HALF_PI;       // ← 描画回転角を計算

    pushMatrix();                                // ← 現在の変換行列を保存（座標系のスタック）
    translate(pos.x, pos.y);                     // ← 描画原点を Boid の位置に移動
    rotate(theta);                               // ← 進行方向に合わせて回転
    fill(200, 200, 255);                         // ← 塗り色を薄い水色に設定
    stroke(100);                                 // ← 枠線の色を指定
    triangle(0, -6, -3, 6, 3, 6);                // ← 三角形で Boid（鳥っぽさ）を描く
    popMatrix();                                 // ← 変換行列を元に戻す
  }                                              // ← show 終了
}                                                // ← Boid クラスの終わり

// ========================= Enemy クラス =========================
// Boid を追いかける敵キャラ。近い敵同士は分散して重ならないようにする。
class Enemy {                                   // ← Enemy クラス開始
  PVector pos, vel;                              // ← 位置 pos と速度 vel を保持
  float maxSpeed = 2.5;                          // ← 基本追跡速度（スカラー）
  float maxForce = 0.2;                          // ← 加速度の上限（舵の限界）
  float size = 60;                               // ← 見た目の大きさ（直径）および当たり判定に使用

  // コンストラクタ：初期位置を受け取り、pos を初期化、vel はゼロにする
  Enemy(float x, float y) {                      // ← コンストラクタ開始
    pos = new PVector(x, y);                     // ← 初期位置を設定
    vel = new PVector();                         // ← 初期は停止（0,0） vel反射
  }                                               // ← コンストラクタ終わり

  // update：追尾と分散を含む敵の行動更新
  // 引数 target = 追尾対象の位置（Boid の pos）
  // 引数 enemies = 敵リスト（分散計算に使用）
  // 引数 remainTime = 残り秒（速度の加速に使用）
  void update(PVector target, ArrayList<Enemy> enemies, int remainTime) { // ← update 開始
    float speed = maxSpeed;                       // ← 現在決めるべきスピードを初期化

    // 30秒〜10秒では線形に少しずつ加速する
    if (remainTime <= 30 && remainTime > 10) {    // ← 範囲チェック
      speed = maxSpeed + map(30 - remainTime, 0, 20, 0, 5); // ← 線形増加（0→5 の範囲）
    }
    // 10秒以下は指数的に急加速する（緊迫感を出す）
    else if (remainTime <= 10) {                  // ← 10秒以下
      speed = maxSpeed * pow(2, (10 - remainTime) / 2.0); // ← 指数的増加
      if (speed > 20) speed = 20;                 // ← 極端に速くならないよう上限を設定
    }                                             // ← speed 制御の終わり

    // 目的地（target）への「望ましい速度」ベクトルを作る（大きさ = speed）
    PVector desired = PVector.sub(target, pos).setMag(speed); // ← 目的方向の速度ベクトル

    // 現在の vel との差が steer（加速ベクトル）になる。limit で加速を制限する。
    PVector steer = PVector.sub(desired, vel).limit(maxForce); // ← 基本の steering

    // 敵同士の分散：近すぎる他の敵がいたら押し返す力を加える
    for (Enemy other : enemies) {                 // ← 全敵を調べる
      if (other != this) {                        // ← 自分自身は無視（自己比較防止）
        float d = PVector.dist(this.pos, other.pos); // ← this と other の距離を計算

        // もし近すぎる（size 未満）なら押し返し力を計算して加える
        if (d > 0 && d < size) {                 // ← d>0 は自己比較除外の保険
          // this.pos - other.pos は「相手から自分へ向かうベクトル」
          // normalize() で方向のみ、div(d) で距離に反比例する重みを付与（近いほど強くなる）
          PVector diff = PVector.sub(this.pos, other.pos).normalize().div(d); // ← 分散方向
          steer.add(diff.mult(0.5));             // ← 力を少し弱めて steer に追加（0.5 倍）
        }                                         // ← if 終わり
      }                                           // ← 自分除外の if 終わり
    }                                             // ← for 終わり

    // 速度に加速度（steer）を加えて速度を更新
    vel.add(steer);                               // ← vel ← vel + steer
    // 位置を速度で更新する（シンプルな数値積分）
    pos.add(vel);                                 // ← pos ← pos + vel

    // 画面端で跳ね返らせる（位置補正と速度反転）
    if (pos.x < 0) { pos.x = 0; vel.x *= -1; }    // ← 左端に行かせない・反転
    if (pos.x > width) { pos.x = width; vel.x *= -1; } // ← 右端同様
    if (pos.y < 0) { pos.y = 0; vel.y *= -1; }    // ← 上端同様
    if (pos.y > height) { pos.y = height; vel.y *= -1; } // ← 下端同様
  }                                               // ← Enemy.update の終わり

  // 描画：敵を円形で描く
  void show() {                                   // ← show 開始
    fill(255, 50, 50);                            // ← 赤色で塗る（R=255,G=50,B=50）
    noStroke();                                   // ← 枠線なし（円がシンプルに見える）
    ellipse(pos.x, pos.y, size, size);            // ← 中心 pos.x,pos.y で直径 size の円を描く
  }                                               // ← show 終了
}                                                 // ← Enemy クラスの終わり
