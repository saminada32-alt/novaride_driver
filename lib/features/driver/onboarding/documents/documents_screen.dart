import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/providers/auth_provider.dart';
import 'provider/document_provider.dart';
import 'services/document_service.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../location/location_info_screen.dart';

class DocumentsScreen extends StatefulWidget {
  final bool resubmitOnly;
  const DocumentsScreen({super.key, this.resubmitOnly = false});
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _picker = ImagePicker();

  // عناوين الوثائق
  late Map<String, String> _titles;

  @override
  void initState() {
    super.initState();
    if (widget.resubmitOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final token = context.read<AuthProvider>().token;
        if (token != null) {
          await context.read<DocumentsProvider>().loadRejectedFields(token);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final local = AppLocalizations.of(context)!;
    _titles = {
      'profile': local.profilePicture,
      'driverIdFront': local.driverIdFront,
      'driverIdBack': local.driverIdBack,
      'licenseFront': local.licenseFront,
      'licenseBack': local.licenseBack,
      'insuranceFront': local.insurance,
      'vehicleFront': local.vehicleFrontPhoto,
      'vehicleBack': local.vehicleBackPhoto,
    };
  }

  Future<void> _pick(String key) async {
    final prov = context.read<DocumentsProvider>();
    final local = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: Text(local.camera),
              onTap: () async {
                Navigator.pop(context);
                await _pickFrom(key, ImageSource.camera, prov);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: Text(local.gallery),
              onTap: () async {
                Navigator.pop(context);
                await _pickFrom(key, ImageSource.gallery, prov);
              },
            ),
            if (prov.files[key] != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(local.remove),
                onTap: () {
                  Navigator.pop(context);
                  prov.removeFile(key);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFrom(
    String key,
    ImageSource src,
    DocumentsProvider prov,
  ) async {
    final p = await _picker.pickImage(
      source: src,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (p == null) return;

    // ضغط الصورة
    final targetPath =
        '${File(p.path).parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressed = await FlutterImageCompress.compressAndGetFile(
      p.path,
      targetPath,
      quality: 80,
      minWidth: 800,
      minHeight: 800,
    );

    prov.setFile(
      key,
      compressed != null ? File(compressed.path) : File(p.path),
    );
  }

  Future<void> _submit() async {
    final token = context.read<AuthProvider>().token;
    final prov = context.read<DocumentsProvider>();
    if (token == null) return;

    final local = AppLocalizations.of(context)!;

    final ok = await prov.uploadAll(token);
    if (!mounted) return;

    if (ok) {
      if (prov.resubmitMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(local.documentsSentReview),
            backgroundColor: Colors.green.shade600,
          ),
        );
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LocationInfoScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.errorMessage ?? local.uploadFailedTryAgain),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _progressBar() => Row(
    children: List.generate(
      4,
      (i) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          decoration: BoxDecoration(
            color: i <= 2 ? Colors.green : Colors.green.withOpacity(.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
  );

  Widget _tile(String key, String title, {String? subtitle}) {
    final prov = context.watch<DocumentsProvider>();
    final local = AppLocalizations.of(context)!;
    final file = prov.files[key];
    final serverUrl = prov.serverUrls[key];
    final apiField = DocumentsService.apiFieldForAppKey(key) ?? key;
    final rejectionReason = prov.rejectedFields[apiField];
    final isRejected = rejectionReason != null && rejectionReason.isNotEmpty;

    Widget preview;
    if (file != null) {
      preview = Image.file(file, width: 52, height: 52, fit: BoxFit.cover);
    } else if (serverUrl != null && !isRejected) {
      preview = AppNetworkImage(
        url: serverUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        fallback: Container(
          width: 52,
          height: 52,
          color: Colors.grey.shade100,
          child: const Icon(Icons.upload_file, color: Colors.grey, size: 26),
        ),
      );
    } else {
      preview = Container(
        width: 52,
        height: 52,
        color: Colors.grey.shade100,
        child: const Icon(Icons.upload_file, color: Colors.grey, size: 26),
      );
    }

    return GestureDetector(
      onTap: () => _pick(key),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRejected
                ? Colors.red
                : file != null
                    ? Colors.green
                    : Colors.grey.shade300,
            width: 1.5,
          ),
          color: isRejected
              ? Colors.red.withOpacity(.03)
              : file != null
                  ? Colors.green.withOpacity(.02)
                  : Colors.white,
        ),
        child: Row(
          children: [
            // Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: preview,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                  if (isRejected) ...[
                    const SizedBox(height: 4),
                    Text(
                      rejectionReason,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (file != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      '✓ ${local.readyToUpload}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              file != null ? Icons.check_circle : Icons.radio_button_unchecked,
              color: file != null ? Colors.green : Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final prov = context.watch<DocumentsProvider>();
    final resubmit = prov.resubmitMode || widget.resubmitOnly;

    final allTiles = <Map<String, String?>>[
      {'key': 'profile', 'title': local.profilePicture, 'subtitle': local.profileDescription},
      {'key': 'driverIdFront', 'title': local.driverIdFront},
      {'key': 'driverIdBack', 'title': local.driverIdBack, 'subtitle': local.idDescription},
      {'key': 'licenseFront', 'title': local.licenseFront},
      {'key': 'licenseBack', 'title': local.licenseBack, 'subtitle': local.licenseDescription},
      {'key': 'insuranceFront', 'title': local.insurance},
      {'key': 'vehicleFront', 'title': local.vehicleFrontPhoto},
      {'key': 'vehicleBack', 'title': local.vehicleBackPhoto},
    ];

    final visibleTiles = resubmit && prov.rejectedAppKeys.isNotEmpty
        ? allTiles.where((t) => prov.rejectedAppKeys.contains(t['key'])).toList()
        : allTiles;

    final uploadedCount = visibleTiles
        .where((t) => prov.files[t['key']] != null)
        .length;
    final totalCount = visibleTiles.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car, color: Colors.green),
            SizedBox(width: 6),
            Text(
              local.appName,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _progressBar(),
            const SizedBox(height: 24),

            Text(
              resubmit ? local.resubmitDocumentsTitle : local.documentsTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              resubmit ? local.resubmitDocumentsSubtitle : local.documentsSubtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 12),

            // Counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.documentsSelected,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$uploadedCount / $totalCount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: uploadedCount == totalCount
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Upload Progress
            if (prov.isLoading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: prov.uploadProgress > 0 ? prov.uploadProgress : null,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  prov.uploadProgress > 0
                      ? '${(prov.uploadProgress * 100).toInt()}%'
                      : local.uploading,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Error
            if (prov.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prov.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // Document Tiles
            ...visibleTiles.map(
              (t) => _tile(
                t['key']!,
                t['title']!,
                subtitle: t['subtitle'],
              ),
            ),

            const SizedBox(height: 28),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: prov.isLoading
                        ? null
                        : () => Navigator.pop(context),
                    child: Text(
                      local.back,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: prov.isAllUploaded
                          ? Colors.black
                          : Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: (prov.isAllUploaded && !prov.isLoading)
                        ? _submit
                        : null,
                    child: prov.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            local.next,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
