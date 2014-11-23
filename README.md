# Nimmt

ニムトが遊べるRubyのお遊びスクリプトです。

## Requirements

- Ruby 2.0+

## Usage

```ruby
$ bin/nimmt
```

唐突にゲームが始まります。

```
==== Turn Start ====
# あなたが持っているカード
7 13 40 58 63 72 85 86 91 94
# 場に出されているカード
## 1列目
62
## 2列目
92
## 3列目
82
## 4列目
52

----
出すカードの数字を入力してください。
>
```

指示に従って、「場に出すカードの数字」や「カードを置く列番号」を入力していきましょう。
途中でやめたいときは`Ctrl+C`でスクリプト本体を止めてください。

# Rule

- プレイヤーが1人、コンピュータが3人の計4人構成で遊びます。
- どのカードも失点は1点です。 # TODO: あとで直す
