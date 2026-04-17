import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import '../../domain/entities/wallpaper_entity.dart';
import '../providers/favorites_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class WallpaperDetailScreen extends StatefulWidget {
  final WallpaperEntity wallpaper;

  const WallpaperDetailScreen({super.key, required this.wallpaper});

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  bool _isDownloading = false;

  Future<void> _downloadImage(BuildContext context) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Downloading is not supported on Web yet.'),
        ),
      );
      return;
    }

    setState(() => _isDownloading = true);
    try {
      String filePath = '';
      if (widget.wallpaper.imageUrl.startsWith('assets/')) {
        filePath = 'Already saved locally!';
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This is a Premium Offline Wallpaper.')),
        );
        setState(() => _isDownloading = false);
        return;
      } else {
        final response = await http.get(Uri.parse(widget.wallpaper.imageUrl));

        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/Wallify_${widget.wallpaper.id}.jpg';
        final file = File(tempPath);
        await file.writeAsBytes(response.bodyBytes);

        final params = SaveFileDialogParams(
          sourceFilePath: tempPath,
          fileName: 'Wallify_${widget.wallpaper.id}.jpg',
        );

        final savedFilePath = await FlutterFileDialog.saveFile(params: params);

        if (savedFilePath != null) {
          filePath = savedFilePath.toString();
        } else {
          // User canceled the dialog
          setState(() => _isDownloading = false);
          return;
        }
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Wallpaper saved to $filePath')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save to file: $e')));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _setWallpaper(BuildContext context, int location) async {
    setState(() => _isDownloading = true);
    try {
      String filePath = '';
      if (widget.wallpaper.imageUrl.startsWith('assets/')) {
        // For assets, we need to copy them to a temp file first since the plugin needs a path
        final byteData = await DefaultAssetBundle.of(context).load(widget.wallpaper.imageUrl);
        final directory = await getTemporaryDirectory();
        filePath = '${directory.path}/temp_wallpaper.png';
        final file = File(filePath);
        await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      } else {
        final response = await http.get(Uri.parse(widget.wallpaper.imageUrl));
        final directory = await getTemporaryDirectory();
        filePath = '${directory.path}/${widget.wallpaper.id}.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
      }

      bool result = await WallpaperManager.setWallpaperFromFile(
        filePath,
        location,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result ? 'Wallpaper set successfully' : 'Failed to set wallpaper',
          ),
          backgroundColor: result ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error setting wallpaper: $e')));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _showWallpaperOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Set Wallpaper',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text('Home Screen', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(context, WallpaperManager.HOME_SCREEN);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.white),
                title: const Text('Lock Screen', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(context, WallpaperManager.LOCK_SCREEN);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phonelink_setup, color: Colors.white),
                title: const Text('Both Screens', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(context, WallpaperManager.BOTH_SCREEN);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, provider, child) {
              final isFavorite = provider.isFavorite(widget.wallpaper);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  provider.toggleFavorite(widget.wallpaper);
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Hero(
            tag: widget.wallpaper.id,
            child: PhotoView(
              imageProvider: widget.wallpaper.imageUrl.startsWith('assets/')
                  ? AssetImage(widget.wallpaper.imageUrl) as ImageProvider
                  : CachedNetworkImageProvider(widget.wallpaper.imageUrl),
              loadingBuilder: (context, event) =>
                  const Center(child: CircularProgressIndicator()),
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.error, color: Colors.white)),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
          if (_isDownloading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.black.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.download,
                label: 'Save',
                onTap: () => _downloadImage(context),
              ),
              if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
                _buildActionButton(
                  icon: Icons.wallpaper,
                  label: 'Set Wallpaper',
                  onTap: () => _showWallpaperOptions(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
