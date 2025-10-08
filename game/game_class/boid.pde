// ========================= Boid クラス（群れを構成する個体） =========================
class Boid {                                 // ← Boid クラスの開始（1 個体あたりの状態と振る舞いを定義）
  PVector pos;                               // ← 位置ベクトル (x, y) を保持するフィールド
  PVector vel;                               // ← 速度ベクトル（毎フレームの位置変化量）を保持
  PVector acc;                               // ← 加速度ベクトル（そのフレームで蓄積する力の合計）を保持
  float maxForce = 0.2;                      // ← 舵（steering）力の上限：加速度の大きさを制限して滑らかにする係数
  float maxSpeed = 2;                        // ← 速度の上限：Boid が出せる最大速度（ピクセル／フレームに相当）

  // コンストラクタ：Boid を作るときに初期位置を受け取る
  Boid(float x, float y) {
    pos = new PVector(x, y);                 // ← pos を指定座標で初期化（位置をセット）
    vel = PVector.random2D();                // ← vel をランダム方向の単位ベクトルで初期化（ランダムな向き・大きさ 1）
    acc = new PVector();                     // ← acc をゼロベクトルで初期化（まだ力は蓄積されていない）
  }                                          // ← コンストラクタ終わり

  // update：毎フレーム呼ばれ、周囲の仲間・敵・目標に基づいて加速度を計算し位置を更新する
  // 引数 boids = 仲間リスト、enemies = 敵リスト、target = リーダー位置（ここではマウス）
  void update(ArrayList<Boid> boids, ArrayList<Enemy> enemies, PVector target) {
    // --- 各行動ルールで生じるベクトルを計算し、それぞれに重みを掛ける ---
    PVector separation = separate(boids).mult(1.5); // ← 近接回避ベクトル（分離）を取得し、重み 1.5 を掛ける
                                                     //     ※ mult() は戻り値の PVector を破壊的に乗算して返す（元のベクトルを変更）
    PVector alignment = align(boids).mult(1.0);     // ← 周囲と向きを揃える整列ベクトル（重み 1.0）
    PVector cohesion = cohesion(boids).mult(1.0);   // ← 群れの中心へ寄せる結合ベクトル（重み 1.0）
                                                     //     ※ ローカル変数名がメソッド名と同じ "cohesion" だが、
                                                     //       ここでは右辺のメソッド呼び出しが先に評価されてから代入されるので問題ない
    PVector fleeEnemies = flee(enemies).mult(2.0);  // ← 敵から逃げるベクトル（重み 2.0 — 優先度高め）
    PVector seekTarget = seek(target).mult(1.0);    // ← 目標（リーダー）へ進むベクトル（重み 1.0）

    // --- 加速度（合力）として acc に順に足し合わせる（各行動の合成） ---
    acc.add(separation);    // ← 分離力を加算（近接回避）
    acc.add(alignment);     // ← 整列力を加算（向き合わせ）
    acc.add(cohesion);      // ← 結合力を加算（群れの中心へ）
    acc.add(fleeEnemies);   // ← 敵回避力を加算（衝突回避・生存優先）
    acc.add(seekTarget);    // ← 目標追従力を加算（マウスやリーダーへの追従）

    // --- 運動方程式の離散積分（オイラー法に近い簡易積分） ---
    vel.add(acc);          // ← 速度に加速度を足す： v ← v + a
    vel.limit(maxSpeed);   // ← 速度の大きさを maxSpeed 以下に制限（v の大きさを clamp）
    pos.add(vel);          // ← 位置に速度を足す： p ← p + v（移動の実行）
    acc.mult(0);           // ← 加速度を 0 にリセット（次フレームにリセットして力を再蓄積する）
                           //     ※ acc = new PVector() としないのはオブジェクト生成を避けるための最適化

    // --- 画面端の処理（ワープではなく画面外に行ったら反対側へ出すラップ処理） ---
    if (pos.x < 0) pos.x = width;    // ← x が左端より小さければ右端（width）へワープ
    if (pos.x > width) pos.x = 0;    // ← x が右端より大きければ左端（0）へワープ
    if (pos.y < 0) pos.y = height;   // ← y が上端より小さければ下端（height）へワープ
    if (pos.y > height) pos.y = 0;   // ← y が下端より大きければ上端（0）へワープ
  } // ← update の終わり

  // show：Boid の描画（ここでは点で表現）
  void show() {
    stroke(0, 200, 255);   // ← 描画する点の色（R=0,G=200,B=255）を設定
    strokeWeight(4);       // ← 点の太さ（ピクセル）を設定
    point(pos.x, pos.y);   // ← pos の位置に点を描く（Boid のビジュアル表現）
  } // ← show 終了

