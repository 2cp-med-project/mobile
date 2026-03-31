<!-- # 🏥 Healio — Plateforme de Santé Numérique (Algérie)

## 📋 Description

**Healio** est une application mobile Flutter destinée aux **patients algériens**, conçue pour centraliser et simplifier la gestion de leur santé au quotidien. Elle connecte les patients à leurs médecins, leurs dossiers médicaux et un assistant IA de santé personnalisé.

---

## 🎯 Objectif

Permettre à chaque patient de :
- Avoir **tout son parcours médical en un seul endroit**
- Communiquer facilement avec ses médecins
- Être alerté en temps réel des demandes d'accès à son dossier
- Consulter et évaluer les médecins de sa région
- Interagir avec un chatbot IA pour des questions de santé

---

## ✨ Fonctionnalités

### 🔐 Authentification
- Inscription en 5 étapes (nom, prénom, date de naissance, localisation, contacts d'urgence, mot de passe)
- Vérification OTP (email / téléphone)
- Formulaire médical initial (groupe sanguin, allergies, antécédents...)
- Connexion sécurisée avec token JWT

### 🏠 Dashboard
- Carte de bienvenue avec prochain rendez-vous
- Accès rapide : Demandes, Dossier Médical, Assistant AI, Expériences
- Liste des prochains rendez-vous
- Liste des demandes récentes avec statuts (En attente / Acceptée / Refusée / Échec)

### 📁 Gestion des Demandes d'Accès
- Un médecin demande l'accès au dossier médical du patient
- Le patient reçoit une **notification Firebase (FCM)** en temps réel
- Modal de confirmation avec blur : **Accorder l'autorisation** ou **Refuser**
- Historique des demandes avec statuts colorés

### 🤖 Assistant IA (HealBot)
- Chatbot médical alimenté par un **LLM backend**
- Accès rapide : Mes rapports, Mes médicaments, Rendez-vous du jour
- Envoi d'images depuis la galerie
- Historique des conversations sauvegardé
- Recherche et suppression de conversations

### ⭐ Expériences des Patients
- Liste des médecins avec notes et avis
- Filtres par spécialité (Cardiologie, Neurologie, Dermatologie...)
- Évaluation détaillée : Note globale, Ponctualité, Communication, Expertise, Écoute
- Avis de la communauté

### 👤 Profil Patient
- Photo de profil + nom + ID patient
- Contacts d'urgence
- Modification des informations personnelles
- Paramètres de notifications (RDV, demandes médecins)
- Sécurité et confidentialité
- Déconnexion

---

## 🛠️ Stack Technique

### Mobile (Flutter)
| Package | Usage |
|---|---|
| `flutter_svg` | Icônes SVG |
| `shared_preferences` | Stockage local (token, profil) |
| `firebase_core` | Firebase init |
| `firebase_messaging` | Notifications push (FCM) |
| `image_picker` | Galerie photo |
| `dio` | Requêtes HTTP vers backend |

### Backend (à intégrer)
- **Auth** : JWT (login, register, OTP)
- **LLM** : Chatbot IA médical
- **FCM** : Envoi de notifications push
- **API REST** : RDV, dossiers, demandes, évaluations

---

## 📱 Screens

```
Splash → SignIn → SignUp (5 étapes) → OTP → Formule → MedicalForm → Welcome
                                                                        ↓
                                                                   MainScreen
                                                                   ├── Home
                                                                   ├── RDV
                                                                   ├── HealBot AI
                                                                   ├── Carte Santé
                                                                   ├── Dossier
                                                                   └── Profil
```

---

## 🔔 Notifications en Temps Réel

Lorsqu'un médecin envoie une demande d'accès :
1. Backend reçoit la demande
2. Backend envoie une notification via **Firebase FCM** au token du patient
3. L'app affiche un **modal avec blur** sur l'écran actif
4. Le patient accepte ou refuse → réponse envoyée au backend

---

## 🚧 Backend TODO (intégration finale)

- [ ] `POST /auth/login` → Connexion
- [ ] `POST /auth/register` → Inscription
- [ ] `POST /auth/otp/verify` → Vérification OTP
- [ ] `GET /profile` → Profil patient
- [ ] `GET /appointments/upcoming` → Prochains RDV
- [ ] `GET /requests/pending` → Demandes en attente
- [ ] `POST /requests/{id}/accept` → Accepter demande
- [ ] `POST /requests/{id}/refuse` → Refuser demande
- [ ] `GET /doctors` → Liste médecins
- [ ] `POST /reviews` → Soumettre évaluation
- [ ] `POST /chatbot/message` → Message LLM
- [ ] `POST /fcm/token` → Enregistrer token FCM
- [ ] `GET /chatbot/chats` → Historique conversations

---

## 👨‍💻 Équipe

Projet réalisé dans le cadre du **2CP** — Application mobile santé numérique pour l'Algérie.

---

## 📄 Licence

Projet académique — tous droits réservés. -->