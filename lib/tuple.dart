class Tuple<T, U> {
  T a;
  U b;
  Tuple(this.a, this.b);
  @override
  String toString() => "($a, $b)";
}
