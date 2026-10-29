import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/profile_viewmodel.dart';
import 'app_router.dart';
import 'routes.dart';
import 'theme.dart';

class ProfilMahasiswaApp extends StatelessWidget {
  const ProfilMahasiswaApp({super.key, this.viewModel});

  /// Opsional, dipakai pada pengujian untuk menyuntikkan ViewModel.
  final ProfileViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    // ViewModel dibuat satu kali di atas MaterialApp, sehingga semua layar
    // berbagi state yang sama dan state tidak hilang saat pindah layar.
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => viewModel ?? ProfileViewModel(),
      child: MaterialApp(
        title: 'Profil Mahasiswa',
        debugShowCheckedModeBanner: false,
        theme: buildUmTheme(),
        initialRoute: AppRoutes.home,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
