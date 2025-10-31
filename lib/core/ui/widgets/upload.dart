import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum SmartSource { camera, gallery, files }

class SmartAllowedTypes {
  final bool images;
  final bool pdf;
  final List<String> extraExtensions;

  const SmartAllowedTypes({
    this.images = true,
    this.pdf = false,
    this.extraExtensions = const [],
  });

  List<String> get filePickerExtensions {
    final exts = <String>[];
    if (pdf) exts.add('pdf');
    exts.addAll(
      extraExtensions.map((e) => e.replaceAll('.', '').toLowerCase()),
    );
    return exts.toSet().toList();
  }

  bool get hasFilePickerTypes => pdf || extraExtensions.isNotEmpty;
}

class SmartPickedFile {
  final File file;
  final String? displayName;
  final int sizeBytes;

  SmartPickedFile({
    required this.file,
    this.displayName,
    required this.sizeBytes,
  });
}

Future<void> showSmartUploaderBottomSheet({
  required BuildContext context,
  required void Function(List<SmartPickedFile> files) onSelected,
  SmartAllowedTypes allowedTypes = const SmartAllowedTypes(
    images: true,
    pdf: false,
  ),
  bool allowMultiple = false,
  int maxSizeInMB = 2,
  String? titleText,
  String? galleryText,
  String? cameraText,
  String? filesText,
  Color? accentColor,
}) async {
  final theme = Theme.of(context);
  final accent = accentColor ?? theme.colorScheme.primary;
  final picker = ImagePicker();

  Future<void> handleOverSize() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('الملف أكبر من الحد المسموح (${maxSizeInMB}MB)')),
    );
  }

  bool checkSizeOK(int bytes) => bytes <= maxSizeInMB * 1024 * 1024;

  Future<void> pickFromCamera() async {
    final x = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (x == null) return;
    final f = File(x.path);
    final size = await f.length();
    if (!checkSizeOK(size)) return handleOverSize();
    onSelected([
      SmartPickedFile(file: f, displayName: x.name, sizeBytes: size),
    ]);
  }

  Future<void> pickFromGallery() async {
    if (allowMultiple) {
      final xs = await picker.pickMultiImage(imageQuality: 85);
      if (xs.isEmpty) return;
      final list = <SmartPickedFile>[];
      for (final x in xs) {
        final f = File(x.path);
        final size = await f.length();
        if (!checkSizeOK(size)) {
          await handleOverSize();
          continue;
        }
        list.add(
          SmartPickedFile(file: f, displayName: x.name, sizeBytes: size),
        );
      }
      if (list.isNotEmpty) onSelected(list);
    } else {
      final x = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (x == null) return;
      final f = File(x.path);
      final size = await f.length();
      if (!checkSizeOK(size)) return handleOverSize();
      onSelected([
        SmartPickedFile(file: f, displayName: x.name, sizeBytes: size),
      ]);
    }
  }

  Future<void> pickFromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: allowedTypes.hasFilePickerTypes ? FileType.custom : FileType.any,
      allowedExtensions: allowedTypes.filePickerExtensions,
      withData: false,
    );
    if (result == null) return;
    final list = <SmartPickedFile>[];
    for (final p in result.files) {
      final path = p.path;
      if (path == null) continue;
      final f = File(path);
      final size = await f.length();
      if (!checkSizeOK(size)) {
        await handleOverSize();
        continue;
      }
      list.add(SmartPickedFile(file: f, displayName: p.name, sizeBytes: size));
    }
    if (list.isNotEmpty) onSelected(list);
  }

  await showModalBottomSheet(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.2),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titleText ?? 'اختر طريقة الرفع',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _UploadOptionButton(
                icon: Icons.photo_library_outlined,
                color: accent,
                text: galleryText ?? 'اختيار من المعرض',
                onTap: () async {
                  Navigator.pop(ctx);
                  await pickFromGallery();
                },
              ),
              const SizedBox(height: 12),
              _UploadOptionButton(
                icon: Icons.camera_alt_outlined,
                color: accent,
                text: cameraText ?? 'التقاط صورة',
                onTap: () async {
                  Navigator.pop(ctx);
                  await pickFromCamera();
                },
              ),
              if (allowedTypes.hasFilePickerTypes) ...[
                const SizedBox(height: 12),
                _UploadOptionButton(
                  icon: Icons.attach_file,
                  color: accent,
                  text: filesText ?? 'اختيار ملف',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await pickFromFiles();
                  },
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الحد الأقصى: ${maxSizeInMB}MB',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _UploadOptionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const _UploadOptionButton({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      icon: Icon(icon),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class SmartUploadField extends StatefulWidget {
  final String? title;
  final String hint;

  final int maxSizeInMB;
  final SmartAllowedTypes allowedTypes;
  final bool allowMultiple;
  final List<SmartSource> sources;
  final void Function(List<SmartPickedFile> files) onSelected;

  final ImageProvider? initialPreview;

  final Future<void> Function(
    BuildContext ctx,
    void Function(File) onSingleSelected,
  )?
  openWithLegacySheet;

  final Color? primaryColor;
  final Color? backgroundColor;
  final TextStyle? hintTextStyle;
  final Color? buttonBorderColor;
  final Color? buttonForegroundColor;
  final TextStyle? buttonLabelStyle;
  final String? assetImage;
  final Size assetSize;

  final double borderRadius;
  final List<int> dashPattern;
  final double strokeWidth;

  final EdgeInsets padding;

  const SmartUploadField({
    super.key,
    this.title,
    required this.hint,
    this.maxSizeInMB = 2,
    this.allowedTypes = const SmartAllowedTypes(images: true, pdf: false),
    this.allowMultiple = false,
    this.sources = const [
      SmartSource.gallery,
      SmartSource.camera,
      SmartSource.files,
    ],
    required this.onSelected,
    this.initialPreview,
    this.openWithLegacySheet,
    // شكل
    this.primaryColor,
    this.backgroundColor,
    this.hintTextStyle,
    this.buttonBorderColor,
    this.buttonForegroundColor,
    this.buttonLabelStyle,
    this.assetImage,
    this.assetSize = const Size(88, 51),
    this.borderRadius = 12,
    this.dashPattern = const [6, 4],
    this.strokeWidth = 1.5,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
  });

  @override
  State<SmartUploadField> createState() => _SmartUploadFieldState();
}

