import 'package:flutter/material.dart';

import '../models/professional_profile.dart';
import '../services/local_storage.dart';
import '../theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(4, (_) => TextEditingController());
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    LocalStorage().loadProfile().then((profile) {
      final values = [
        profile.name,
        profile.profession,
        profile.phone,
        profile.pixKey,
      ];
      for (var i = 0; i < values.length; i++) {
        _controllers[i].text = values[i];
      }
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    await LocalStorage().saveProfile(
      ProfessionalProfile(
        name: _controllers[0].text.trim(),
        profession: _controllers[1].text.trim(),
        phone: _controllers[2].text.trim(),
        pixKey: _controllers[3].text.trim(),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Configurações salvas')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Configurações')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Aparência',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeModeNotifier,
                  builder: (context, mode, child) =>
                      DropdownButtonFormField<ThemeMode>(
                        initialValue: mode,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.dark_mode_outlined),
                          labelText: 'Tema',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('Seguir o sistema'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Claro'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Escuro'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setThemeMode(value);
                        },
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Seus dados profissionais',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < 4; i++) ...[
                  TextFormField(
                    controller: _controllers[i],
                    decoration: InputDecoration(
                      labelText: const [
                        'Nome',
                        'Profissão ou empresa',
                        'Telefone',
                        'Chave Pix',
                      ][i],
                      prefixIcon: Icon(
                        const [
                          Icons.person_outline,
                          Icons.work_outline,
                          Icons.phone_outlined,
                          Icons.pix,
                        ][i],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
  );
}
