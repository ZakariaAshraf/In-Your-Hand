String getCharacterAssetPath(String characterId) {
  switch (characterId) {
    case 'male_busi':
      return "assets/icons/mbusi.png";
    case 'female_busi':
      return "assets/icons/fbusi.png";
    default:
      return "assets/icons/icon.png"; // صورة احتياطية
  }
}