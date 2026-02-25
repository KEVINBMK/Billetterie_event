# Répartition des contributions – LikitaEvent

Ce document indique **les dossiers et parties du projet** attribués à chaque contributeur pour la soutenance / le rendu du projet.

---

## Kevin – Lead technique / Architecture

- **`lib/main.dart`** – Point d’entrée, configuration des providers (Auth, Firestore, Paiement), thème, routeur
- **`lib/app_router.dart`** – Routes nommées, redirections (dashboard, login), configuration GoRouter
- **`lib/core/constants/`** – Constantes applicatives (`app_constants.dart`, `api_constants.dart`)
- **`android/`** – Configuration Android (build, `local.properties`, `google-services.json`)
- **`web/`** – Configuration web (index.html, Firebase, manifest)
- **`firebase.json`**, **`.firebaserc`** – Déploiement Firebase Hosting
- **Repository Git** – Branches, coordination, revues de code

---

## Melvin – Back-end Flutter & Services

- **`lib/core/services/firebase_auth_service.dart`** – Authentification Firebase (email/mot de passe), gestion des sessions
- **`lib/core/services/firestore_service.dart`** – Accès Firestore (événements, réservations, billets), création de tickets, requêtes
- **`lib/core/services/labyrinthe_payment_service.dart`** – Intégration API Labyrinthe (paiement Mobile Money)
- **`lib/core/state/auth_state.dart`** – État d’authentification (Provider), rôles (organisateur, admin)
- **`lib/core/models/event.dart`** – Modèle de données Événement
- **`lib/core/models/ticket.dart`** – Modèle de données Billet / Réservation
- **`lib/core/models/likita_user.dart`** – Modèle utilisateur et rôles

---

## Jonathan – Front-end Participant

- **`lib/features/events/events_screens.dart`** – Liste des événements (agenda public)
- **`lib/features/events/event_detail_screen.dart`** – Détail d’un événement, bouton « Acheter un billet »
- **`lib/features/events/checkout_screen.dart`** – Formulaire d’achat (nom, email, quantité, téléphone si payant), appel paiement puis création du billet
- **`lib/features/tickets/my_tickets_screen.dart`** – Écran « Mes billets » (liste des billets par email)
- **`lib/features/tickets/ticket_qr_screen.dart`** – Affichage du billet avec QR code
- **`lib/features/home/home_screen.dart`** – Page d’accueil (hero, cartes, liens vers événements et app)

---

## Dieuvie – Front-end Organisateur / Admin

- **`lib/features/dashboard/organizer_dashboard_screen.dart`** – Tableau de bord organisateur (stats, liste des événements, modifier/supprimer)
- **`lib/features/dashboard/organizer_event_form_screen.dart`** – Création et édition d’un événement (CRUD)
- **`lib/features/dashboard/scan_ticket_screen.dart`** – Scan des billets (QR / saisie manuelle) pour l’organisateur (web + mobile)

---

## Chris – UX/UI Designer & Tests

- **`lib/core/theme/likita_theme.dart`** – Thème global (couleurs, typo, composants Material)
- **`lib/core/widgets/likita_app_bar.dart`** – AppBar avec logo LikitaEvent
- **`lib/core/widgets/likita_nav_bar.dart`** – Barre de navigation (liens Accueil, Événements, Mes billets, Dashboard, Connexion)
- **`lib/core/widgets/responsive_scaffold.dart`** – Scaffold responsive (largeur max, mise en page)
- **`lib/features/auth/login_register_screens.dart`** – Écrans de connexion et d’inscription (UI, champs, boutons)
- **`docs/`** – Maquettes et documents de design (ex. `LikitaEvent_Maquettes_Soutenance_Fix.pdf`)

---

## Fichiers partagés / transverses

- **`lib/firebase_options.dart`** – Généré par FlutterFire CLI (config Firebase par plateforme)
- **`pubspec.yaml`** – Dépendances du projet (définies avec Kevin, utilisées par toute l’équipe)

---

*Document à utiliser pour la soutenance ou le rendu afin de montrer la répartition du travail par contributeur.*
