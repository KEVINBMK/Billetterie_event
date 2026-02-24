## 🎟️ Billetterie Événementielle – Projet Flutter (L4 LMD)

Application mobile de billetterie événementielle réalisée dans le cadre du cours de **programmation mobile**. Ce projet constitue l'examen final et sera défendu en groupe.

Notre objectif : concevoir une application complète, fonctionnelle et bien architecturée, permettant à des **participants** de découvrir des événements et d'acheter des billets, et à des **organisateurs** de gérer leurs événements et leurs ventes.

---

## 🧑‍💻 Équipe et Rôles

| Membre | Rôle Principal | Responsabilités Clés |
| :--- | :--- | :--- |
| **Kevin** | Lead Technique / Architecture | Structure du projet, intégration Firebase (Auth, Firestore), coordination, respect du pattern MVC, gestion d'état (Provider). |
| **Melvin** | Back-end Flutter & Intégrations | Création des modèles (`/models`), services (`/services`), intégration de **l'API Labyrinthe** pour les paiements Mobile Money, logique métier des controllers. |
| **Jonathan** | Front-end "Participant" | Parcours d'achat sans compte, formulaire d'informations participant, liste et détail des événements, génération et affichage du QR code. |
| **Dieuvie** | Front-end "Organisateur / Admin" | Tableau de bord organisateur (statistiques, liste des participants), gestion des événements (CRUD), interface Super Admin (gestion des organisateurs). |
| **Chris** | UX/UI Designer & Tests | Maquettes, design système cohérent, feedbacks visuels (loaders, Snackbars), tests fonctionnels, accessibilité. |

---

## ✅ Fonctionnalités Détaillées (MVP)

Notre MVP est pensé pour répondre aux critères de l'examen tout en offrant une expérience utilisateur complète.

### 1. Authentification & Gestion des Rôles
- **Inscription/Connexion** : Réservée aux **Organisateurs** et au **Super Admin** (email/mot de passe + Google).
- **Super Admin** (vous) :
  - Créer, modifier, désactiver des comptes **organisateurs**.
  - Vue globale sur **tous les événements**.
  - Pouvoir de **supprimer** un événement ou un organisateur problématique.
- **Participant** : Aucun compte requis pour acheter un billet.

### 2. Gestion des Événements
- **CRUD complet pour l'Organisateur** sur ses propres événements.
- Champs d'un événement : Titre, Description, Date, Lieu, Image (Firebase Storage), **Capacité maximale**, **Prix** (0 = gratuit).
- **Visibilité** :
  - Participant : agenda public de **tous** les événements.
  - Organisateur : voit uniquement ses événements.
  - Super Admin : voit **tous** les événements.

### 3. Parcours d'Achat Participant (Sans Compte)
1.  **Découverte** : Parcours de l'agenda, filtres, page de détail d'un événement.
2.  **Réservation** : Clic sur "Acheter un billet".
3.  **Formulaire d'informations** : Saisie des données personnelles (nom, email, téléphone). **Ces données seront visibles uniquement par l'organisateur de l'événement.**
4.  **Paiement (si événement payant)** :
    *   Intégration de l'**API Labyrinthe** pour initier une transaction Mobile Money.
    *   Gestion de la confirmation de paiement (callback/webhook).
5.  **Confirmation** : Réservation enregistrée en base, capacité de l'événement mise à jour.

### 4. Billets et Génération de QR Code
- Après confirmation de la commande (paiement réussi ou gratuité), **génération automatique d'un QR code** unique (contenant l'ID de réservation).
- Affichage du billet avec QR code dans l'application.
- Option d'**impression/téléchargement** du billet.

### 5. Tableau de Bord Organisateur
- Liste de ses événements avec indicateurs : 📊 **billets vendus / capacité totale**.
- Accès à la **liste des participants** pour chaque événement (données fournies lors de l'achat).

### 6. Fonctionnalités Bonus (Selon le temps)
- Scan de QR code à l'entrée (pour l'organisateur).
- Ajout d'événements aux favoris.
- Filtres avancés (par date, lieu, catégorie, prix).

---

## 🛠️ Stack Technique

| Composant | Technologie / Outil | Justification |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart) | Cross-platform, performant, imposé par le cours. |
| **Backend & Auth** | Firebase (Auth, Firestore, Storage) | Temps réel, facile à intégrer, répond aux critères de l'examen. |
| **Paiement** | API Labyrinthe | Intégration Mobile Money locale (RDC). |
| **Gestion d'état** | Provider | Simple, recommandé, parfait pour séparer UI et logique. |
| **QR Code** | `qr_flutter` | Génération facile de QR codes. |
| **Architecture** | Pattern MVC | `/models`, `/views`, `/controllers`, `/services` proprement séparés. |
| **Versionning** | Git | Travail collaboratif, évaluation des contributions. |

