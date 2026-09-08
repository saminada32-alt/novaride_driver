import 'package:flutter/material.dart';
import '../../../core/services/work_zones_service.dart';
import '../../../l10n/app_localizations.dart';
import '../onboarding/location/syria_cities_catalog.dart';

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
    try {
      final zones = await WorkZonesService.instance.list();
      final onShift = await WorkZonesService.instance.isOnShift();
      if (!mounted) return;
      setState(() {
        _zones = zones;
        _onShift = onShift;
      });
    } catch (_) {
      // Keep whatever was already shown; the RefreshIndicator remains
      // available to retry rather than getting stuck loading forever.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addZone() async {
    final t = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    String selectedCity = SyriaCitiesCatalog.cities.first.id;
    List<SyriaArea> areas = SyriaCitiesCatalog.areasFor(selectedCity);
    String? selectedArea = areas.isNotEmpty ? areas.first.id : null;
    TimeOfDay start = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 22, minute: 0);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(t.workZoneAdd),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedCity,
                  decoration: InputDecoration(labelText: t.city),
                  items: SyriaCitiesCatalog.cities
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.label(isAr)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setDialogState(() {
                      selectedCity = v;
                      areas = SyriaCitiesCatalog.areasFor(v);
                      selectedArea = areas.isNotEmpty ? areas.first.id : null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedArea,
                  decoration: InputDecoration(labelText: t.workArea),
                  items: areas
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.label(isAr)),
                        ),
                      )
                      .toList(),
                  onChanged: areas.isEmpty
                      ? null
                      : (v) => setDialogState(() => selectedArea = v),
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
              onPressed: selectedArea == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: Text(t.save),
            ),
          ],
        ),
      ),
    );

    if (ok != true || selectedArea == null) return;

    try {
      await WorkZonesService.instance.add({
        'city': selectedCity,
        'workArea': selectedArea,
        'workStart':
            '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
        'workEnd':
            '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
      });
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.actionFailed), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteZone(WorkZone z) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.workZoneDeleteTitle),
        content: Text(t.workZoneDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await WorkZonesService.instance.delete(z.id);
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.actionFailed), backgroundColor: Colors.red),
      );
    }
  }

  String _fmtTime(String t24) {
    final p = t24.split(':');
    if (p.length < 2) return t24;
    return '${p[0]}:${p[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (WorkZonesService.workHoursDisabled) {
      return Scaffold(
        appBar: AppBar(title: Text(t.workZonesTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              t.workZonesDisabledBanner,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }
    return _buildBody(context);
  }

  String _zoneLabel(WorkZone z, bool isAr) {
    final city = SyriaCitiesCatalog.cityById(z.city);
    final area = SyriaCitiesCatalog.areasFor(z.city)
        .where((a) => a.id == z.workArea)
        .toList();
    final cityLabel = city?.label(isAr) ?? z.city;
    final areaLabel = area.isNotEmpty ? area.first.label(isAr) : z.workArea;
    return '$cityLabel · $areaLabel';
  }

  Widget _buildBody(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

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
                        title: Text(_zoneLabel(z, isAr)),
                        subtitle: Text(
                          '${_fmtTime(z.workStart)} – ${_fmtTime(z.workEnd)}'
                          '${z.isPrimary ? ' · ${t.workZonePrimary}' : ''}',
                        ),
                        trailing: z.isPrimary
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteZone(z),
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
