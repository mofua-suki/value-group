# Value Group

[日本語](https://github.com/mofua-suki/value-group/blob/main/README.ja.md) · [pub.dev](https://pub.dev/packages/value_group)

Use an ordered collection when your code handles zero, one, and multiple values differently. Dart pattern matching makes those cases explicit.

## Installation

Requires Dart SDK 3.14.0 or later, below 4.0.0.

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

Pass a `ValuedGroup<T>` when a function requires at least one value. Its `first` getter is always defined. Construct it from an iterable with `ValuedGroup.from`, which rejects empty input.

The constructors take a shallow snapshot of the iterable in one pass. The `values` list is unmodifiable. Group equality compares values in order and includes duplicate counts.

Since 0.1.5, groups of the same runtime type compare each element using its own Dart `==` and `hashCode`, as in a distinct merge. Earlier versions could compare nested collections recursively. For example, two single-value groups containing separately allocated Dart lists `[1]` are unequal. They compare equal when both hold the same list instance.

An ordinary merge appends the right group and preserves duplicates. Set `distinct: true` to keep the first occurrence of each value according to its equality and hash code. This works for both operands even when one is empty. The result is classified by its final size.

When combining groups created with different element types, create the left group with the common type first. For example, use `Group<num>.from(ints.values).merge(other: doubles)` to combine a `Group<int>` with a `Group<double>`.

## Development

Run these commands from the repository root.

```sh
dart pub get
dart analyze
dart test
```

Run the example with `dart run example/value_group_example.dart`.
