# Guide d'utilisation des composants backend – À lire par toute l'équipe

## 1. Introduction

Bonjour à tous ! 👋  
J’ai (Melvin) mis en place la base de l’application :  
- **Modèles** (`/models`) : classes `User`, `Event`, `Reservation`.  
- **Services** (`/services`) : communication avec Firebase (Auth, Firestore) et API Labyrinthe.  
- **Contrôleurs** (`/controllers`) : `AuthController`, `EventController`, `ReservationController` – ils exposent la logique métier et les données aux vues.  

Ces fichiers sont **stables** et **ne doivent pas être modifiés** sans mon accord.  
Si vous avez besoin d’une nouvelle fonctionnalité ou d’une modification, **contactez-moi d’abord**.

---

## 2. Structure des dossiers – Qui fait quoi ?

| Dossier | Responsable | Description |
|--------|------------|-------------|
| `lib/models/` | **Melvin** | Classes de données (ne pas toucher). |
| `lib/services/` | **Melvin** | Appels Firebase, API (ne pas toucher). |
| `lib/controllers/` | **Melvin** | Logique métier exposée aux vues (ne pas toucher sans accord). |
| `lib/views/` | **Jonathan / Dieuvie** | Écrans de l’application. C’est ici que vous travaillez ! |
| `lib/core/` | **Kevin / Chris** | Thème, widgets communs, constantes, routes. |
| `lib/main.dart` | **Kevin** | Point d’entrée, configuration des providers et routes. |

**Règle d’or** : ne modifiez jamais un fichier qui n’est pas dans votre zone.  
Si vous devez absolument changer quelque chose dans `controllers/`, parlez-en d’abord à Melvin.

---

## 3. Comment utiliser les contrôleurs dans les vues

### 3.1. Accéder à un contrôleur

Utilisez `Provider.of<T>(context)` ou `Consumer<T>`.

**Exemple avec `AuthController` :**
```dart
final auth = Provider.of<AuthController>(context);
if (auth.user != null) {
  // utilisateur connecté
}
```

**Exemple avec `Consumer` :**
```dart
Consumer<EventController>(
  builder: (context, eventController, child) {
    if (eventController.isLoading) return CircularProgressIndicator();
    return ListView(...);
  },
)
```

### 3.2. Charger les données au bon moment

