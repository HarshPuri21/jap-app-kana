import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../services/route_observer.dart';
import '../theming/theme_scope.dart';
import '../theming/theme_tokens.dart';
import '../widgets/app_background.dart';
import '../widgets/mode_card.dart';
import '../widgets/themed/themed_motion.dart';
import '../widgets/themed/themed_controls.dart';
import '../widgets/themed/themed_surface.dart';
import 'sentence_mode_screen.dart';
import 'kanji_mode_screen.dart';
import 'flashcard_screen.dart';
import 'test_setup_screen.dart';
import 'settings_screen.dart';
import 'daily_review_screen.dart';
import 'radical_list_screen.dart';
import 'radical_quiz_screen.dart';
import 'kana_mode_screen.dart';
import 'kana_quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    // Covers the very first appearance (app launch) -- subsequent returns
    // from a lesson screen are covered by didPopNext below, since popping
    // back to an already-built screen does not re-run initState.
    context.read<AudioService>().ensureMenuMusicPlaying();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // We're visible again after a pushed screen (a lesson, settings, etc.)
    // was popped off -- resume the menu music if it isn't already playing.
    context.read<AudioService>().ensureMenuMusicPlaying();
  }

  void _openScreen(Widget screen) {
    context.read<AudioService>().playMenuClick();
    Navigator.of(context).push(themedRoute(context, (_) => screen));
  }

  /// Calm, distinguishable hues for the learning modes, derived from the
  /// active theme so they change with it rather than being hard-coded.
  List<Color> _modeHues(ThemeTokens t) => [
        t.colors.accent,
        Color.lerp(t.colors.accent, const Color(0xFF6366F1), 0.55)!,
        t.colors.good,
        Color.lerp(t.colors.accent, t.colors.good, 0.5)!,
        t.colors.warn,
        Color.lerp(t.colors.warn, t.colors.bad, 0.35)!,
        Color.lerp(t.colors.accent, t.colors.warn, 0.5)!,
        Color.lerp(t.colors.good, t.colors.accent, 0.4)!,
      ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final settings = context.watch<SettingsService>();
    final progress = context.watch<ProgressService>();
    final answered = settings.statsAnsweredTotal;
    final correct = settings.statsCorrectTotal;
    final pct = answered == 0 ? null : (100 * correct / answered).round();
    final queueSize = progress.todayQueueSize;
    final hues = _modeHues(t);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    t.spacing.gutter,
                    t.spacing.xs,
                    t.spacing.gutter,
                    t.spacing.xl,
                  ),
                  children: [
                    if (pct != null) ...[
                      _AccuracyStrip(
                        correct: correct,
                        answered: answered,
                        pct: pct,
                      ),
                      SizedBox(height: t.spacing.md),
                    ],
                    _ReviewBanner(
                      queueSize: queueSize,
                      onTap: () => _openScreen(const DailyReviewScreen()),
                    ),
                    SizedBox(height: t.spacing.xl),
                    const ThemedSectionLabel('Practice'),
                    ModeCard(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Learn Sentences',
                      subtitle: '320 example sentences, easy → hard',
                      accentColor: hues[0],
                      onTap: () => _openScreen(const SentenceModeScreen()),
                    ),
                    SizedBox(height: t.spacing.sm),
                    ModeCard(
                      icon: Icons.brush_outlined,
                      title: 'Learn Kanji',
                      subtitle: '536 kanji with readings & breakdowns',
                      accentColor: hues[1],
                      onTap: () => _openScreen(const KanjiModeScreen()),
                    ),
                    SizedBox(height: t.spacing.sm),
                    ModeCard(
                      icon: Icons.style_outlined,
                      title: 'Flashcards',
                      subtitle: 'Swipe through vocab & kanji',
                      accentColor: hues[2],
                      onTap: () => _openScreen(const FlashcardScreen()),
                    ),
                    SizedBox(height: t.spacing.sm),
                    ModeCard(
                      icon: Icons.category_outlined,
                      title: 'Radicals',
                      subtitle: '280 radicals — browse & search',
                      accentColor: hues[3],
                      onTap: () => _openScreen(const RadicalListScreen()),
                    ),
                    SizedBox(height: t.spacing.sm),
                    ModeCard(
                      icon: Icons.extension_outlined,
                      title: 'Radical Quiz',
                      subtitle: 'Match each radical to its meaning',
                      accentColor: hues[4],
                      onTap: () => _openScreen(const RadicalQuizScreen()),
                    ),
                    SizedBox(height: t.spacing.sm),
                    ModeCard(
                      icon: Icons.quiz_outlined,
                      title: 'Take a Test',
                      subtitle: 'Timed quiz with a final score',
                      accentColor: hues[5],
                      onTap: () => _openScreen(const TestSetupScreen()),
                    ),
                    SizedBox(height: t.spacing.sm),
                    ModeCard(
                      icon: Icons.translate,
                      title: 'Learn Kana',
                      subtitle: 'Hiragana & katakana, browsed by stage',
                      accentColor: hues[6],
                      onTap: () => _openScreen(const KanaModeScreen()),
                    ),
                    SizedBox(height: t.spacing.sm),
                    ModeCard(
                      icon: Icons.spellcheck,
                      title: 'Kana Quiz',
                      subtitle: 'Kana ↔ romaji, hiragana & katakana',
                      accentColor: hues[7],
                      onTap: () => _openScreen(const KanaQuizScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The masthead. Deliberately not a themed bar: on the home screen the
  /// title reads as printed onto the backdrop, with the surfaces beginning
  /// below it -- that contrast is what gives the cards their depth.
  Widget _buildHeader(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        t.spacing.gutter,
        t.spacing.md,
        t.spacing.sm,
        t.spacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '日本語トレーニング',
                  style: t.text
                      .jp(13, color: t.colors.textSecondary)
                      .copyWith(letterSpacing: 3),
                ),
                const SizedBox(height: 4),
                Text('Nihongo Trainer', style: t.text.display),
              ],
            ),
          ),
          SizedBox(width: t.spacing.xs),
          Padding(
            padding: EdgeInsets.only(top: 6, right: t.spacing.xs),
            child: ThemedIconButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onPressed: () => _openScreen(const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lifetime accuracy -- the same numbers as before, given somewhere calm.
class _AccuracyStrip extends StatelessWidget {
  final int correct;
  final int answered;
  final int pct;

  const _AccuracyStrip({
    required this.correct,
    required this.answered,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ThemedSurface(
      level: SurfaceLevel.subtle,
      radius: t.radii.md,
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.md,
        vertical: t.spacing.sm + 2,
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_outlined, color: t.colors.accent, size: 18),
          SizedBox(width: t.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Overall accuracy',
                  style: t.text.caption.copyWith(letterSpacing: 0.4),
                ),
                const SizedBox(height: 5),
                ThemedProgressBar(value: pct / 100, height: 5),
              ],
            ),
          ),
          SizedBox(width: t.spacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: t.text.title.copyWith(
                  color: t.colors.accent,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text('$correct / $answered', style: t.text.caption),
            ],
          ),
        ],
      ),
    );
  }
}

