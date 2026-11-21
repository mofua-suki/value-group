import 'package:value_group/value_group.dart';

void main() {
  final selected = Group<String>.from(['A', 'A', 'B']);
  const empty = Group<String>.empty();
  final group = empty.merge(other: selected, distinct: true);

  final label = switch (group) {
    EmptyGroup<String>() => 'None',
    SingleGroup<String>(:final value) => value,
    MultipleGroup<String>(:final values) => values.join(', '),
  };
  print(label); // A, B
}
