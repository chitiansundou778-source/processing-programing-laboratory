// =========================
// タイピング練習プログラム（英単語とローマ字）
// =========================

// キーのボタン情報を保存する配列、画面に表示するキーを全部まとめて管理するための箱
KeyButton[] keys; // ←ここに作ったキー全てを格納する配列。キーの表示や押下判定で使う

// 英語の単語のリスト、練習用の単語を並べている
String[] englishWords = {
  "apple", "banana", "cherry", "date", "elder", "fig", "grape", "honey", "ice", "juice",
  "kite", "lemon", "mango", "nectar", "olive", "peach", "quince", "raspberry", "straw", "tomato",
  "ant", "ball", "cat", "dog", "elephant", "fish", "goat", "hat", "ink", "jaguar",
  "kangaroo", "lion", "mouse", "nut", "octopus", "parrot", "queen", "rabbit", "snake", "tiger",
  "umbrella", "vulture", "whale", "xenon", "yak", "zebra", "airplane", "boat", "car", "drum",
  "engine", "fan", "guitar", "house", "island", "jacket", "key", "lamp", "moon", "notebook",
  "ocean", "piano", "queen", "rose", "sun", "train", "umbrella", "vase", "window", "xylophone",
  "yarn", "zoo", "apple", "banana", "cherry", "date", "elder", "fig", "grape", "honey", "ice",
  "juice", "kite", "lemon", "mango", "nectar", "olive", "peach", "quince", "raspberry", "straw",
  "tomato", "ant", "ball", "cat", "dog", "elephant", "fish", "goat", "hat", "ink", "jaguar",
  "kangaroo", "lion", "mouse", "nut", "octopus", "parrot", "queen", "rabbit", "snake", "tiger",
  "umbrella", "vulture", "whale", "xenon", "yak", "zebra"
};
 // ←英語単語100個。練習でランダムに表示される

// ローマ字の単語のリスト、日本語をローマ字にしたもの
String[] romajiWords = {
  "neko", "inu", "ringo", "mikan", "kagi", "kuruma", "densha", "hon", "gakkou", "hana",
  "arigatou", "sumimasen", "onegai", "wakarimashita", "itadakimasu", "gochisousama", "osaki", "itadakimasu", "sumimasen", "arigatou",
  "konnichiwa", "sayonara", "ohayou", "konbanwa", "oyasumi", "genki", "daijoubu", "douzo", "wakarimasen", "shitsurei",
  "hai", "iie", "doumo", "onegai", "sumimasen", "arigatou", "douzo", "wakarimashita", "itadakimasu", "gochisousama",
  "osaki", "itadakimasu", "sumimasen", "arigatou", "konnichiwa", "sayonara", "ohayou", "konbanwa", "oyasumi", "genki",
  "daijoubu", "douzo", "wakarimasen", "shitsurei", "hai", "iie", "doumo", "onegai", "sumimasen", "arigatou",
  "douzo", "wakarimashita", "itadakimasu", "gochisousama", "osaki", "itadakimasu", "sumimasen", "arigatou", "konnichiwa", "sayonara",
  "ohayou", "konbanwa", "oyasumi", "genki", "daijoubu", "douzo", "wakarimasen", "shitsurei", "hai", "iie",
  "doumo", "onegai", "sumimasen", "arigatou", "douzo", "wakarimashita", "itadakimasu", "gochisousama", "osaki", "itadakimasu"
};
 // ←ローマ字単語100個。日本語の読みをローマ字で練習する

// 今画面に表示している単語、typedTextと比較して正解判定に使う
String currentWord = ""; // ←現在表示中の単語。ユーザーがこれを打つ

// ユーザーが入力した文字を貯めておく箱
String typedText = ""; // ←入力された文字列を保持する。正解判定用

// 今選んでいる単語が単語リストの何番目かを示す
int wordIndex = 0; // ←ランダム単語選択時に更新される番号。配列のインデックスとして使う