---

## 🗂️ Structure du Projet (Architecture MVC)

```
lib/
├── main.dart # Point d'entrée, configuration Provider
│
├── models/ # Classes de données (DTOs)
│ ├── user_model.dart
│ ├── event_model.dart
│ └── reservation_model.dart
│
├── views/ (ou screens/) # Interfaces utilisateur
│ ├── auth/
│ │ ├── login_screen.dart
│ │ └── register_screen.dart
│ ├── participant/
│ │ ├── home_screen.dart # Agenda public
│ │ ├── event_detail_screen.dart
│ │ └── ticket_confirmation_screen.dart
│ ├── organizer/
│ │ ├── dashboard_screen.dart
│ │ ├── manage_events_screen.dart
│ │ └── participants_list_screen.dart
│ └── admin/
│ └── manage_organizers_screen.dart
│
├── controllers/ # Logique métier (ChangeNotifier)
│ ├── auth_controller.dart
│ ├── event_controller.dart
│ └── reservation_controller.dart
│
└── services/ # Services externes
├── firebase_auth_service.dart
├── firestore_service.dart
├── labyrinthe_api_service.dart # Paiement Mobile Money
└── qr_code_service.dart

```

---

## 🚀 Installation et Lancement

### Prérequis
- Flutter SDK (dernière version stable)
- Android Studio / VS Code avec plugins Flutter/Dart
- Émulateur Android ou appareil physique
- Compte Firebase (pour la configuration)

### Étapes

1.  **Cloner le dépôt**
    ```bash
    git clone https://github.com/KEVINBMK/Billetterie_event.git
    cd Billetterie_event
    ```

2.  **Configuration Firebase**
    *   Créez un projet sur la [console Firebase](https://console.firebase.google.com/).
    *   Activez **Authentication** (Email/Mot de passe + Google).
    *   Créez une base de données **Firestore** (mode test au début).
    *   Activez **Storage** pour les images.
    *   Téléchargez le fichier `google-services.json` (Android) et placez-le dans `android/app/`.

3.  **Installer les dépendances**
    ```bash
    flutter pub get
    ```

4.  **Lancer l'application**
    ```bash
    flutter run
    ```

---

## 🤝 Organisation du Travail et Git

### Flux de travail
- **Branche principale** : `main` (protégée, code stable).
- **Branches de développement** : `dev` (intégration continue).
- **Branches par fonctionnalité** : `feature/nom-de-la-fonctionnalite` (ex: `feature/auth`, `feature/paiement`).
- **Revues de code** : Chaque merge dans `dev` doit être validé par au moins un autre membre.

### Conventions de Commits
Nous utilisons des messages clairs pour faciliter le suivi :
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Mise à jour de la documentation (comme ce README !)
- `refactor:` Amélioration du code sans changer le comportement
- `style:` Changements liés au formatage (indentation, etc.)

**Exemple** : `feat: ajout du formulaire d'informations participant`

---

## 📅 Roadmap Prévisionnelle

| Sprint | Objectifs Principaux | Livrables |
| :--- | :--- | :--- |
| **Sprint 1** (Setup) | Initialisation projet, Firebase Auth, structure MVC, 1er écran (liste événements). | Base de code fonctionnelle, authentification. |
| **Sprint 2** (Cœur métier) | Détail événement, parcours d'achat (formulaire, check capacité), génération de QR code. | Un participant peut acheter un billet (gratuit). |
| **Sprint 3** (Paiement) | Intégration API Labyrinthe, gestion des événements payants, webhook de confirmation. | Paiement Mobile Money fonctionnel. |
| **Sprint 4** (Organisateur) | Dashboard organisateur, gestion des événements (CRUD), liste des participants. | L'organisateur peut gérer ses events et voir ses ventes. |
| **Sprint 5** (Admin & Finalisation) | Interface Super Admin, polish UI/UX, tests, documentation finale (README). | Application prête pour la soutenance. |

---

## 📝 Remarques pour l'Évaluateur

Ce projet vise à démontrer :
- ✅ La maîtrise du **pattern MVC** et d'une architecture propre.
- ✅ L'utilisation complète de **Firebase** (Auth, Firestore CRUD, Storage).
- ✅ L'intégration d'une **API externe** (Labyrinthe pour les paiements).
- ✅ Une **gestion d'état** efficace avec **Provider**.
- ✅ Une **expérience utilisateur** soignée (feedbacks visuels, QR code, etc.).
- ✅ Un **travail d'équipe** structuré et visible via Git.

**Toute démarcation (design soigné, fonctionnalités bonus) sera valorisée.**

---

**Bonne chance à toute l'équipe ! 🚀**