Pour charger une liste dès que l’écran s’affiche :

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<EventController>(context, listen: false).loadEvents();
  });
}
```

---

## 4. API des contrôleurs

### `AuthController` – Gestion de l’authentification

| Propriété / Méthode | Description |
|---------------------|-------------|
| `User? user` | L’utilisateur Firebase actuellement connecté (ou `null`). |
| `String? role` | Rôle : `'organizer'` ou `'admin'` (ou `null` si non connecté). |
| `Future<void> signInWithEmail(String email, String password)` | Connexion email/mdp. |
| `Future<void> signUpWithEmail(String email, String password, String displayName)` | Inscription (crée un compte organisateur). |
| `Future<void> signInWithGoogle()` | Connexion avec Google. |
| `Future<void> signOut()` | Déconnexion. |

**Exemple d’utilisation :**  
```dart
ElevatedButton(
  onPressed: () => auth.signInWithEmail(emailCtrl.text, pwdCtrl.text),
  child: Text('Connexion'),
);
```

---

### `EventController` – Gestion des événements

| Propriété / Méthode | Description |
|---------------------|-------------|
| `List<Event> events` | Liste observable des événements (selon le dernier chargement). |
| `bool isLoading` | Indique si un chargement est en cours. |
| `void loadEvents()` | Écoute **tous** les événements (pour l’agenda public). |
| `void loadEventsByOrganizer(String organizerId)` | Écoute les événements d’un organisateur spécifique. |
| `Future<void> addEvent(Event event)` | Ajoute un nouvel événement. |
| `Future<void> updateEvent(Event event)` | Met à jour un événement. |
| `Future<void> deleteEvent(String eventId)` | Supprime un événement. |

**Exemple pour l’agenda public (Jonathan) :**
```dart
eventController.loadEvents(); // dans initState
// puis afficher eventController.events
```

**Exemple pour le dashboard organisateur (Dieuvie) :**
```dart
eventController.loadEventsByOrganizer(auth.user!.uid);
```

---

### `ReservationController` – Gestion des réservations

| Propriété / Méthode | Description |
|---------------------|-------------|
| `List<Reservation> reservations` | Liste observable des réservations (selon le filtre). |
| `bool isLoading` | Indique si un chargement est en cours. |
| `void loadReservationsForEvent(String eventId)` | Écoute les réservations d’un événement. |
| `void loadReservationsForOrganizer(String organizerId)` | Écoute toutes les réservations d’un organisateur. |
| `Future<bool> createReservation({required String eventId, required String organizerId, required String participantName, required String participantEmail, required int ticketsCount, required double totalPaid, required String qrCodeData})` | Crée une réservation (utilisé après paiement ou pour billet gratuit). |

**Exemple pour afficher les participants d’un événement (Dieuvie) :**
```dart
reservationController.loadReservationsForEvent(event.id);
```

---

## 5. Paiement avec l’API Labyrinthe

Le service `LabyrinthePaymentService` est déjà prêt dans `services/`.  
Il est utilisé automatiquement par le `ReservationController` quand le billet est payant.

**Pour l’instant, le flux complet n’est pas encore intégré dans le contrôleur.**  
Nous en reparlerons quand j’aurai finalisé l’intégration. En attendant, vous pouvez tester les réservations gratuites.

---

## 6. Ce que vous devez faire (Jonathan, Dieuvie, Kevin)

### Jonathan (front-end participant)
- Créer les écrans dans `lib/views/public/` et `lib/views/participant/` :
  - Liste des événements (agenda) – utilise `EventController.loadEvents()`.
  - Détail d’un événement.
  - Formulaire d’achat (collecte infos participant) – appelle `ReservationController.createReservation()`.
  - Page de confirmation avec QR code (utilise `qr_flutter`).

### Dieuvie (front-end organisateur / admin)
- Créer les écrans dans `lib/views/organizer/` et `lib/views/admin/` :
  - Dashboard organisateur (ses événements) – utilise `EventController.loadEventsByOrganizer(auth.user!.uid)`.
  - Formulaire création/édition d’événement – appelle `addEvent` / `updateEvent`.
  - Liste des participants pour un événement – utilise `ReservationController.loadReservationsForEvent(event.id)`.
  - Interface super admin (si le temps le permet) – liste de tous les utilisateurs/événements avec suppression.

### Kevin (lead technique)
- Configurer les routes nommées dans `main.dart` (ex: `/`, `/login`, `/dashboard`, `/event-detail`).
- Mettre en place le thème global (`core/theme`).
- Ajouter les providers dans `MultiProvider` (déjà fait, mais à vérifier).
- Gérer le dépôt Git : branches, protection de `main`, revues de code.

---

## 7. Règles de collaboration Git

1. **Chacun travaille sur sa propre branche** :
   - `feature/frontend-participant` (Jonathan)
   - `feature/organizer-dashboard` (Dieuvie)
   - `feature/core-setup` (Kevin)
   - `feature/backend` (Melvin)

2. **Ne jamais commiter directement sur `main`**.
3. **Avant de commencer une nouvelle fonctionnalité**, faites un `git pull origin main` pour récupérer les dernières mises à jour.
4. **Ouvrez une Pull Request** vers `main` (ou `develop`) quand votre fonctionnalité est prête.
5. **Kevin fera les revues de code** et merger après validation.

**Conflits :** si vous modifiez le même fichier que quelqu’un d’autre (par exemple `main.dart` pour ajouter une route), c’est Kevin qui s’en charge. Évitez de modifier `main.dart` vous-mêmes sans coordination.

---

## 8. Résumé : fichiers à ne pas toucher

❌ **NE PAS MODIFIER** (sauf accord explicite) :
- `lib/models/*`
- `lib/services/*`
- `lib/controllers/*`

✅ **VOUS POUVEZ MODIFIER** :
- `lib/views/**/*` (tous vos écrans)
- `lib/core/**/*` (thème, widgets, constantes)
- `lib/main.dart` (uniquement Kevin ou après coordination)

---

## 9. Premier lancement après récupération du code

1. Clonez le dépôt.
2. Exécutez `flutter pub get`.
3. Assurez-vous d’avoir le fichier `firebase_options.dart` (généré par `flutterfire configure`).
4. Lancez l’application avec `flutter run`.

Si vous rencontrez des problèmes, contactez-moi ou Kevin.

---

**Merci à tous !**  
Avec cette organisation, on avance vite et sans conflits. 💪

— Melvin