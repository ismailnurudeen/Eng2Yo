class Utils {
  static final audioApiEndpoint =
      "https://gentle-falls-68008.herokuapp.com/api/v1/names";
  static String getAudioEndpoint(String word) => "$audioApiEndpoint/$word";
}
