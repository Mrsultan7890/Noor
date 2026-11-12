import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/book_catalog.dart';
import '../../providers/app_language_provider.dart';
import '../../services/book_catalog_service.dart';
import '../../services/book_download_service.dart';
import '../../widgets/service_loading_view.dart';

class BookLibraryScreen extends StatefulWidget {
  const BookLibraryScreen({
    super.key,
    this.catalogService,
    this.downloadService,
  });

  final BookCatalogService? catalogService;
  final BookDownloadService? downloadService;

  @override
  State<BookLibraryScreen> createState() => _BookLibraryScreenState();
}

class _BookLibraryScreenState extends State<BookLibraryScreen> {
  late final BookCatalogService _catalogService =
      widget.catalogService ?? BookCatalogService();
  late final BookDownloadService _downloadService =
      widget.downloadService ?? BookDownloadService();

  BookCatalog? _catalog;
  String _query = '';
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog({bool forceRefresh = false}) async {
    if (_catalog == null && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final catalog = await _catalogService.load(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _isLoading = false;
        if (_selectedCategory != null &&
            !catalog.categories.any(
              (category) => category.id == _selectedCategory,
            )) {
          _selectedCategory = null;
        }
      });
    } on BookCatalogLoadException catch (error, stackTrace) {
      debugPrint('Could not load the book catalog: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _catalog = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _catalog;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Book Library')),
        actions: [
          IconButton(
            tooltip: context.tr('Refresh books'),
            onPressed: () => _loadCatalog(forceRefresh: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading && catalog == null
          ? const ServiceLoadingView(
              serviceName: 'Book Library',
              icon: Icons.menu_book,
            )
          : catalog == null
              ? _buildLoadError(context)
              : _buildLibrary(context, catalog),
    );
  }

  Widget _buildLoadError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 52,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('Books could not be loaded'),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('Check your connection and try again.'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadCatalog,
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('Try again')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibrary(BuildContext context, BookCatalog catalog) {
    final books = catalog.search(
      query: _query,
      categoryId: _selectedCategory,
    );
    return RefreshIndicator(
      onRefresh: () => _loadCatalog(forceRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: context.tr('Search books, authors, or topics'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: context.tr('Clear search'),
                      onPressed: () => setState(() => _query = ''),
                      icon: const Icon(Icons.close),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (catalog.isOffline) ...[
            const SizedBox(height: 12),
            Material(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(context.tr('Showing saved books offline')),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(context.tr('All books')),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                ),
                for (final category in catalog.categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(context.tr(category.name)),
                      selected: _selectedCategory == category.id,
                      onSelected: (_) => setState(() {
                        _selectedCategory = _selectedCategory == category.id
                            ? null
                            : category.id;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${books.length} ${context.tr(books.length == 1 ? 'Book' : 'Books')}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 10),
          if (books.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 44),
              child: Column(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('No books found'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(context.tr('Try another search or category.')),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 4 : 2;
                return GridView.builder(
                  itemCount: books.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.61,
                  ),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final category = catalog.categories.firstWhere(
                      (item) => item.id == book.categoryId,
                    );
                    return _BookCard(
                      book: book,
                      categoryName: context.tr(category.name),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => BookDetailScreen(
                            book: book,
                            categoryName: context.tr(category.name),
                            downloadService: _downloadService,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.categoryName,
    required this.onTap,
  });

  final BookItem book;
  final String categoryName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primaryContainer,
                          colors.secondaryContainer,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.menu_book,
                      size: 54,
                      color: colors.primary.withOpacity(0.65),
                    ),
                  ),
                  Image.network(
                    book.coverUrl.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes == null
                              ? null
                              : progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 14,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          categoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({
    super.key,
    required this.book,
    required this.categoryName,
    required this.downloadService,
  });

  final BookItem book;
  final String categoryName;
  final BookDownloadService downloadService;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final Map<int, File> _downloadedFiles = {};
  final Set<int> _busyVolumes = {};
  final Map<int, double?> _downloadProgress = {};
  bool _checkingDownloads = true;

  @override
  void initState() {
    super.initState();
    _checkDownloadedFiles();
  }

  Future<void> _checkDownloadedFiles() async {
    try {
      final files = <int, File>{};
      for (final volume in widget.book.volumes) {
        final file =
            await widget.downloadService.getDownloadedFile(widget.book, volume);
        if (file != null) files[volume.number] = file;
      }
      if (!mounted) return;
      setState(() {
        _downloadedFiles.addAll(files);
        _checkingDownloads = false;
      });
    } on FileSystemException catch (error, stackTrace) {
      debugPrint(
          'Could not inspect downloaded book files: $error\n$stackTrace');
      if (mounted) setState(() => _checkingDownloads = false);
    }
  }

  Future<void> _downloadAndOpen(BookVolume volume) async {
    setState(() {
      _busyVolumes.add(volume.number);
      _downloadProgress[volume.number] = null;
    });
    try {
      final file = _downloadedFiles[volume.number] ??
          await widget.downloadService.download(
            widget.book,
            volume,
            onProgress: (received, total) {
              if (!mounted) return;
              setState(() {
                _downloadProgress[volume.number] =
                    total > 0 ? received / total : null;
              });
            },
          );
      if (!mounted) return;
      setState(() => _downloadedFiles[volume.number] = file);
      await widget.downloadService.open(file);
    } on DioException catch (error, stackTrace) {
      debugPrint('Could not download book volume: $error\n$stackTrace');
      if (mounted) {
        _showMessage(context.tr('The book could not be downloaded.'));
      }
    } on FileSystemException catch (error, stackTrace) {
      debugPrint('Could not open the downloaded book: $error\n$stackTrace');
      if (mounted) {
        _showMessage(context.tr('No PDF reader could open the book.'));
      }
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Could not open the downloaded book: $error\n$stackTrace');
      if (mounted) {
        _showMessage(context.tr('No PDF reader could open the book.'));
      }
    } on FormatException catch (error, stackTrace) {
      debugPrint('Downloaded book failed PDF validation: $error\n$stackTrace');
      if (mounted) {
        _showMessage(context.tr('The downloaded file is not a valid PDF.'));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busyVolumes.remove(volume.number);
          _downloadProgress.remove(volume.number);
        });
      }
    }
  }

  Future<void> _openArchivePage() async {
    final didLaunch = await launchUrl(
      widget.book.archiveUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!didLaunch && mounted) {
      _showMessage(context.tr('Could not open Internet Archive.'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 190,
                height: 240,
                child: Image.network(
                  widget.book.coverUrl.toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.menu_book,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.book.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${context.tr('by')} ${widget.book.author}',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.folder_outlined, size: 18),
                  label: Text(widget.categoryName),
                ),
                Chip(
                  avatar: const Icon(Icons.language, size: 18),
                  label: Text(_languageName(context, widget.book.language)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.book.description,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 2,
            alignment: WrapAlignment.center,
            children: widget.book.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('Available volumes'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (final volume in widget.book.volumes)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text('${volume.number}'),
                      ),
                      title: Text(volume.title),
                      subtitle: Text(
                        _downloadedFiles.containsKey(volume.number)
                            ? context.tr('Saved for offline reading')
                            : volume.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: _busyVolumes.contains(volume.number)
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _downloadedFiles.containsKey(volume.number)
                                  ? Icons.download_done
                                  : Icons.picture_as_pdf_outlined,
                            ),
                    ),
                    if (_busyVolumes.contains(volume.number))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: LinearProgressIndicator(
                          value: _downloadProgress[volume.number],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _checkingDownloads ||
                                _busyVolumes.contains(volume.number)
                            ? null
                            : () => _downloadAndOpen(volume),
                        icon: Icon(
                          _downloadedFiles.containsKey(volume.number)
                              ? Icons.menu_book
                              : Icons.download,
                        ),
                        label: Text(
                          context.tr(
                            _downloadedFiles.containsKey(volume.number)
                                ? 'Read volume'
                                : 'Download & read',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _openArchivePage,
            icon: const Icon(Icons.open_in_new),
            label: Text(context.tr('View on Internet Archive')),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('Book hosted on Internet Archive'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _languageName(BuildContext context, String code) {
    return switch (code) {
      'en' => context.tr('English'),
      'ur' => context.tr('Urdu'),
      'ar' => context.tr('Arabic'),
      'id' => context.tr('Indonesian'),
      'tr' => context.tr('Turkish'),
      'fr' => context.tr('French'),
      _ => code,
    };
  }
}
