// ======================= 敵クラス =======================
// Boid を捕食する敵の挙動を管理するクラス
class Enemy {
  PVector pos;   // 敵の現在位置ベクトル
  PVector vel;   // 敵の速度ベクトル
  float size = 20;      // 敵の表示サイズ（円の直径）
  float maxSpeed = 1.5; // 敵の最大移動速度

  // --- コンストラクタ（生成時に位置を指定） ---
  Enemy(float x, float y) {
    pos = new PVector(x, y);   // 引数で受け取った位置を初期位置に設定
    vel = PVector.random2D();  // ランダムな方向の速度ベクトルを初期値として与える
  }

  // --- 更新処理（ターゲット追跡 + 他の敵との距離調整 + ランダム移動） ---
  void update(PVector target, ArrayList<Enemy> enemies) {
    // プレイヤーのBoidや目標に向かって追跡するベクトル（強さ1.5倍）
    PVector pursuit = seek(target).mult(1.5);

    // 他の敵と距離を取りすぎないように分離ベクトル（強さ2倍）
    PVector separation = separate(enemies).mult(2.0);

    // ランダムな揺らぎ（自然な不規則さを加える）
    PVector randomMove = PVector.random2D().mult(0.5);

    // 加速度ベクトル（このフレームでの力の合計）
    PVector acceleration = new PVector();

    // 各行動ベクトルを合成
    acceleration.add(pursuit);
    acceleration.add(separation);
    acceleration.add(randomMove);

    // 加速度を速度に加える
    vel.add(acceleration);
    vel.limit(maxSpeed); // 最大速度を超えないように制御
    pos.add(vel);        // 位置に速度を反映（移動）

    // --- 画面端をループさせる処理（ラップアラウンド） ---
    if (pos.x < 0) pos.x = width;   // 左に出たら右から出現
    if (pos.x > width) pos.x = 0;   // 右に出たら左から出現
    if (pos.y < 0) pos.y = height;  // 上に出たら下から出現
    if (pos.y > height) pos.y = 0;  // 下に出たら上から出現
  }

  // --- 描画処理（赤い円として表示） ---
  void show() {
    fill(255, 50, 50);   // 赤色（やや暗め）
    noStroke();          // 輪郭線なし
    ellipse(pos.x, pos.y, size, size); // 現在位置に円を描画
  }

  // --- 目標へ向かうベクトルを計算する（追跡行動） ---
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, pos); // ターゲットへの方向ベクトル
    desired.setMag(maxSpeed);                   // 最大速度の大きさに調整
    PVector steer = PVector.sub(desired, vel);  // 現在の速度との差を操舵力とする
    return steer;                               // 操舵ベクトルを返す
  }

  // --- 他の敵と距離を保つ（分離行動） ---
  PVector separate(ArrayList<Enemy> enemies) {
    float desired = 40;      // 距離40未満に近づくと離れようとする
    PVector steer = new PVector(); // 合計ステアリングベクトル
    int count = 0;                 // 対象となった敵の数

    // 他の敵をチェック
    for (Enemy other : enemies) {
      float d = PVector.dist(pos, other.pos); // 敵との距離を計算
      if ((d > 0) && (d < desired)) {         // 自分以外かつ近すぎる場合
        PVector diff = PVector.sub(pos, other.pos); // その敵から遠ざかる方向
        diff.normalize();  // 向きだけの単位ベクトルに
        diff.div(d);       // 距離が近いほど強く離れるように調整
        steer.add(diff);   // 避ける力を合計
        count++;           // 判定対象をカウント
      }
    }

    // 平均化して自然な分離ベクトルにする
    if (count > 0) steer.div(count);

    return steer; // 最終的な分離ベクトルを返す
  }
}
