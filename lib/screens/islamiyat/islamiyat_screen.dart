import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/islamiyat_model.dart';
import '../../providers/app_language_provider.dart';
import '../../services/islamiyat_content_service.dart';
import '../../utils/user_friendly_error.dart';
import '../../widgets/service_loading_view.dart';

class IslamiyatScreen extends StatefulWidget {
  const IslamiyatScreen({super.key, this.service});

  final IslamiyatContentService? service;

  @override
  State<IslamiyatScreen> createState() => _IslamiyatScreenState();
}

class _IslamiyatScreenState extends State<IslamiyatScreen> {
  late final IslamiyatContentService _service =
      widget.service ?? IslamiyatContentService();
  final TextEditingController _searchController = TextEditingController();
  IslamiyatCatalog? _catalog;
  String? _error;
  String _query = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final catalog = await _service.load();
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _isLoading = false;
      });
    } on IslamiyatContentLoadException catch (error) {
      debugPrint('Failed to load Islamiyat catalog: $error');
      if (!mounted) return;
      setState(() {
        _error = UserFriendlyError.content(error.cause);
        _isLoading = false;
      });
    }
  }

  String _localized(Map<String, String> text, String languageCode) =>
      text[languageCode] ?? text['en'] ?? text.values.first;

  List<IslamiyatArticle> _filteredArticles(String languageCode) {
    final articles = _catalog?.articles ?? const <IslamiyatArticle>[];
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return articles;

    return articles.where((article) {
      final searchableText = [
        article.id,
        ...article.title.values,
        ...article.question.values,
        ...article.answer.values,
        ...article.tags,
        ...article.sources.expand((source) => [
              source.type,
              source.title,
              source.author ?? '',
              source.reference,
              source.quote ?? '',
            ]),
        _localized(article.title, languageCode),
        _localized(article.question, languageCode),
        _localized(article.answer, languageCode),
      ];
      return searchableText.any((text) => text.toLowerCase().contains(query));
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<AppLanguageProvider>().languageCode;
    final articles = _filteredArticles(languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Islamiyat')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: context.tr('Refresh content'),
            onPressed: _isLoading ? null : _loadCatalog,
          ),
        ],
      ),
      body: _isLoading
          ? const ServiceLoadingView(
              serviceName: 'Islamiyat',
              icon: Icons.menu_book_outlined,
            )
          : _error != null
              ? _LoadError(
                  message: context.tr(_error!),
                  onRetry: _loadCatalog,
                )
              : Column(
                  children: [
                    _SearchField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    if (_catalog?.isOffline ?? false)
                      _OfflineNotice(
                          message: context.tr(
                        'Offline: showing saved Islamiyat content.',
                      )),
                    Expanded(
                      child: articles.isEmpty
                          ? _EmptyState(
                              isSearching: _query.trim().isNotEmpty,
                              onRefresh: _loadCatalog,
                            )
                          : RefreshIndicator(
                              onRefresh: _loadCatalog,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                itemCount: articles.length,
                                itemBuilder: (context, index) {
                                  final article = articles[index];
                                  final title =
                                      _localized(article.title, languageCode);
                                  final question = _localized(
                                    article.question,
                                    languageCode,
                                  );
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        child: Icon(
                                          Icons.question_answer_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                      title: Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              question,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${article.sources.length} '
                                              '${context.tr(article.sources.length == 1 ? 'reference' : 'references')}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                      ),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => IslamiyatDetailScreen(
                                            article: article,
                                            languageCode: languageCode,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: context.tr('Search questions, answers, and sources'),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: context.tr('Clear search'),
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isSearching,
    required this.onRefresh,
  });

  final bool isSearching;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSearching ? Icons.search_off : Icons.menu_book_outlined,
                size: 52,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr(
                  isSearching
                      ? 'No matching content found.'
                      : 'No content published yet.',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (!isSearching) ...[
                const SizedBox(height: 8),
                Text(
                  context.tr('Add articles to the Islamiyat GitHub JSON file.'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.tr('Refresh content')),
                ),
              ],
            ],
          ),
        ),
      );
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 52),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.tr('Try again')),
              ),
            ],
          ),
        ),
      );
}

class IslamiyatDetailScreen extends StatelessWidget {
  const IslamiyatDetailScreen({
    super.key,
    required this.article,
    required this.languageCode,
  });

  final IslamiyatArticle article;
  final String languageCode;

  String _localized(Map<String, String> text) =>
      text[languageCode] ?? text['en'] ?? text.values.first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_localized(article.title))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.tr('Question'),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _localized(article.question),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _localized(article.answer),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
          ),
          if (article.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: article.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 28),
          Text(
            context.tr('References'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr(
              'References are provided by the article author; verify the edition and context.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...article.sources.map((source) => _SourceCard(source: source)),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source});

  final IslamiyatSource source;

  Future<void> _openSource(BuildContext context) async {
    final url = source.url;
    if (url == null) return;
    try {
      final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.tr('Could not open this source link.'))),
        );
      }
    } on Exception catch (error) {
      debugPrint('Could not open Islamiyat source URL: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.tr('Could not open this source link.'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text('${source.type} · ${source.reference}'),
            if (source.author != null) ...[
              const SizedBox(height: 4),
              Text('${context.tr('Author')}: ${source.author}'),
            ],
            if (source.quote != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '“${source.quote}”',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
            ],
            if (source.url != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => _openSource(context),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(context.tr('Open source')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
