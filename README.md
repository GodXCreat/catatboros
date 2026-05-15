# CatatBoros

CatatBoros adalah aplikasi Android offline untuk mencatat pengeluaran harian dengan Smart Input. Contoh: ketik `mie ayam 15k`, aplikasi akan mendeteksi nama item, nominal Rp15.000, kategori, tanggal, dan jam.

## Fitur utama

- Smart Input: mendukung `5k`, `5rb`, `5000`, `5.000`, dan `5ribu`.
- Auto kategori: Makanan, Minuman, Transport, Tagihan, Belanja, Hiburan, Kesehatan, Pendidikan, dan Lainnya.
- Riwayat transaksi per hari, edit, hapus transaksi, hapus transaksi satu hari.
- Dashboard: total hari ini, minggu ini, bulan ini, perbandingan bulan lalu, dan kategori terboros.
- Laporan: pie chart kategori, grafik 7 hari, tren 30 hari, filter minggu/bulan/3 bulan/custom.
- Budget bulanan, progress bar, notifikasi 80%, dan alert saat terlampaui.
- Backup/export JSON dan CSV, import JSON, backup otomatis harian lokal.
- PIN lock, biometric lock, auto lock.
- Home screen widget sederhana untuk total pengeluaran hari ini.
- UI Material Design 3, Bahasa Indonesia, dark/light/auto mode.

## Struktur penting

```text
catatboros/
├── .github/workflows/build-apk.yml
├── android/app/build.gradle
├── android/app/src/main/AndroidManifest.xml
├── android/app/src/main/kotlin/com/catatboros/app/
├── lib/main.dart
├── lib/models/
├── lib/providers/
├── lib/screens/
├── lib/services/
├── lib/widgets/
├── lib/utils/
└── pubspec.yaml
```

## Cara clone repo

```bash
git clone https://github.com/USERNAME/catatboros.git
cd catatboros
```

Ganti `USERNAME` sesuai akun GitHub kamu.

## Cara menjalankan lokal

```bash
flutter pub get
flutter run
```

Kalau folder Android belum lengkap karena hasil upload manual, jalankan:

```bash
flutter create --platforms=android --project-name catatboros --org com.catatboros .
flutter pub get
flutter build apk --release
```

APK lokal ada di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Cara push ke GitHub

```bash
git init
git add .
git commit -m "Initial CatatBoros Flutter project"
git branch -M main
git remote add origin https://github.com/USERNAME/catatboros.git
git push -u origin main
```

Setiap push ke branch `main`, GitHub Actions otomatis build APK release dan mengunggahnya sebagai artifact.

## Cara download APK dari GitHub Actions

1. Buka repository GitHub.
2. Masuk tab **Actions**.
3. Klik workflow terbaru bernama **Build CatatBoros APK**.
4. Buka run yang statusnya sukses.
5. Scroll ke bagian **Artifacts**.
6. Download artifact **CatatBoros-APK**.
7. Ekstrak file ZIP artifact, lalu ambil file `.apk` di dalamnya.

## Cara membuat GitHub Release otomatis

Buat tag versi, lalu push tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions akan membuat Release baru dan melampirkan APK secara otomatis.

## Cara install APK di Android

1. Pindahkan file APK ke HP Android.
2. Buka APK lewat File Manager.
3. Jika muncul peringatan, aktifkan izin **Install unknown apps / Instal aplikasi tidak dikenal** untuk File Manager atau browser yang dipakai.
4. Tekan **Install**.
5. Minimal Android 8.0 atau API 26.

## Catatan teknis

- Package name: `com.catatboros.app`.
- Versi aplikasi: `1.0.0+1`.
- Min Android: API 26.
- Target SDK: API 34.
- Compile SDK: API 35 agar kompatibel dengan toolchain Android terbaru.
- Aplikasi tidak membutuhkan koneksi internet untuk menyimpan, membaca, dan mengelola data pengeluaran.
- File backup akan mencoba disimpan ke folder `Downloads`. Jika sistem Android membatasi akses, file disimpan ke folder dokumen aplikasi dan tetap bisa dibagikan lewat share sheet.
- Build release di project ini memakai debug signing agar APK bisa langsung dihasilkan oleh GitHub Actions. Untuk rilis Play Store, ganti konfigurasi signing release dengan keystore produksi.