/// The prominent "what should I do today" entry point -- sits above the
/// regular mode list since it's the recommended daily habit, on the elevated
/// tier so it reads as the most forward surface on the screen.
class _ReviewBanner extends StatelessWidget {
  final int queueSize;
  final VoidCallback onTap;
  const _ReviewBanner({required this.queueSize, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hasReviews = queueSize > 0;
    final accent = hasReviews ? t.colors.accent : t.colors.good;

    return ThemedCard(
      onTap: onTap,
      level: SurfaceLevel.elevated,
      radius: t.radii.lg,
      padding: EdgeInsets.all(t.spacing.md + 2),
      tint: accent,
      tintStrength: hasReviews ? 0.9 : 0.5,
      semanticLabel: hasReviews
          ? 'Daily review, $queueSize items due'
          : 'Daily review, all caught up',
      child: Row(
        children: [
          ThemedIconPlate(
            icon: hasReviews ? Icons.bolt_rounded : Icons.check_rounded,
            color: accent,
            size: 54,
            iconSize: 26,
          ),
          SizedBox(width: t.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Daily Review', style: t.text.cardTitle),
                    ),
                    if (hasReviews)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.18),
                          borderRadius:
                              BorderRadius.circular(ThemeRadii.pill),
                          border: Border.all(color: accent.withOpacity(0.45)),
                        ),
                        child: Text(
                          '$queueSize due',
                          style: t.text.caption.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hasReviews
                      ? 'Vocab & kanji due for review, spaced just right'
                      : "You're all caught up — check back later",
                  style: t.text.secondary.copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
          SizedBox(width: t.spacing.xs),
          Icon(
            Icons.chevron_right_rounded,
            color: t.colors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }
}
