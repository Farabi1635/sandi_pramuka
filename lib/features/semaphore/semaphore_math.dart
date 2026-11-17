import 'dart:math';
import 'dart:ui';

/// Sudut lengan dalam derajat untuk nomor posisi 1-8, diukur dari arah bawah
/// dan bertambah ke arah kiri: 1 bawah (0), 2 kiri bawah (45), 3 kiri (90),
/// 4 kiri atas (135), 5 atas (180), 6 kanan atas (225), 7 kanan (270),
/// 8 kanan bawah (315).
double semaphoreAngle(int position) => ((position - 1) * 45).toDouble();

/// Vektor arah lengan (x ke kanan, y ke bawah) untuk sudut [degrees].
Offset armDirection(double degrees) {
  final r = degrees * pi / 180;
  return Offset(-sin(r), cos(r));
}

/// Selisih sudut terpendek dari [from] ke [to], dalam rentang (-180, 180].
double shortestDelta(double from, double to) {
  var d = (to - from) % 360;
  if (d > 180) d -= 360;
  return d;
}

/// Sudut di antara [from] dan [to] lewat jalur terpendek, [t] dari 0 sampai 1.
double lerpAngle(double from, double to, double t) =>
    from + shortestDelta(from, to) * t;

/// Posisi kedua lengan (sudut dalam derajat).
class ArmAngles {
  const ArmAngles(this.a, this.b);
  final double a;
  final double b;
}

/// Kedua lengan lurus ke bawah (posisi istirahat).
const ArmAngles restPose = ArmAngles(0, 0);

/// Menentukan lengan mana menuju posisi mana supaya gerakannya sependek
/// mungkin dari pose [current] ke pasangan posisi [p] dan [q].
ArmAngles assignArms(ArmAngles current, int p, int q) {
  final t1 = semaphoreAngle(p);
  final t2 = semaphoreAngle(q);
  final direct = shortestDelta(current.a, t1).abs() +
      shortestDelta(current.b, t2).abs();
  final swapped = shortestDelta(current.a, t2).abs() +
      shortestDelta(current.b, t1).abs();
  return swapped < direct ? ArmAngles(t2, t1) : ArmAngles(t1, t2);
}

/// Nama arah tiap nomor posisi.
const List<String> semaphorePositionNames = [
  'bawah',
  'kiri bawah',
  'kiri',
  'kiri atas',
  'atas',
  'kanan atas',
  'kanan',
  'kanan bawah',
];
