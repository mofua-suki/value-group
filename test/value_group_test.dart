import 'package:test/test.dart';
import 'package:value_group/value_group.dart';

void main() {
  test('construction selects the variant by the number of values', () {
    expect(Group<int>.from([]), isA<EmptyGroup<int>>());
    expect(Group<int>.from([1]), isA<SingleGroup<int>>());
    expect(Group<int>.from([1, 1]), isA<MultipleGroup<int>>());
  });

  test('Group.from snapshots the source and keeps its equality stable', () {
    final source = [1, 2];
    final group = Group<int>.from(source);
    final groups = {group};

    source[0] = 3;
    source.clear();

    expect(group.values, [1, 2]);
    expect(groups.contains(Group<int>.from([1, 2])), isTrue);
  });

  test('ValuedGroup.from snapshots the source and rejects an empty input', () {
    final source = [1, 2];
    final group = ValuedGroup<int>.from(source);

    source.clear();

    expect(group.first, 1);
    expect(group.values, [1, 2]);
    expect(() => ValuedGroup<int>.from(source), throwsArgumentError);
  });

  test('constructors traverse their input once', () {
    final source = _CountingIterable([1, 2]);
    final group = Group<int>.from(source);
    final valuedSource = _CountingIterable([1, 2]);
    final valuedGroup = ValuedGroup<int>.from(valuedSource);

    expect(group.values, [1, 2]);
    expect(valuedGroup.values, [1, 2]);
    expect(source.traversals, 1);
    expect(valuedSource.traversals, 1);
  });

  test('all variants expose an unmodifiable view of their values', () {
    final groups = [
      const Group<int>.empty(),
      const Group<int>.single(1),
      Group<int>.from([1, 2]),
    ];

    for (final group in groups) {
      expect(() => group.values.add(3), throwsUnsupportedError);
      if (group.values.isNotEmpty) {
        expect(() => group.values[0] = 3, throwsUnsupportedError);
      }
    }
  });

  test('value equality includes order and multiplicity', () {
    final group = Group<int>.from([1, 2, 2]);
    final equalGroup = Group<int>.from([1, 2, 2]);

    expect(group, equalGroup);
    expect(group.hashCode, equalGroup.hashCode);
    expect(group, isNot(Group<int>.from([2, 1, 2])));
    expect(group, isNot(Group<int>.from([1, 2])));
  });

  test('ordinary merge keeps order and duplicates', () {
    const empty = Group<int>.empty();
    final left = Group<int>.from([2, 1, 2]);
    final right = Group<int>.from([1, 3, 1]);

    expect(left.merge(other: right).values, [2, 1, 2, 1, 3, 1]);
    expect(empty.merge(other: left), left);
    expect(left.merge(other: empty), left);
  });

  test('distinct merge normalizes empty and duplicate-only inputs', () {
    const empty = Group<int>.empty();
    const single = Group<int>.single(1);
    final duplicates = ValuedGroup<int>.from([1, 1]);

    expect(empty.merge(other: empty, distinct: true), isA<EmptyGroup<int>>());
    expect(empty.merge(other: duplicates, distinct: true), single);
    expect(duplicates.merge(other: empty, distinct: true), single);
    expect(single.merge(other: duplicates, distinct: true), single);
    expect(duplicates.merge(other: single, distinct: true), single);
    final ValuedGroup<int> merged = duplicates.merge(
      other: duplicates,
      distinct: true,
    );
    expect(merged, single);
  });

  test('distinct merge keeps first occurrences in left-to-right order', () {
    const empty = Group<int>.empty();
    final left = Group<int>.from([2, 1, 2]);
    final right = Group<int>.from([3, 1, 4, 3]);

    expect(left.merge(other: right, distinct: true).values, [2, 1, 3, 4]);
    expect(empty.merge(other: left, distinct: true).values, [2, 1]);
    expect(left.merge(other: empty, distinct: true).values, [2, 1]);
  });
}

final class _CountingIterable<T> extends Iterable<T> {
  _CountingIterable(this.source);

  final Iterable<T> source;
  int traversals = 0;

  @override
  Iterator<T> get iterator {
    traversals++;
    return source.iterator;
  }
}