// 正しく入力できた単語の数を数える
int correctCount = 0; // ←正解した単語の数をカウントして表示する

// 英語モードならtrue、ローマ字モードならfalse
boolean englishMode = true; // ←Shift+Mで切り替えるフラグ。trueなら英語単語、falseならローマ字

// フリーモードかどうか。EnterでON/OFF
boolean freeTypingMode = false; // ←Enterで自由入力モードに切り替えるかどうかの判定

// フリーモードで打った文字を保存する箱
String freeTypingText = ""; // ←自由入力用文字列を保持する。正解判定はなし

// -------------------------
// setup()はプログラム開始時に一回だけ呼ばれる関数
// -------------------------
void setup() { 
  size(1000, 800); // ←画面サイズ 横1000px 縦800px
  textAlign(CENTER, CENTER); // ←文字を描くとき中央基準にする
  textSize(20); // ←文字の大きさを20pxに設定

  keys = createGrabShellBothHands(); // ←左右の手のキー配置を作成して配列に保存

  pickRandomWord(); // ←最初の単語をランダムで選択して表示
}

// -------------------------
// draw()は画面を更新するたびに何度も繰り返し実行される
// -------------------------
void draw() {
  background(0); // ←背景を黒で塗りつぶす。毎フレームリセット

  // keys配列に入っている全てのキーを画面に描画
  for (KeyButton k : keys) { 
    k.display(); // ←KeyButtonクラスのdisplay()メソッドを呼んでキーを描画
  }

  fill(255); // ←文字色を白に設定
  textSize(22); // ←文字サイズ22px
  text(englishMode ? "English Mode" : "Romaji Mode", width/2, 20); // ←モード表示（画面上中央）
  text("Shift + M: Toggle Romaji/English", width/2, 50); // ←切替操作の説明を表示
  text("Enter: Free Typing Mode", width/2, 80); // ←フリーモード操作説明を表示

  if(freeTypingMode){ // ←フリーモードONのときの処理
    fill(0, 255, 0); // ←文字を緑色に
    textSize(28); // ←文字を少し大きめに
    text(freeTypingText, width/2, 120); // ←画面上中央に入力文字を表示
  } else { // ←通常モードの処理
    fill(255); // ←単語を白色で描画
    textSize(28); // ←単語の文字サイズ
    text("Word: " + currentWord, width/2, 120); // ←現在打つ単語を表示

    fill(0, 255, 0); // ←入力文字は緑で描画
    textSize(32); // ←入力文字を大きめに表示
    text(typedText, width/2, 160); // ←入力文字を画面に表示

    fill(255, 255, 0); // ←正解数を黄色で描画
    textSize(24); // ←文字サイズ24px
    textAlign(LEFT, TOP); // ←左上基準で表示
    text("Correct Words: " + correctCount, 20, 20); // ←正解数表示
    textAlign(CENTER, CENTER); // ←中央揃えに戻す
  }

  highlightNextKey(); // ←次に押すべきキーを黄色でハイライトする関数を呼ぶ
}

