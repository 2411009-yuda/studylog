class Catatan {
  final int? id;
  final String mataKuliah;
  final String judul;
  final String isi;
  final String tanggal;

  const Catatan({
    this.id,
    required this.mataKuliah,
    required this.judul,
    required this.isi,
    required this.tanggal,
  });

  factory Catatan.fromMap(Map<String, Object?> map) {
    return Catatan(
      id: map['id'] as int?,
      mataKuliah: map['mata_kuliah'] as String,
      judul: map['judul'] as String,
      isi: map['isi'] as String,
      tanggal: map['tanggal'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'mata_kuliah': mataKuliah,
      'judul': judul,
      'isi': isi,
      'tanggal': tanggal,
    };
  }

  Catatan copyWith({
    int? id,
    String? mataKuliah,
    String? judul,
    String? isi,
    String? tanggal,
  }) {
    return Catatan(
      id: id ?? this.id,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}