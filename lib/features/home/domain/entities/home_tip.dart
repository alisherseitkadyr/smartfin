enum TipTheme { green, amber, blue, indigo }

class HomeTip {
  final int id;
  final String sectionCode;
  final String title;
  final String body;
  final String iconKey;
  final TipTheme theme;

  const HomeTip({
    required this.id,
    required this.sectionCode,
    required this.title,
    required this.body,
    required this.iconKey,
    required this.theme,
  });
}
