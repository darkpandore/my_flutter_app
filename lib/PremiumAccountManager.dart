class PremiumAccountManager {
  // Liste des utilisateurs Premium
  List<String> premiumUsers = ["shirley2505", "brunetsabrina37", "Vinted"];

  // Méthode pour vérifier si un utilisateur fait partie des comptes Premium
  bool isPremiumUser(String username) {
    return premiumUsers.any((premiumUser) => premiumUser.toLowerCase() == username.toLowerCase());
    // Retourne true si l'utilisateur est Premium, insensible à la casse
  }

  // Méthode pour ajouter un utilisateur à la liste Premium (facultatif)
  void addPremiumUser(String username) {
    if (!premiumUsers.any((premiumUser) => premiumUser.toLowerCase() == username.toLowerCase())) {
      premiumUsers.add(username);
    }
  }

  // Méthode pour supprimer un utilisateur de la liste Premium (facultatif)
  void removePremiumUser(String username) {
    premiumUsers.removeWhere((premiumUser) => premiumUser.toLowerCase() == username.toLowerCase());
  }
}
