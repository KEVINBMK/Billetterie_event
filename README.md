## Billetterie Événementielle – Projet Flutter

Application mobile de billetterie événementielle réalisée dans le cadre du cours de **programmation mobile** (Android Studio / Flutter).

L’objectif est de permettre à des utilisateurs de **découvrir des événements**, **acheter des billets** et à des **organisateurs** de gérer leurs événements et leurs ventes.

---

## Équipe

- **Kevin** – Lead technique / architecture, intégration globale.
- **Melvin** – Back-end Flutter (services, modèles, intégration API / base locale).
- **Jonathan** – Front-end “utilisateur” (parcours d’achat, liste/détail événements).
- **Dieuvie** – Front-end “organisateur / admin” (dashboard, gestion événements).
- **Chris** – UX/UI (maquettes, design système) & tests fonctionnels.

---

## Fonctionnalités prévues (MVP)

- **Authentification & rôles**
  - Connexion / inscription utilisateur.
  - Rôles de base : participant, organisateur (admin simple optionnel).

- **Gestion des événements**
  - Création / édition / suppression d’un événement (titre, description, date, lieu, image, capacité, prix).
  - Liste des événements disponibles.
  - Détail d’un événement avec informations complètes.

- **Billets & réservations**
  - Achat / réservation de billets pour un événement.
  - Limitation par capacité (plus de billets si complet).
  - Génération d’un billet (code/QR code affiché dans l’appli).

- **Tableau de bord organisateur**
  - Voir les événements créés.
  - Voir le nombre de billets vendus par événement.

Selon le temps du projet, des fonctionnalités bonus pourront être ajoutées (scan de QR code à l’entrée, favoris, filtres avancés, etc.).

---

## Stack technique

- **Langage** : Dart
- **Framework** : Flutter
- **Backend** : Firebase (Auth, Firestore)
- **Plateformes** : Android, **Web**, iOS si besoin.
- **Gestion d’état** : Provider
- **Thème** : LikitaEvent (bleu / rouge / fond crème)

---

## Structure prévue de l’application

Organisation indicative des dossiers Flutter :

- `lib/`
  - `main.dart` – point d’entrée de l’application.
  - `core/` – thèmes, styles, widgets communs, constantes.
  - `features/`
    - `auth/` – écrans de login/inscription, services d’authentification.
    - `events/` – liste/détail événements, modèles et services associés.
    - `tickets/` – billets de l’utilisateur, génération/affichage du ticket.
    - `dashboard/` – écrans organisateur (gestion d’événements, stats simples).

Cette structure pourra évoluer avec l’avancement du projet.

---

## Installation & lancement

1. **Prérequis**
   - Flutter SDK installé.
   - Android Studio installé et configuré (SDK, émulateur ou téléphone physique).

2. **Cloner le projet**

```bash
git clone https://github.com/KEVINBMK/Billetterie_event.git
cd Billetterie_event
```

3. **Installer les dépendances**

```bash
flutter pub get
```

4. **Lancer l’application**

- **Android / iOS** :
```bash
flutter run
```

- **Web** (navigateur) :
```bash
flutter run -d chrome
```

5. **Build production Web**

```bash
flutter build web
```

Les fichiers générés sont dans `build/web/`. Tu peux les héberger sur Firebase Hosting, GitHub Pages, etc.

---

## Organisation du travail

- Utilisation de branches par fonctionnalité (ex. `feature/auth`, `feature/events-list`, etc.).
- Revue de code minimale par un autre membre lorsque possible.
- Petites itérations avec un flux fonctionnel complet prioritaire :
  1. Auth simple + liste/détail événements.
  2. Achat / génération de billet.
  3. Dashboard organisateur et améliorations UX/UI.

---

## Roadmap (à adapter pendant le projet)

- **Sprint 1**
  - Initialisation projet Flutter.
  - Authentification basique.
  - Création et affichage simple des événements.

- **Sprint 2**
  - Achat / réservation de billets.
  - Affichage des billets de l’utilisateur.

- **Sprint 3**
  - Dashboard organisateur (statistiques simples).
  - Améliorations UX/UI et corrections de bugs.

---

## Remarques pour l’enseignant

Ce projet vise à montrer :

- La capacité à structurer une application Flutter en fonctionnalités claires.
- La mise en pratique de concepts de programmation mobile (navigation, formulaires, persistance, etc.).
- Le travail collaboratif (répartition des rôles, Git, revues de code).

