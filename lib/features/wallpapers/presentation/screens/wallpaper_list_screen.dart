import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_card.dart';
import 'wallpaper_detail_screen.dart';

class WallpaperListScreen extends StatefulWidget {
  final String category;

  const WallpaperListScreen({super.key, required this.category});

  @override
  State<WallpaperListScreen> createState() => _WallpaperListScreenState();
}

class _WallpaperListScreenState extends State<WallpaperListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WallpaperProvider>(context, listen: false)
          .fetchWallpapers(widget.category, isRefresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        Provider.of<WallpaperProvider>(context, listen: false).fetchWallpapers(widget.category);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Wallpapers'),
      ),
      body: Consumer<WallpaperProvider>(
        builder: (context, provider, child) {
          if (provider.wallpapers.isEmpty && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.wallpapers.isEmpty && !provider.isLoading) {
            return const Center(child: Text('No wallpapers found.'));
          }

          if (provider.error.isNotEmpty && provider.wallpapers.isEmpty) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: provider.wallpapers.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.wallpapers.length) {
                return const Center(child: CircularProgressIndicator());
              }

              return WallpaperCard(
                wallpaper: provider.wallpapers[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WallpaperDetailScreen(
                        wallpaper: provider.wallpapers[index],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
