import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/book_catalog.dart';
import '../../providers/app_language_provider.dart';

class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen({
    super.key,
    required this.book,
    required this.volume,
    required this.file,
  });

  final BookItem book;
  final BookVolume volume;
  final File file;

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  static const _nightModeKey = 'book_reader_night_mode';
  static const _nightModeColorMatrix = <double>[
    -1,
    0,
    0,
    0,
    255,
    0,
    -1,
    0,
    0,
    255,
    0,
    0,
    -1,
    0,
    255,
    0,
    0,
    0,
    1,
    0,
  ];

  final PdfViewerController _controller = PdfViewerController();
  late final PdfTextSearcher _textSearcher;
  final TextEditingController _searchController = TextEditingController();
  late Future<SharedPreferences> _preferencesFuture;
  late PdfDocumentRef _documentRef;
  late PdfDocumentListenable _documentListenable;
  VoidCallback? _removeDocumentListener;
  Future<void> _pendingPageSave = Future<void>.value();
  int _currentPage = 1;
  int? _pageCount;
  bool _searchOpen = false;
  bool? _nightModeOverride;
  bool _hasRestoredProgress = false;
  bool _storageWarningShown = false;

  String get _progressKey =>
      'book_reader_page_${widget.book.id}_${widget.volume.number}';

  String get _bookmarkKey =>
      'book_reader_bookmark_${widget.book.id}_${widget.volume.number}';

  @override
  void initState() {
    super.initState();
    _textSearcher = PdfTextSearcher(_controller)..addListener(_onSearchChanged);
    _searchController.addListener(_onSearchTextChanged);
    _preferencesFuture = SharedPreferences.getInstance();
    _loadDocument();
  }

  @override
  void dispose() {
    _textSearcher
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchController.dispose();
    _removeDocumentListener?.call();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchTextChanged() {
    _textSearcher.startTextSearch(_searchController.text);
  }

  void _closeSearch() {
    _searchController.clear();
    _textSearcher.resetTextSearch();
    setState(() => _searchOpen = false);
  }

  void _loadDocument() {
    _documentRef = PdfDocumentRefFile(widget.file.path);
    _documentListenable = _documentRef.resolveListenable();
    _removeDocumentListener =
        _documentListenable.addListener(_onDocumentChanged);
    unawaited(_documentListenable.load());
  }

  void _onDocumentChanged() {
    if (_documentListenable.error != null) {
      debugPrint(
        'Could not load book PDF ${widget.file.path}: '
        '${_documentListenable.error}',
      );
    }
    if (mounted) setState(() {});
  }

  void _retryDocumentLoad() {
    unawaited(_documentListenable.load(forceReload: true));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _preferencesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(
            'Could not load book reader settings: '
            '${snapshot.error}\n${snapshot.stackTrace}',
          );
          return Scaffold(
            appBar: AppBar(title: Text(widget.book.title)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr('Reader settings could not be loaded.'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _preferencesFuture = SharedPreferences.getInstance();
                        });
                      },
                      child: Text(context.tr('Try again')),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final preferences = snapshot.data;
        if (preferences == null) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.book.title)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final nightMode =
            _nightModeOverride ?? (preferences.getBool(_nightModeKey) ?? false);
        final savedPage = preferences.getInt(_progressKey) ?? 1;
        final initialPage = savedPage < 1 ? 1 : savedPage;
        final bookmarkPage = preferences.getInt(_bookmarkKey);
        final displayedPage = _pageCount == null ? initialPage : _currentPage;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  widget.volume.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: context.tr('Search in book'),
                onPressed: _pageCount == null
                    ? null
                    : () {
                        if (_searchOpen) {
                          _closeSearch();
                        } else {
                          setState(() => _searchOpen = true);
                        }
                      },
                icon: Icon(
                  _searchOpen ? Icons.close : Icons.search,
                ),
              ),
              IconButton(
                tooltip: context.tr(
                  nightMode ? 'Switch to day mode' : 'Switch to night mode',
                ),
                onPressed: () => _toggleNightMode(preferences, nightMode),
                icon: Icon(
                  nightMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
              IconButton(
                tooltip: context.tr(
                  bookmarkPage == displayedPage
                      ? 'Remove bookmark'
                      : 'Save bookmark',
                ),
                onPressed: _pageCount == null
                    ? null
                    : () => _toggleBookmark(
                          preferences,
                          bookmarkPage,
                          displayedPage,
                        ),
                icon: Icon(
                  bookmarkPage == displayedPage
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
              ),
              IconButton(
                tooltip: context.tr('Go to bookmark'),
                onPressed: bookmarkPage == null || _pageCount == null
                    ? null
                    : () => _goToPage(bookmarkPage),
                icon: const Icon(Icons.bookmark_border),
              ),
            ],
          ),
          body: Column(
            children: [
              if (_searchOpen) _buildSearchControls(context),
              Expanded(
                child: _buildPdfViewer(
                  context,
                  preferences,
                  nightMode,
                ),
              ),
              _buildPageControls(
                context,
                displayedPage,
                _pageCount,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchControls(BuildContext context) {
    final searcher = _textSearcher;
    final matchCount = searcher.matches.length;
    final currentIndex = searcher.currentIndex;
    final searchPending = _searchController.text.isNotEmpty &&
        searcher.pattern != _searchController.text;
    final resultLabel = matchCount > 0
        ? '${(currentIndex ?? 0) + 1} / $matchCount'
        : searcher.isSearching || searchPending
            ? context.tr('Searching…')
            : _searchController.text.isNotEmpty
                ? context.tr('No matches')
                : '';

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (searcher.isSearching)
            LinearProgressIndicator(value: searcher.searchProgress)
          else
            const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: context.tr('Search book text'),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (resultLabel.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    resultLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              IconButton(
                tooltip: context.tr('Previous match'),
                onPressed: currentIndex != null && currentIndex > 0
                    ? () => searcher.goToPrevMatch()
                    : null,
                icon: const Icon(Icons.keyboard_arrow_up),
              ),
              IconButton(
                tooltip: context.tr('Next match'),
                onPressed: currentIndex == null || currentIndex + 1 < matchCount
                    ? matchCount > 0
                        ? () => searcher.goToNextMatch()
                        : null
                    : null,
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
              IconButton(
                tooltip: context.tr('Close search'),
                onPressed: _closeSearch,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer(
    BuildContext context,
    SharedPreferences preferences,
    bool nightMode,
  ) {
    final backgroundColor = nightMode ? Colors.white : const Color(0xFFE7E9EC);
    final documentError = _documentListenable.error;
    if (documentError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('This PDF could not be opened.'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _retryDocumentLoad,
                icon: const Icon(Icons.refresh),
                label: Text(context.tr('Try again')),
              ),
            ],
          ),
        ),
      );
    }
    if (_documentListenable.document == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget viewer = PdfViewer(
      _documentRef,
      controller: _controller,
      params: PdfViewerParams(
        backgroundColor: backgroundColor,
        enableTextSelection: true,
        maxScale: 4.0,
        pagePaintCallbacks: [_textSearcher.pageTextMatchPaintCallback],
        onPageChanged: (pageNumber) => _onPageChanged(pageNumber, preferences),
      ),
      initialPageNumber: 1,
    );

    if (nightMode) {
      viewer = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_nightModeColorMatrix),
        child: viewer,
      );
    }

    return ColoredBox(
      color: nightMode ? Colors.black : backgroundColor,
      child: viewer,
    );
  }

  Widget _buildPageControls(
    BuildContext context,
    int displayedPage,
    int? pageCount,
  ) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Material(
        color: colors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: pageCount == null ? null : displayedPage / pageCount,
            ),
            Row(
              children: [
                IconButton(
                  tooltip: context.tr('Previous page'),
                  onPressed: pageCount == null || displayedPage <= 1
                      ? null
                      : () => _goToPage(displayedPage - 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: pageCount == null
                        ? null
                        : () => _showGoToPageDialog(
                              context,
                              displayedPage,
                              pageCount,
                            ),
                    child: Text(
                      _pageIndicator(context, displayedPage, pageCount),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.tr('Next page'),
                  onPressed: pageCount == null || displayedPage >= pageCount
                      ? null
                      : () => _goToPage(displayedPage + 1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _pageIndicator(
    BuildContext context,
    int currentPage,
    int? pageCount,
  ) {
    if (pageCount == null) return context.tr('Loading');
    return context
        .tr('Page {current} of {total}')
        .replaceAll('{current}', '$currentPage')
        .replaceAll('{total}', '$pageCount');
  }

  void _onPageChanged(int? pageNumber, SharedPreferences preferences) {
    if (!mounted || pageNumber == null) return;
    final pageCount = _controller.pageCount;

    if (!_hasRestoredProgress) {
      _hasRestoredProgress = true;
      final savedPage = preferences.getInt(_progressKey) ?? 1;
      final restoredPage = savedPage.clamp(1, pageCount).toInt();
      setState(() {
        _currentPage = restoredPage;
        _pageCount = pageCount;
      });
      if (restoredPage != pageNumber) {
        unawaited(_controller.goToPage(pageNumber: restoredPage));
        return;
      }
    }

    setState(() {
      _currentPage = pageNumber;
      _pageCount = pageCount;
    });
    _pendingPageSave = _pendingPageSave.then((_) async {
      await _persist(() => preferences.setInt(_progressKey, pageNumber));
    });
  }

  Future<void> _goToPage(int pageNumber) async {
    final pageCount = _pageCount;
    if (pageCount == null) return;
    final boundedPage = pageNumber.clamp(1, pageCount).toInt();
    await _controller.goToPage(pageNumber: boundedPage);
  }

  Future<void> _showGoToPageDialog(
    BuildContext context,
    int currentPage,
    int pageCount,
  ) async {
    final formKey = GlobalKey<FormState>();
    final pageController = TextEditingController(text: '$currentPage');
    final selectedPage = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('Go to page')),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: pageController,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.tr('Page number'),
            ),
            validator: (value) {
              final page = int.tryParse(value?.trim() ?? '');
              if (page == null || page < 1 || page > pageCount) {
                return context.tr('Enter a valid page number.');
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(
                  dialogContext,
                  int.parse(pageController.text.trim()),
                );
              }
            },
            child: Text(context.tr('Go')),
          ),
        ],
      ),
    );
    pageController.dispose();
    if (selectedPage != null) await _goToPage(selectedPage);
  }

  Future<void> _toggleNightMode(
    SharedPreferences preferences,
    bool currentValue,
  ) async {
    final nextValue = !currentValue;
    setState(() => _nightModeOverride = nextValue);
    await _persist(() => preferences.setBool(_nightModeKey, nextValue));
  }

  Future<void> _toggleBookmark(
    SharedPreferences preferences,
    int? bookmarkPage,
    int currentPage,
  ) async {
    final removingBookmark = bookmarkPage == currentPage;
    final saved = removingBookmark
        ? await _persist(() => preferences.remove(_bookmarkKey))
        : await _persist(
            () => preferences.setInt(_bookmarkKey, currentPage),
          );
    if (!mounted || !saved) return;
    setState(() {});
    _showMessage(
      context.tr(removingBookmark ? 'Bookmark removed' : 'Bookmark saved'),
    );
  }

  Future<bool> _persist(Future<bool> Function() operation) async {
    try {
      if (await operation()) return true;
    } on PlatformException catch (error, stackTrace) {
      debugPrint(
        'Could not save book reader settings: $error\n$stackTrace',
      );
    } on MissingPluginException catch (error, stackTrace) {
      debugPrint(
        'Could not save book reader settings: $error\n$stackTrace',
      );
    }

    if (mounted && !_storageWarningShown) {
      _storageWarningShown = true;
      _showMessage(context.tr('Reader settings could not be saved.'));
    }
    return false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
