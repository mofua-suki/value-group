import 'package:equatable/equatable.dart';

/// An ordered group containing zero, one, or multiple values.
///
/// Use a pattern switch to distinguish [EmptyGroup], [SingleGroup], and
/// [MultipleGroup].
sealed class Group<T extends Object> extends Equatable {
  const Group._();

  /// Takes an immutable snapshot of [values], retaining order and duplicates.
  factory Group.from(Iterable<T> values) {
    final snapshot = List<T>.unmodifiable(values);
    if (snapshot.isEmpty) return EmptyGroup<T>();
    return ValuedGroup<T>._fromSnapshot(snapshot);
  }

  /// Creates a group with no values.
  const factory Group.empty() = EmptyGroup<T>;

  /// Creates a group with one [value].
  const factory Group.single(T value) = SingleGroup<T>;

  /// The unmodifiable list of values in their original order.
  List<T> get values;

  /// Appends [other]'s values in order.
  ///
  /// With [distinct], keeps the first occurrence of each value according to
  /// the element's equality and hash code, even if either group is empty.
  /// The result type reflects the number of values retained.
  Group<T> merge({required Group<T> other, bool distinct = false});

  @override
  List<Object?> get props => values;
}

/// A group with no values.
final class EmptyGroup<T extends Object> extends Group<T> {
  const EmptyGroup() : super._();

  @override
  List<T> get values => List<T>.unmodifiable(const []);

  @override
  Group<T> merge({required Group<T> other, bool distinct = false}) =>
      distinct ? Group<T>.from(<T>{...other.values}) : other;
}

/// A group guaranteed to contain at least one value.
sealed class ValuedGroup<T extends Object> extends Group<T> {
  const ValuedGroup._() : super._();

  /// Takes an immutable snapshot of [values].
  ///
  /// Throws [ArgumentError] if [values] is empty.
  factory ValuedGroup.from(Iterable<T> values) {
    final snapshot = List<T>.unmodifiable(values);
    if (snapshot.isEmpty) {
      throw ArgumentError('A valued group must contain at least one value.');
    }
    return ValuedGroup<T>._fromSnapshot(snapshot);
  }

  factory ValuedGroup._fromSnapshot(List<T> snapshot) => snapshot.length == 1
      ? SingleGroup<T>(snapshot.single)
      : MultipleGroup<T>._(snapshot);

  /// The first value, which is always available in a valued group.
  T get first => values.first;

  @override
  ValuedGroup<T> merge({required Group<T> other, bool distinct = false}) {
    if (!distinct && other is EmptyGroup<T>) return this;
    final merged = values.followedBy(other.values);
    return ValuedGroup<T>._fromSnapshot(
      List<T>.unmodifiable(distinct ? <T>{...merged} : merged),
    );
  }
}

/// A group with exactly one [value].
final class SingleGroup<T extends Object> extends ValuedGroup<T> {
  const SingleGroup(this.value) : super._();

  final T value;

  @override
  T get first => value;

  @override
  List<T> get values => List<T>.unmodifiable([value]);
}

/// A group with at least two values.
final class MultipleGroup<T extends Object> extends ValuedGroup<T> {
  const MultipleGroup._(this.values) : super._();

  @override
  final List<T> values;
}
