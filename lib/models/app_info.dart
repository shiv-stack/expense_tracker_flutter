class AppInfo {
  final String name;
  final String description;
  final String iconAsset;
  final String storeUrl;

  const AppInfo({
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.storeUrl,
  });
}

final List<AppInfo> myApps = const [
  AppInfo(
    name: "CaloriAI",
    description: 'CaloriAI is a smart calorie tracker that helps you manage your diet and nutrition effectively.',
    iconAsset: 'assets/appIcons/calorie.png',
    storeUrl: "https://play.google.com/store/apps/details?id=com.tushar.calori_ai",
  ),
  AppInfo(
    name: 'QuizVeda',
    description: 'QuizVeda is a fun and educational quiz app that tests your knowledge on various topics.',
    iconAsset: 'assets/appIcons/quiz.png',
    storeUrl: 'https://play.google.com/store/apps/details?id=com.tushar.quiz_app',
  ),
];
