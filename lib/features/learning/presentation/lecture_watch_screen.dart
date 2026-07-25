import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/arabic_numerals.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../courses/data/course_models.dart';
import '../../purchase/data/webview_ticket_repository.dart';
import '../application/learning_providers.dart';
import '../data/learning_repository.dart';

/// Native lecture-watching screen — replaces the generic [BridgeWebViewScreen]
/// for the "learn" case specifically. The embedded WebView still hosts the
/// actual lecture page (video player + speed/quality controls + any notes
/// below it — external content, not ours to restyle beyond `?embed=1`
/// stripping the site's own nav/sidebar/top-bar, see
/// resources/views/student/learn.blade.php on the Laravel side), but
/// everything structurally around it — app bar, position-in-course context,
/// up-next, prev/next, mark-complete — is native Modernist chrome. The
/// WebView gets the full remaining height (not a fixed video-only box) since
/// the real page has real content below the player that must stay reachable.
class LectureWatchScreen extends ConsumerStatefulWidget {
  const LectureWatchScreen({
    super.key,
    required this.courseId,
    required this.sections,
    required this.initialLectureId,
  });

  final int courseId;
  final List<CourseSection> sections;
  final int initialLectureId;

  @override
  ConsumerState<LectureWatchScreen> createState() => _LectureWatchScreenState();
}

class _LectureWatchScreenState extends ConsumerState<LectureWatchScreen> {
  late final List<(CourseSection section, CourseLecture lecture)> _flat;
  late int _index;
  String? _bridgeUrl;
  bool _isLoadingTicket = true;
  bool _isWebLoading = true;
  final Set<int> _visited = {};

  @override
  void initState() {
    super.initState();
    _flat = [
      for (final section in widget.sections)
        for (final lecture in section.lectures) (section, lecture),
    ];
    _index = _flat.indexWhere((e) => e.$2.id == widget.initialLectureId);
    if (_index < 0) _index = 0;
    _loadTicket();
  }

  (CourseSection, CourseLecture) get _current => _flat[_index];
  bool get _hasPrev => _index > 0;
  bool get _hasNext => _index < _flat.length - 1;

  Future<void> _loadTicket() async {
    setState(() {
      _isLoadingTicket = true;
      _isWebLoading = true;
      _bridgeUrl = null;
    });
    try {
      final url = await ref
          .read(webviewTicketRepositoryProvider)
          .requestLearnTicket(
            courseId: widget.courseId,
            lectureId: _current.$2.id,
          );
      if (mounted) setState(() => _bridgeUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToOpenLecture(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingTicket = false);
    }
  }

  Future<void> _markCurrentComplete() async {
    final id = _current.$2.id;
    if (_visited.add(id)) {
      try {
        await ref.read(learningRepositoryProvider).markLectureComplete(id);
      } catch (_) {
        // Non-fatal — the web player also tracks its own progress server-side.
      }
    }
  }

  Future<void> _goTo(int index) async {
    await _markCurrentComplete();
    setState(() => _index = index);
    await _loadTicket();
  }

  Future<void> _close() async {
    await _markCurrentComplete();
    ref.invalidate(courseLecturesProvider(widget.courseId));
    ref.invalidate(myCoursesProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final (section, lecture) = _current;
    final l10n = AppLocalizations.of(context)!;
    final fg = Theme.of(context).textTheme.bodyMedium?.color;
    final divider = Theme.of(context).dividerColor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _close,
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${section.title} · ${localizedDigits(context, _index + 1)}/${localizedDigits(context, _flat.length)}',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.normal,
                  color: fg?.withValues(alpha: 0.55),
                ),
              ),
              Text(
                lecture.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (_bridgeUrl != null)
                    InAppWebView(
                      key: ValueKey(lecture.id),
                      initialUrlRequest: URLRequest(url: WebUri(_bridgeUrl!)),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        thirdPartyCookiesEnabled: true,
                      ),
                      onLoadStart: (controller, url) {
                        if (mounted) setState(() => _isWebLoading = true);
                      },
                      onLoadStop: (controller, url) {
                        if (mounted) setState(() => _isWebLoading = false);
                      },
                    ),
                  if (_isLoadingTicket || _isWebLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
            if (_hasNext)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: divider, width: 2)),
                ),
                child: InkWell(
                  onTap: () => _goTo(_index + 1),
                  child: Row(
                    children: [
                      Text(
                        '${l10n.upNext}: ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: fg?.withValues(alpha: 0.55),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _flat[_index + 1].$2.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                      Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: fg?.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: divider, width: 2)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (_hasPrev)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _goTo(_index - 1),
                          child: const Icon(Icons.skip_previous_rounded, size: 20),
                        ),
                      ),
                    if (_hasPrev) const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_hasNext) {
                            await _goTo(_index + 1);
                          } else {
                            await _close();
                          }
                        },
                        child: Text(
                          _hasNext ? l10n.markCompleteNext : l10n.finishLecture,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
