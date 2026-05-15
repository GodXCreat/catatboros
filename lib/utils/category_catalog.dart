import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryCatalog {
  static List<ExpenseCategory> defaults = const [
    ExpenseCategory(
      id: 'makanan',
      name: 'Makanan',
      icon: '🍔',
      keywords: ['makan', 'makanan', 'nasi', 'ayam', 'mie', 'mi', 'bakso', 'soto', 'warteg', 'restoran', 'lauk', 'sarapan', 'siang', 'malam', 'pecel', 'lalapan', 'burger', 'pizza'],
      colorValue: 0xFFE53935,
      isDefault: true,
      sortOrder: 1,
    ),
    ExpenseCategory(
      id: 'minuman',
      name: 'Minuman',
      icon: '☕',
      keywords: ['minum', 'minuman', 'kopi', 'teh', 'jus', 'boba', 'es', 'air', 'susu', 'latte', 'cappuccino', 'matcha', 'sirup'],
      colorValue: 0xFF8D6E63,
      isDefault: true,
      sortOrder: 2,
    ),
    ExpenseCategory(
      id: 'transport',
      name: 'Transport',
      icon: '🚗',
      keywords: ['grab', 'gojek', 'gocar', 'goride', 'bensin', 'parkir', 'tol', 'busway', 'bus', 'angkot', 'ojek', 'taxi', 'taksi', 'kereta', 'kapal', 'transport'],
      colorValue: 0xFF1E88E5,
      isDefault: true,
      sortOrder: 3,
    ),
    ExpenseCategory(
      id: 'tagihan',
      name: 'Tagihan',
      icon: '🏠',
      keywords: ['listrik', 'air', 'wifi', 'internet', 'gas', 'sewa', 'kos', 'kontrakan', 'pulsa', 'token', 'pln', 'pdam', 'tagihan'],
      colorValue: 0xFFF4511E,
      isDefault: true,
      sortOrder: 4,
    ),
    ExpenseCategory(
      id: 'belanja',
      name: 'Belanja',
      icon: '🛒',
      keywords: ['beli', 'belanja', 'supermarket', 'indomaret', 'alfamart', 'shopee', 'tokopedia', 'lazada', 'pasar', 'mall', 'baju', 'sepatu', 'sabun', 'skincare'],
      colorValue: 0xFF43A047,
      isDefault: true,
      sortOrder: 5,
    ),
    ExpenseCategory(
      id: 'hiburan',
      name: 'Hiburan',
      icon: '🎮',
      keywords: ['netflix', 'spotify', 'game', 'bioskop', 'youtube', 'konser', 'nonton', 'hiburan', 'ps', 'steam', 'disney', 'karaoke'],
      colorValue: 0xFF8E24AA,
      isDefault: true,
      sortOrder: 6,
    ),
    ExpenseCategory(
      id: 'kesehatan',
      name: 'Kesehatan',
      icon: '💊',
      keywords: ['obat', 'dokter', 'apotek', 'vitamin', 'rumah sakit', 'rs', 'klinik', 'masker', 'periksa', 'kesehatan'],
      colorValue: 0xFF00ACC1,
      isDefault: true,
      sortOrder: 7,
    ),
    ExpenseCategory(
      id: 'pendidikan',
      name: 'Pendidikan',
      icon: '📚',
      keywords: ['buku', 'kursus', 'sekolah', 'kuliah', 'kampus', 'print', 'fotokopi', 'belajar', 'pendidikan', 'kelas', 'seminar'],
      colorValue: 0xFF3949AB,
      isDefault: true,
      sortOrder: 8,
    ),
    ExpenseCategory(
      id: 'lainnya',
      name: 'Lainnya',
      icon: '📦',
      keywords: ['lain', 'lainnya', 'misc', 'umum'],
      colorValue: 0xFF757575,
      isDefault: true,
      sortOrder: 99,
    ),
  ];

  static ExpenseCategory fallback(List<ExpenseCategory> categories) {
    return categories.firstWhere((c) => c.id == 'lainnya', orElse: () => defaults.last);
  }
}