// -------------------------
// keyPressed()はキーを押したとき呼ばれる
// -------------------------
void keyPressed() {
  String kStr = str(key).toLowerCase(); // ←押されたキーを文字列に変換し小文字化

  if (key == 'M' && keyEvent.isShiftDown()) {  // ←Shift+Mでモード切替
    englishMode = !englishMode; // ←英語とローマ字モードを反転
    pickRandomWord(); // ←新しい単語を選ぶ
    typedText = ""; // ←入力文字リセット
    return; // ←処理終了
  }

  if(keyCode == ENTER){ // ←Enterでフリーモード切替
    freeTypingMode = !freeTypingMode; // ←ON/OFFを反転
    if(!freeTypingMode){ // ←フリーモード終了時の処理
      freeTypingText = ""; // ←文字列リセット
      pickRandomWord(); // ←新しい単語選択
      typedText = ""; // ←入力リセット
    }
    return; // ←処理終了
  }

  if(freeTypingMode){ // ←フリーモード入力処理
    if(keyCode == BACKSPACE && freeTypingText.length() > 0){ // ←バックスペースで最後の文字を削除
      freeTypingText = freeTypingText.substring(0, freeTypingText.length()-1); // ←文字削除
    } else if(key != CODED){ // ←特殊キーでなければ
      freeTypingText += key; // ←入力文字を追加
    }
    for (KeyButton k : keys) if (k.label.equalsIgnoreCase(kStr)) k.active = true; // ←押されたキーを緑色で表示
    return; // ←フリーモード処理終了
  }

  if (keyCode == BACKSPACE && typedText.length() > 0){ // ←通常モード バックスペース処理
    typedText = typedText.substring(0, typedText.length()-1); // ←最後の文字を削除
  }

  if (typedText.length() < currentWord.length()){ // ←まだ単語が終わっていないときの処理
    char nextChar = currentWord.charAt(typedText.length()); // ←次に押す文字を取得
    if (str(key).equalsIgnoreCase(str(nextChar))){ // ←正しい文字か判定
      typedText += key; // ←typedTextに追加
      for (KeyButton k : keys) if (k.label.equalsIgnoreCase(str(key))){ 
        k.active = true; // ←キーを緑色に
        k.mistyped = false; // ←間違いフラグOFF
      }
      if(typedText.length() == currentWord.length()){ // ←単語完成時
        correctCount++; // ←正解数を増やす
        pickRandomWord(); // ←次の単語に切替
        typedText = ""; // ←入力リセット
      }
    } else { // ←間違った場合の処理
      for (KeyButton k : keys) if (k.label.equalsIgnoreCase(str(key))) k.mistyped = true; // ←キーを赤色で表示
    }
  }

  for (KeyButton k : keys){ // ←押されたキーの視覚反応処理
    if (k.label.equalsIgnoreCase(kStr)) k.active = true; // ←普通の文字キーを緑に
    if (key == ' ' && k.label.equals("SPACE")) k.active = true; // ←スペースキーを緑に
    if (keyCode == CONTROL && k.label.equals("CTRL")) k.active = true; // ←Ctrlキーを緑に
  }
}

// -------------------------
// keyReleased()はキーを離したとき呼ばれる
// -------------------------
void keyReleased(){
  for (KeyButton k : keys){ // ←全キーに対して処理
    k.active = false; // ←緑色を消す
    k.highlight = false; // ←黄色ハイライトを消す
    k.mistyped = false; // ←赤色を消す
  }
}

// -------------------------
// pickRandomWord()は単語をランダムで選ぶ
// -------------------------
void pickRandomWord(){
  wordIndex = int(random(0, min(englishWords.length, romajiWords.length))); // ←単語番号をランダムに決定
  currentWord = englishMode ? englishWords[wordIndex] : romajiWords[wordIndex]; // ←モードに応じた単語を選択
  typedText = ""; // ←入力文字リセット
}

// -------------------------
// highlightNextKey()は次に押すべきキーを黄色にする
// -------------------------
void highlightNextKey(){
  if(freeTypingMode) return; // ←フリーモードでは何もしない
  if(typedText.length() >= currentWord.length()) return; // ←単語が終了したら何もしない
  char nextChar = currentWord.charAt(typedText.length()); // ←次に押す文字取得
  for(KeyButton k : keys){ // ←全キーをチェック
    if(k.label.equalsIgnoreCase(str(nextChar))) k.highlight = true; // ←次の文字を黄色でハイライト
    else k.highlight = false; // ←それ以外はハイライトを消す
    if(nextChar == ' ' && k.label.equals("SPACE")) k.highlight = true; // ←空白文字の場合はSPACEキーを黄色に
  }
}

