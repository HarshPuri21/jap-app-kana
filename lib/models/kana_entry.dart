/// One kana character -- hiragana or katakana, at any stage from the basic
/// 46 through extended katakana combinations for loanwords.
///
/// Mirrors [KanjiEntry]/[RadicalEntry] in shape (a plain data class with a
/// `fromJson` factory) so it slots into the same load/browse/quiz patterns
/// the rest of the app already uses.
class KanaEntry {
  final String character;

  /// Hepburn romaji. Empty for the sokuon (っ/ッ), which has no vowel sound
  /// of its own -- see [sound] for what it actually does.
  final String romaji;

  /// Short pronunciation/description. Usually equal to [romaji]; differs for
  /// entries where the romaji alone doesn't explain the sound (the sokuon,
  /// the moraic nasal).
  final String sound;

  /// 'hiragana' | 'katakana'
  final String type;

  /// 'basic' | 'dakuten' | 'handakuten' | 'yoon' | 'small' | 'special' |
  /// 'extended_katakana'
  final String group;

  final bool isSmall;

  /// The corresponding character in the other kana system (あ <-> ア), when
  /// one exists. Extended katakana combinations have no hiragana pair.
  final String? pairedKana;

  /// Usage note -- a particle-reading quirk, a duplicate-sound explanation,
  /// etc. Most entries have none.
  final String? notes;

  KanaEntry({
    required this.character,
    required this.romaji,
    required this.sound,
    required this.type,
    required this.group,
    required this.isSmall,
    required this.pairedKana,
    required this.notes,
  });

  factory KanaEntry.fromJson(Map<String, dynamic> json) {
    return KanaEntry(
      character: json['character'] as String,
      romaji: json['romaji'] as String,
      sound: json['sound'] as String,
      type: json['type'] as String,
      group: json['group'] as String,
      isSmall: json['isSmall'] as bool? ?? false,
      pairedKana: json['pairedKana'] as String?,
      notes: json['notes'] as String?,
    );
  }

  bool get isHiragana => type == 'hiragana';
  bool get isKatakana => type == 'katakana';
}

/// Display names for each kana group, in learning order. 'special' (ゔ/ヴ)
/// intentionally shares a label with 'small' -- the source material
/// presents them under one combined "small kana / special pronunciation"
/// heading, and splitting them into their own section would be one more
/// header for a single character.
const Map<String, String> kKanaGroupLabels = {
  'basic': 'Basic',
  'dakuten': 'Dakuten',
  'handakuten': 'Handakuten',
  'yoon': 'Yōon',
  'small': 'Small Kana & Pronunciation',
  'special': 'Small Kana & Pronunciation',
  'extended_katakana': 'Extended Katakana',
};
