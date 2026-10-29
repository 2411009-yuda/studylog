import 'package:flutter/foundation.dart';

import '../data/catatan_repository.dart';
import '../models/catatan.dart';

class CatatanViewModel extends ChangeNotifier {
  final CatatanRepository _repository;

  CatatanViewModel({
    CatatanRepository? repository,
  }) : _repository = repository ?? CatatanRepository();

  List<Catatan> _catatan = [];

  bool _isLoading = false;

  String? _error;

  List<Catatan> get catatan => List.unmodifiable(_catatan);

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> muatCatatan() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _catatan = await _repository.semua();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tambahCatatan(Catatan baru) async {
    await _repository.tambah(baru);
    await muatCatatan();
  }

  Future<void> ubahCatatan(Catatan catatan) async {
    final jumlahDiubah = await _repository.ubah(catatan);

    if (jumlahDiubah == 0) {
      throw StateError('Catatan tidak ditemukan.');
    }

    await muatCatatan();
  }

  Future<void> hapusCatatan(int id) async {
    final jumlahDihapus = await _repository.hapus(id);

    if (jumlahDihapus == 0) {
      throw StateError('Catatan tidak ditemukan.');
    }

    await muatCatatan();
  }
}