// -------------------------
// createGrabShellBothHands()は左右のキー配置を作る
// -------------------------
KeyButton[] createGrabShellBothHands(){
  ArrayList<KeyButton> list = new ArrayList<KeyButton>(); // ←一時保存用リスト作成
  int keyW = 60, keyH = 60; // ←キー幅60px、高さ60px
  int spacing = 5; // ←キー間の隙間
  float offset = keyW / 4.0; // ←列ずらし量
  float topExtra = keyW / 2.0; // ←上段の余分なオフセット
  float centerX = width / 2; // ←画面中央
  float baseY = 200; // ←上寄せ開始位置

  String[] leftRows = {"bgt","vfr","cde","xsw","zaq"}; // ←左手の行
  for(int r=0; r<leftRows.length; r++){ // ←行ごとにループ
    String row = leftRows[r]; // ←行文字列取得
    for(int c=0; c<row.length(); c++){ // ←列ごとにループ
      float extra = (r==0)? -topExtra : 0; // ←上段左寄せ補正
      float rowOffset = (r==2)? offset : -r*offset; // ←段ごとのオフセット補正
      float x = centerX - 200 + c*(keyW+spacing) + rowOffset + extra; // ←X座標計算
      float y = baseY + r*(keyH+spacing); // ←Y座標計算
      list.add(new KeyButton(x,y,keyW,keyH,str(row.charAt(c)))); // ←KeyButton作成してリストに追加
    }
  }

  String[] rightRows = {"yhn","ujm","ik,","ol.","p;/"}; // ←右手行
  for(int r=0; r<rightRows.length; r++){ // ←行ループ
    String row = rightRows[r]; // ←行文字列
    for(int c=0; c<row.length(); c++){ // ←列ループ
      float extra = (r==0)? topExtra : 0; // ←上段右寄せ補正
      float rowOffset = (r==2)? -offset : r*offset; // ←段補正
      float x = centerX + 200 + c*(keyW+spacing) + rowOffset + extra; // ←X座標計算
      float y = baseY + r*(keyH+spacing); // ←Y座標計算
      list.add(new KeyButton(x,y,keyW,keyH,str(row.charAt(c)))); // ←KeyButton作成して追加
    }
  }

  float thumbY = baseY + 5*(keyH+spacing)+40; // ←親指用Y座標
  list.add(new KeyButton(centerX - keyW, thumbY, keyW*2,keyH,"SPACE")); // ←スペースキー追加
  list.add(new KeyButton(centerX - keyW, thumbY+keyH+spacing,keyW*2,keyH,"BACK")); // ←バックスペース追加
  list.add(new KeyButton(centerX + keyW, thumbY+keyH+spacing,keyW*2,keyH,"ENTER")); // ←Enterキー追加
  list.add(new KeyButton(centerX - keyW*3, thumbY+keyH+spacing,keyW*2,keyH,"CTRL")); // ←Ctrlキー追加

  return list.toArray(new KeyButton[list.size()]); // ←配列に変換して返す
}

// -------------------------
// KeyButtonクラス
// -------------------------
class KeyButton{
  float x,y,w,h; // ←キーの位置と大きさ
  String label; // ←キーに表示する文字
  boolean active=false; // ←押されたときtrue
  boolean highlight=false; // ←次に押すべきキーを黄色にする
  boolean mistyped=false; // ←間違えたときtrueにする

  KeyButton(float x,float y,float w,float h,String label){ this.x=x; this.y=y; this.w=w; this.h=h; this.label=label; } // ←コンストラクタ

  void display(){ // ←キーを画面に描画する関数
    stroke(255); // ←枠線白色
    if(mistyped) fill(255,0,0); // ←間違えたら赤色
    else if(active) fill(0,255,0); // ←押したら緑色
    else if(highlight) fill(255,255,0); // ←次に押すべきなら黄色
    else noFill(); // ←それ以外は透明
    rect(x,y,w,h,8); // ←四角形描画 丸角8px
    fill(255); // ←文字色白
    text(label,x+w/2,y+h/2); // ←ラベルを中央に表示
  }
}
