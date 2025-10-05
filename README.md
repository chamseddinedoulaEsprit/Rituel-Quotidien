# 🎯 Rituel Quotidien - Suivi des Habitudes

Application mobile **Flutter** pour développer et maintenir de bonnes habitudes quotidiennes (sport, lecture, hydratation, sommeil, etc.).

---

## ✨ Fonctionnalités

### 📝 Gestion des Habitudes

* Création d'habitudes personnalisées avec nom, icône et couleur
* Définition de la fréquence (quotidienne ou hebdomadaire)
* Modification et suppression des habitudes existantes
* Organisation par catégories

### 📊 Suivi Visuel

* Calendrier interactif avec cases cochées
* Système de streaks (séries de jours consécutifs)
* Progression mensuelle avec graphiques
* Vue d'ensemble quotidienne

### 📈 Statistiques Détaillées

* Nombre de jours consécutifs (streak actuel)
* Taux de réussite global
* Historique des 30 derniers jours
* Graphiques de progression mensuelle
* Meilleur streak atteint

### 🎮 Gamification

* Système de points (10 points par habitude complétée)
* Niveaux progressifs (Débutant → Expert)
* Badges de réussite :

  * 🔥 Première Flamme (7 jours consécutifs)
  * ⚡ Éclair (30 jours consécutifs)
  * 💎 Diamant (100 jours consécutifs)
  * 🎯 Perfectionniste (100% sur 30 jours)

### 🔔 Notifications

* Rappels quotidiens personnalisables
* Configuration de l'heure de notification
* Gestion des permissions système

### 👤 Profil Utilisateur

* Avatar personnalisable
* Statistiques globales
* Affichage des badges obtenus
* Niveau et points cumulés

---

## 🚀 Installation

### 🔹 Prérequis

* Flutter SDK (>=3.0.0)
* Dart SDK (>=3.0.0)
* Android Studio / Xcode pour l’émulation

### 🔹 Installation des dépendances

```bash
flutter pub get
```

### 🔹 Lancement de l'application

```bash
flutter run
```

---

## 📱 Plateformes Supportées

* ✅ Android
* ✅ iOS
* ✅ Web

---

## 🛠️ Technologies Utilisées

### Framework

* **Flutter** – Framework UI cross-platform
* **Dart** – Langage de programmation

### Packages Principaux

* `shared_preferences` – Stockage local des données
* `table_calendar` – Calendrier interactif
* `fl_chart` – Graphiques et statistiques
* `flutter_local_notifications` – Notifications locales
* `timezone` – Gestion des fuseaux horaires
* `image_picker` – Sélection d’images (avatar)

---

## 📂 Architecture du Projet

```
lib/
├── main.dart                      # Point d'entrée
├── theme.dart                     # Configuration du thème
├── models/                        # Modèles de données
│   ├── user.dart
│   ├── habit.dart
│   └── habit_completion.dart
├── screens/                       # Écrans principaux
│   ├── home_screen.dart
│   ├── statistics_screen.dart
│   ├── profile_screen.dart
│   └── habit_form_screen.dart
├── services/                      # Logique métier
│   ├── user_service.dart
│   ├── habit_service.dart
│   ├── completion_service.dart
│   └── notification_service.dart
└── widgets/                       # Composants réutilisables
    └── habit_card.dart
```

---

## 🎨 Design

### Palette de Couleurs

* Primary : Indigo (#3F51B5)
* Secondary : Amber (#FFC107)
* Success : Green (#4CAF50)
* Warning : Orange (#FF9800)
* Error : Red (#F44336)

### Navigation

* **Bottom Navigation Bar** avec 3 onglets :

  * 🏠 Accueil (liste des habitudes)
  * 📊 Statistiques
  * 👤 Profil

---

## 💾 Stockage des Données

L’application utilise **SharedPreferences** pour le stockage local :

* Données utilisateur (profil, avatar, points, niveau)
* Liste des habitudes
* Historique des complétions
* Préférences de notifications

### Format des Données

* Sérialisées en JSON pour simplifier le stockage et la récupération

---

## 🔔 Configuration des Notifications

### Android

Permissions dans `android/app/src/main/AndroidManifest.xml` :

* `POST_NOTIFICATIONS` (Android 13+)
* `RECEIVE_BOOT_COMPLETED`
* `SCHEDULE_EXACT_ALARM`

### iOS

Permissions dans `ios/Runner/Info.plist` avec descriptions appropriées.

---

## 📈 Fonctionnement du Système de Gamification

### Points

* 10 points par habitude complétée
* Accumulation quotidienne
* Historique conservé

### Niveaux

* Débutant : 0–99 points
* Intermédiaire : 100–499 points
* Avancé : 500–999 points
* Expert : 1000+ points

### Badges

Déblocage automatique selon critères :

* Analyse quotidienne des streaks
* Vérification du taux de complétion
* Notification lors du déblocage

---

## 🤝 Contribution

Les contributions sont les bienvenues !

1. Fork le projet
2. Crée une branche (`git checkout -b feature/amelioration`)
3. Commit tes changements (`git commit -m 'Ajout fonctionnalité'`)
4. Push vers la branche (`git push origin feature/amelioration`)
5. Ouvre une Pull Request

---

## 📄 Licence

Ce projet est sous licence **MIT**.

---

## 👨‍💻 Auteur

Développé avec ❤️ en **Flutter**

---

## 🐛 Rapport de Bugs

Merci d’ouvrir une issue avec :

* Description du problème
* Étapes pour reproduire
* Version Flutter utilisée
* Plateforme (Android/iOS/Web)

---

## 🗺️ Roadmap (Fonctionnalités Futures Possibles)

* Synchronisation cloud (Firebase / Supabase)
* Mode sombre personnalisable
* Partage de progression sur réseaux sociaux
* Défis communautaires
* Rappels intelligents basés sur l’IA
* Export des données (CSV/PDF)
* Widgets home screen
* Apple Watch / Wear OS support

---

## 📞 Support

Pour toute question ou assistance, ouvrez une issue sur GitHub.

---

🔒 **Note :** L’application fonctionne **entièrement hors ligne**. Aucune connexion internet n’est requise.
