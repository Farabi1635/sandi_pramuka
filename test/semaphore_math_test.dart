import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/features/semaphore/semaphore_math.dart';
import 'package:sandi_pramuka/services/ciphers/semaphore_cipher.dart';
import 'package:sandi_pramuka/shared/widgets/semaphore_cell.dart';

void main() {
  group('Sudut lengan', () {
    test('delapan posisi berjarak 45 derajat dari bawah ke kiri', () {
      expect(semaphoreAngle(1), 0);
      expect(semaphoreAngle(2), 45);
      expect(semaphoreAngle(3), 90);
      expect(semaphoreAngle(5), 180);
      expect(semaphoreAngle(7), 270);
      expect(semaphoreAngle(8), 315);
    });

    test('arah sama dengan gambar di tabel simbol', () {
      for (var p = 1; p <= 8; p++) {
        final a = armDirection(semaphoreAngle(p));
        final b = semaphoreDirection(p);
        expect((a.dx - b.dx).abs() < 1e-9, isTrue, reason: 'dx posisi $p');
        expect((a.dy - b.dy).abs() < 1e-9, isTrue, reason: 'dy posisi $p');
      }
    });

    test('arah dasar', () {
      expect(armDirection(0).dy, closeTo(1, 1e-9)); // bawah
      expect(armDirection(90).dx, closeTo(-1, 1e-9)); // kiri
      expect(armDirection(180).dy, closeTo(-1, 1e-9)); // atas
      expect(armDirection(270).dx, closeTo(1, 1e-9)); // kanan
    });
  });

  group('Gerakan lengan', () {
    test('selisih terpendek melewati batas 0/360', () {
      expect(shortestDelta(315, 45), 90);
      expect(shortestDelta(45, 315), -90);
      expect(shortestDelta(0, 90), 90);
      expect(shortestDelta(90, 0), -90);
      expect(shortestDelta(10, 10), 0);
    });

    test('interpolasi menuju sudut tujuan', () {
      expect(lerpAngle(0, 90, 0), 0);
      expect(lerpAngle(0, 90, 1), 90);
      expect(lerpAngle(0, 90, 0.5), 45);
      expect(lerpAngle(315, 45, 0.5), 360); // lewat arah bawah, bukan atas
    });

    test('lengan dipasangkan dengan gerakan terpendek', () {
      // Dari kiri-kanan (3,7) ke (4,8): lengan kiri naik, kanan turun.
      final a = assignArms(const ArmAngles(90, 270), 4, 8);
      expect(a.a, semaphoreAngle(4));
      expect(a.b, semaphoreAngle(8));
      // Urutan pasangan terbalik tidak mengubah hasil.
      final b = assignArms(const ArmAngles(90, 270), 8, 4);
      expect(b.a, semaphoreAngle(4));
      expect(b.b, semaphoreAngle(8));
    });

    test('dari posisi istirahat ke semua huruf berakhir di posisi benar', () {
      for (final code in semaphoreCodes.values) {
        final parts = code.split('.').map(int.parse).toList();
        final pose = assignArms(restPose, parts[0], parts[1]);
        final got = {pose.a, pose.b};
        final want = {semaphoreAngle(parts[0]), semaphoreAngle(parts[1])};
        expect(got, want, reason: code);
      }
    });
  });

  test('nama arah lengkap untuk 8 posisi', () {
    expect(semaphorePositionNames.length, 8);
    expect(semaphorePositionNames.first, 'bawah');
    expect(semaphorePositionNames[4], 'atas');
  });
}
