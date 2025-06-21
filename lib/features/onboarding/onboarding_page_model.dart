class OnboardingPageModel {
  final String title;
  final String description;
  final String? imageAsset;
  final String? lottieAsset;

  OnboardingPageModel({
    required this.title,
    required this.description,
    this.imageAsset,
    this.lottieAsset,
  });
}