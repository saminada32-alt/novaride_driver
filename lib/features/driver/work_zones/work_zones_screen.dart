import 'package:flutter/material.dart';
import '../../../core/services/work_zones_service.dart';
import '../../../l10n/app_localizations.dart';

class WorkZonesScreen extends StatefulWidget {
  const WorkZonesScreen({super.key});

  @override
  State<WorkZonesScreen> createState() => _WorkZonesScreenState();
}

class _WorkZonesScreenState extends State<WorkZonesScreen> {
  List<WorkZone> _zones = [];
  bool _onShift = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final zones = await WorkZonesService.instance.list();
    final onShift = await WorkZonesService.instance.isOnShift();
    if (!mounted) return;
    setState(() {
      _zones = zones;
      _onShift = onShift;
      _loading = false;
    });
  }

  Future<void> _addZone() async {
    final t = AppLocalizations.of(context)!;
    final cityCtrl = TextEditingController(text: 'damascus');
    final areaCtrl = TextEditingController();
    TimeOfDay start = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 22, minute: 0);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.workZoneAdd),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cityCtrl,
                decoration: InputDecoration(labelText: t.city),
              ),
              TextField(
                controller: areaCtrl,
                decoration: InputDecoration(labelText: t.workArea),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.back),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.save),
          ),
        ],
      ),
    );

    if (ok != true || areaCtrl.text.trim().isEmpty) return;

    await WorkZonesService.instance.add({
      'city': cityCtrl.text.trim(),
      'workArea': areaCtrl.text.trim(),
      'workStart':
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
      'workEnd':
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
    });
    await _load();
  }

  String _fmtTime(String t24) {
    final p = t24.split(':');
    if (p.length < 2) return t24;
    return '${p[0]}:${p[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.workZonesTitle),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addZone,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: _onShift ? Colors.green.shade50 : Colors.orange.shade50,
                    child: ListTile(
                      leading: Icon(
                        _onShift ? Icons.check_circle : Icons.schedule,
                        color: _onShift ? Colors.green : Colors.orange,
                      ),
                      title: Text(
                        _onShift ? t.workZonesOnShift : t.workZonesOffShift,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(t.workZonesScheduleHint),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._zones.map(
                    (z) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text('${z.city} · ${z.workArea}'),
                        subtitle: Text(
                          '${_fmtTime(z.workStart)} – ${_fmtTime(z.workEnd)}'
                          '${z.isPrimary ? ' · ${t.workZonePrimary}' : ''}',
                        ),
                        trailing: z.isPrimary
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await WorkZonesService.instance.delete(z.id);
                                  await _load();
                                },
                              ),
                      ),
                    ),
                  ),
                  if (_zones.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          t.workZonesEmpty,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
