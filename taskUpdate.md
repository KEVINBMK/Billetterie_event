# Billetterie Événementielle - Application Mobile Flutter

Application mobile de billetterie événementielle développée dans le cadre du cours de programmation mobile (L4 LMD).

Ce projet respecte les contraintes techniques imposées (Firebase, MVC, Provider, API externe) et implémente une gestion avancée des rôles avec intégration de paiement mobile.

---

## Équipe et rôles

| Membre | Rôle principal | Responsabilités clés |
| --- | --- | --- |
| Kevin | Lead technique / Architecture | Structure du projet, intégration globale, choix techniques, coordination, repository Git |
| Melvin | Back-end Flutter & Services | Modèles de données, services Firebase (Auth, Firestore), intégration API Labyrinthe, logique métier |
| Jonathan | Front-end Participant | Parcours visiteur (agenda public, détail événement), processus d'achat et réservation |
| Dieuvie | Front-end Organisateur / Admin | CRUD événements, tableau de bord organisateur, interface super admin (modération) |
| Chris | UX/UI Designer & Tests | Maquettes, design system, composants réutilisables, tests fonctionnels, feedback utilisateur |

---

## Fonctionnalités du MVP (Minimum Viable Product)

### 1. Authentification et gestion des rôles

- Inscription / connexion (email + Google) via Firebase Auth.
- Profils pris en charge :
  - **Super Admin** : vue globale sur la plateforme. Peut supprimer (modération) tout organisateur ou événement, mais ne peut pas modifier les événements des organisateurs.
  - **Organisateur** : doit créer un compte pour gérer ses événements et suivre ses ventes.
  - **Visiteur / Participant** : sans compte. Peut consulter l'agenda et acheter des billets.

### 2. Gestion des événements (Organisateur)

- CRUD complet sur ses événements.
- Champs événement :
  - Titre
  - Description
  - Date
  - Lieu
  - Image (upload)
  - Capacité maximale
  - Prix (gratuit ou payant)
- Visualisation du nombre de billets vendus.

### 3. Parcours Participant (sans compte)

- Agenda public (liste de tous les événements).
- Filtres de base (date, lieu, catégorie en bonus).
- Page de détail événement.
- Processus d'achat :
  - Formulaire d'informations personnelles.
  - Si payant : paiement Mobile Money via API Labyrinthe RDC.
  - Si gratuit : confirmation immédiate.
- Génération d'un billet unique avec QR code.
- Affichage du billet + possibilité d'impression.
- Données visibles uniquement par l'organisateur concerné.

### 4. Tableau de bord Organisateur

- Liste de ses événements.
- Nombre de billets vendus.
- Liste des participants.
- Modification / suppression rapide.

### 5. Administration (Super Admin)

- Vue globale organisateurs + événements.
- Pouvoir de suppression (modération).
- Pas de modification des événements.

---

## Stack technique

| Composant | Technologie |
| --- | --- |
| Langage | Dart |
| Framework | Flutter |
| Backend | Firebase (Auth, Firestore, Storage) |
| Auth | Firebase Auth (Email + Google) |
| Base de données | Cloud Firestore |
| Gestion d'état | Provider (ou Riverpod) |
| Paiement | API REST Labyrinthe RDC |
| QR Code | `qr_flutter` |
| Images | Firebase Storage |
| Versionnement | Git |

---

## Structure du projet (Architecture MVC)

```text
lib/
|-- main.dart
|-- core/
|   |-- constants/
|   |-- theme/
|   `-- widgets/
|-- models/
|-- views/
|   |-- auth/
|   |-- public/
|   |-- participant/
|   |-- organizer/
|   `-- admin/
|-- controllers/
|   |-- auth_controller.dart
|   |-- event_controller.dart
|   |-- reservation_controller.dart
|   `-- ...
`-- services/
    |-- firebase_auth_service.dart
    |-- firestore_service.dart
    |-- labyrinthe_payment_service.dart
    `-- external_api_service.dart
```

---

## Installation et lancement

### Prérequis

- Flutter SDK (dernière version stable).
- Android Studio ou VS Code.
- Compte Firebase.

### 1. Cloner le dépôt

```bash
git clone https://github.com/KEVINBMK/Billetterie_event.git
cd Billetterie_event
```

### 2. Configurer Firebase

- Créer un projet Firebase.
- Ajouter l'application Android.
- Télécharger `google-services.json`.
- Placer le fichier dans `android/app/`.
- Activer :
  - Authentication (Email + Google)
  - Firestore
  - Storage

### 3. Installer les dépendances

```bash
flutter pub get
```

### 4. Lancer l'application

```bash
flutter run
```

---

## Organisation Git

- Branche principale : `main`
- Branches fonctionnalités : `feature/nom-feature`

### Workflow

1. Créer une branche depuis `main`.
2. Développer la fonctionnalité.
3. Commits fréquents.
4. Ouvrir une Pull Request.
5. Merge après validation.

### Convention de commits

- `feat`: nouvelle fonctionnalité
- `fix`: correction de bug
- `docs`: documentation
- `refactor`: refactorisation
- `style`: UI
- `chore`: tâches techniques

---

## Roadmap

### Sprint 1 - Fondations

- Init Flutter + Git
- Config Firebase
- Auth Email + Google
- Modèles de données
- Liste des événements
- Setup Provider

### Sprint 2 - Coeur métier

- CRUD événements
- Détail événement
- Formulaire achat
- QR Code
- Dashboard organisateur
- API Labyrinthe (base)

### Sprint 3 - Paiement et finalisation

- Intégration paiement complet
- Gestion gratuit / payant
- Interface super admin
- Design system
- Tests et corrections
- Documentation finale
- Préparation soutenance

### Sprint 4 - Bonus

- Scan QR code
- Filtres avancés
- Favoris (local storage)
- Notifications (Firebase Cloud Messaging)
