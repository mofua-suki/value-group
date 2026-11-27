# Value Group

[English](https://github.com/mofua-suki/value-group/blob/main/README.md) · [pub.dev](https://pub.dev/packages/value_group)

値が0件、1件、複数件のときに処理を分けたい場合に使う、順序付きのコレクションです。Dart のパターンマッチで各ケースを明示できます。

## インストール

対応する Dart SDK は 3.14.0 以上 4.0.0 未満です。

```sh
dart pub add value_group
```

```dart
import 'package:value_group/value_group.dart';

final selected = Group<String>.from(['A', 'A', 'B']);
const empty = Group<String>.empty();
final group = empty.merge(other: selected, distinct: true);

final label = switch (group) {
  EmptyGroup<String>() => 'None',
  SingleGroup<String>(:final value) => value,
  MultipleGroup<String>(:final values) => values.join(', '),
}; // A, B
```

1件以上の値を必要とする関数には `ValuedGroup<T>` を渡せます。`first` で常に先頭の値を取得できます。`ValuedGroup.from` は反復可能な入力からグループを作り、空の入力には `ArgumentError` を投げます。

コンストラクタは入力を1回走査して浅いスナップショットを作ります。`values` のリストは変更できません。グループの等価判定では値の順序と重複の個数も比較します。

0.1.5 以降は、同じ実行時型のグループ同士で、`distinct: true` の結合と同じく各要素の Dart の `==` と `hashCode` を使います。以前は入れ子のコレクションを再帰的に比較する場合がありました。たとえば、別々に作った通常のリスト `[1]` を1件ずつ持つグループは等しくありません。同じリストを共有すれば等しくなります。

通常の `merge` は右側のグループを末尾に追加し、重複を保持します。`distinct: true` を指定すると、両グループを左から順に見て、各値の等価性とハッシュ値に基づき最初の出現だけを残します。片方が空でも同じ規則が適用されます。結果の型は残った値の件数で決まります。

要素型が異なるグループを結合する場合は、左側のグループを先に共通の要素型で作ります。たとえば `Group<int>` と `Group<double>` を結合するには、`Group<num>.from(ints.values).merge(other: doubles)` を使います。

## 開発

このリポジトリのルートで次のコマンドを実行します。

```sh
dart pub get
dart analyze
dart test
```

使用例は `dart run example/value_group_example.dart` で実行できます。