class _SmartUploadFieldState extends State<SmartUploadField> {
  List<SmartPickedFile> _picked = [];

  bool get _hasImagePreview {
    if (_picked.isNotEmpty) {
      final p = _picked.first.file.path.toLowerCase();
      return p.endsWith('.png') ||
          p.endsWith('.jpg') ||
          p.endsWith('.jpeg') ||
          p.endsWith('.webp');
    }
    return widget.initialPreview != null;
  }

  Widget _buildImagePreview() {
    if (!_hasImagePreview) return const SizedBox.shrink();

    final provider = _picked.isNotEmpty
        ? FileImage(_picked.first.file)
        : widget.initialPreview!;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image(
            image: provider,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black54,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close, color: Colors.white, size: 16),
              onPressed: () {
                setState(() => _picked.clear());
                widget.onSelected([]);
              },
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black54,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.edit, color: Colors.white, size: 16),
              onPressed: _openSheet,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNonImagePreview() {
    if (_picked.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.primaryColor ?? Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            color: widget.primaryColor ?? Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _picked.first.displayName ??
                  _picked.first.file.path.split('/').last,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() => _picked.clear());
              widget.onSelected([]);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openSheet() async {
    // لو وفّرت دالة الشيت القديمة، استعملها كما هي
    if (widget.openWithLegacySheet != null) {
      await widget.openWithLegacySheet!(context, (file) {
        final sp = SmartPickedFile(
          file: file,
          displayName: file.path.split('/').last,
          sizeBytes: file.lengthSync(),
        );
        setState(() => _picked = [sp]);
        widget.onSelected([sp]);
      });
      return;
    }

    await showSmartUploaderBottomSheet(
      context: context,
      onSelected: (files) {
        setState(() => _picked = files);
        widget.onSelected(files);
      },
      allowedTypes: widget.allowedTypes,
      allowMultiple: widget.allowMultiple,
      maxSizeInMB: widget.maxSizeInMB,
      titleText: 'اختر طريقة الرفع',
      galleryText: 'اختيار من المعرض',
      cameraText: 'التقاط صورة',
      filesText: 'اختيار ملف',
      accentColor: widget.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary =
        widget.primaryColor ?? Theme.of(context).colorScheme.primary;
    final bg = widget.backgroundColor ?? primary.withValues(alpha: 0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
        // Show image preview if we have an image
        if (_hasImagePreview)
          _buildImagePreview()
        // Show file preview if we have a non-image file
        else if (_picked.isNotEmpty)
          _buildNonImagePreview()
        // Show upload field if nothing is selected
        else
          DottedBorder(
            options: CustomPathDottedBorderOptions(
              color: primary,
              strokeWidth: widget.strokeWidth,
              dashPattern: widget.dashPattern.map((e) => e.toDouble()).toList(),
              customPath: (size) => Path()
                ..addRRect(
                  RRect.fromRectAndRadius(
                    Rect.fromLTWH(0, 0, size.width, size.height),
                    const Radius.circular(12),
                  ),
                ),
            ),
            child: InkWell(
              onTap: _openSheet,
              child: Container(
                width: double.infinity,
                color: bg,
                padding: widget.padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.assetImage != null) ...[
                      Image.asset(
                        widget.assetImage!,
                        width: widget.assetSize.width,
                        height: widget.assetSize.height,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      widget.hint,
                      textAlign: TextAlign.center,
                      style:
                          widget.hintTextStyle ??
                          const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _openSheet,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color:
                              widget.buttonBorderColor ??
                              const Color(0xFF00A388),
                        ),
                        foregroundColor:
                            widget.buttonForegroundColor ??
                            const Color(0xFF00A388),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload),
                      label: Text(
                        'رفع ملف',
                        style:
                            widget.buttonLabelStyle ??
                            TextStyle(
                              fontWeight: FontWeight.w700,
                              color: widget.primaryColor ?? primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