  // ========================= 分離行動（近接回避） =========================
  // 周囲の近すぎる仲間を避けるためのベクトルを返す
  PVector separate(ArrayList<Boid> boids) {
    float desired = 25;               // ← 回避を開始する閾値（距離ピクセル）。これより近ければ回避を強くする
    PVector steer = new PVector();    // ← 回避力（steering）を蓄えるベクトルを初期化（0,0）
    int count = 0;                    // ← 近接している仲間のカウント

    for (Boid other : boids) {        // ← 全仲間をチェック（自身も含まれている可能性があるので後で除外）
      float d = PVector.dist(pos, other.pos); // ← this.pos と other.pos のユークリッド距離を計算
      if ((d > 0) && (d < desired)) { // ← 自分自身でない（d>0）かつ近すぎる（d<desired）の場合
        PVector diff = PVector.sub(pos, other.pos); // ← 相手から遠ざかる方向ベクトル = this.pos - other.pos
        diff.normalize();                 // ← 方向ベクトルを単位ベクトルにする（大きさ 1）
        diff.div(d);                      // ← 距離で割ることで「近いほど強く」する（1/d の重み）
        steer.add(diff);                  // ← 回避ベクトルを蓄積
        count++;                          // ← 近接仲間を数える
      } // ← if 終わり
    } // ← for 終わり

    if (count > 0) {                      // ← 近接仲間がいた場合は平均化して補正する
      steer.div((float)count);           // ← 蓄積したベクトルを近接仲間数で割り、平均回避ベクトルにする
    }
    if (steer.mag() > 0) {                // ← 回避ベクトルがゼロではない場合（有効な力がある時）
      steer.setMag(maxSpeed);             // ← 望ましい速度（向き）を maxSpeed に揃える（目標速度 desired）
      steer.sub(vel);                     // ← steering = desiredVelocity - currentVelocity（差分が加速度）
      steer.limit(maxForce);              // ← 加速度を maxForce で制限（急激な変化を抑える）
    }
    return steer;                         // ← 最終的な回避（steering）ベクトルを返す
  } // ← separate 終了

  // ========================= 整列行動（align） =========================
  // 近傍の仲間の平均速度に合わせるためのステアリングを返す
  PVector align(ArrayList<Boid> boids) {
    float neighborDist = 50;             // ← 整列の影響範囲（距離ピクセル）
    PVector sum = new PVector();         // ← 近傍の速度合計を保持するベクトル
    int count = 0;                       // ← 近傍個体数のカウント

    for (Boid other : boids) {           // ← すべての仲間についてチェック
      float d = PVector.dist(pos, other.pos); // ← this と other の距離
      if ((d > 0) && (d < neighborDist)) { // ← 自分以外で距離が neighborDist 未満のものだけを考慮
        sum.add(other.vel);              // ← その仲間の速度を合計に加える
        count++;                         // ← カウンタ増加
      }
    }

    if (count > 0) {                     // ← 近傍が存在する場合
      sum.div((float)count);             // ← 合計を個体数で割って平均速度を計算
      sum.setMag(maxSpeed);              // ← その平均速度を望ましい速度（大きさ）に揃える
      PVector steer = PVector.sub(sum, vel); // ← steering = desired(平均) - currentVelocity
      steer.limit(maxForce);             // ← 加速度の上限で制限
      return steer;                      // ← 整列用ステアリングを返す
    }
    return new PVector();                 // ← 近傍が無ければゼロベクトルを返す
  } // ← align 終了

  // ========================= 結合行動（cohesion） =========================
  // 近傍の仲間の位置の平均（群れの重心）に向かうベクトルを返す
  PVector cohesion(ArrayList<Boid> boids) {
    float neighborDist = 50;             // ← 結合の影響範囲（距離）
    PVector sum = new PVector();         // ← 近傍の位置合計を保持するベクトル
    int count = 0;                       // ← 近傍の個体数を数えるカウンタ

    for (Boid other : boids) {           // ← 全仲間を走査
      float d = PVector.dist(pos, other.pos); // ← 距離を計算
      if ((d > 0) && (d < neighborDist)) { // ← 自分以外で近ければ位置を合計
        sum.add(other.pos);              // ← 近い仲間の位置を足す
        count++;                         // ← カウントを増やす
      }
    }

    if (count > 0) {                     // ← 近傍が存在すれば
      sum.div(count);                    // ← 位置の平均（群れの中心）を求める
      return seek(sum);                  // ← その中心へ向かう「seek」ベクトルを返す（滑らかな追従）
    }
    return new PVector();                 // ← 近傍が無ければゼロベクトルを返す
  } // ← cohesion 終了

  // ========================= 敵から逃げる（flee） =========================
  // 敵が近い場合、その方向とは逆向きに離脱するベクトルを返す
  PVector flee(ArrayList<Enemy> enemies) {
    float desired = 50;                  // ← 敵に対して回避を始める閾値（ピクセル）
    PVector steer = new PVector();       // ← 回避ベクトルを蓄積する変数（初期 0,0）

    for (Enemy e : enemies) {            // ← 全敵をチェック
      float d = PVector.dist(pos, e.pos); // ← Boid と敵の距離
      if (d < desired) {                 // ← 閾値より近ければ回避対象
        PVector diff = PVector.sub(pos, e.pos); // ← 敵から見て自分がどこにいるか（自分へ向かうベクトル）
        diff.normalize();                // ← 方向だけにする
        diff.div(d);                     // ← 距離で割ることで近い敵ほど強く働くようにする（1/d）
        steer.add(diff);                 // ← 回避ベクトルを蓄積
      }
    }
    return steer;                         // ← 蓄積した回避ベクトルを返す（追加の制限は呼び出し側で行われる）
  } // ← flee 終了

  // ========================= 目標を追う（seek） =========================
  // target（目的地）へ向かうためのステアリングベクトルを返す（典型的な steering 行動）
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, pos); // ← 目的地方向ベクトル = target - 現在位置
    desired.setMag(maxSpeed);               // ← 望ましい速度の大きさを maxSpeed に揃える（速度スケールを統一）
    PVector steer = PVector.sub(desired, vel); // ← steering = desiredVelocity - currentVelocity（差分が加速度）
    steer.limit(maxForce);                  // ← 加速度を maxForce で制限（急な向き変化を抑える）
    return steer;                           // ← 求めたステアリングを返す
  } // ← seek 終了
} // ← Boid クラスの終わり
