import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/checklist/models/checklist_models.dart';
import 'package:systex_frotas/modules/checklist/screens/checklist_run_screen.dart';
import 'package:systex_frotas/modules/checklist/services/checklist_api_service.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';

class ChecklistHomeScreen extends StatefulWidget {
  const ChecklistHomeScreen({super.key});

  @override
  State<ChecklistHomeScreen> createState() => _ChecklistHomeScreenState();
}

class _ChecklistHomeScreenState extends State<ChecklistHomeScreen> {
  final ChecklistApiService _service = ChecklistApiService();
  bool _loading = true;
  List<Checklist> _checklists = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getAll();
      setState(() => _checklists = data);
    } catch (_) {
      if (!mounted) return;
      DgToast.show(context, 'Erro ao carregar checklists.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Checklists do Veículo'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') HomeScreen.performLogout(context);
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Logout'))],
          ),
        ],
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _checklists.isEmpty
              ? const Center(child: Text('Nenhum checklist encontrado.'))
              : ListView.separated(
                  itemCount: _checklists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = _checklists[index];
                    return DgCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChecklistRunScreen(checklistId: item.id, checklistNome: item.nome),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.nome, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(item.descricao.isEmpty ? 'Sem descrição' : item.descricao),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white),
                      ),
                    );
                  },
                ),
    );
  }
}
