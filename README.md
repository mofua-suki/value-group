# Value Group

Use an ordered collection when your code handles zero, one, and multiple values differently. Dart pattern matching makes those cases explicit.

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

An ordinary merge appends the right group and preserves duplicates. Set `distinct: true` to keep the first occurrence of each value according to its equality and hash code. This works for both operands even when one is empty. The result is classified by its final size.
