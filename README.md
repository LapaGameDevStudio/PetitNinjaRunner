# PetitNinjaRunner

PetitNinjaRunner est un jeu 2D de type runner où un ninja saute pour éviter des obstacles.  
Ce projet est réalisé avec Godot Engine.

---

## 🚀 Phases du projet et tâches (Issues)

### 🔹 Phase 1 : Scène principale
- Ajouter le joueur (Player) avec sprite et collision
- Implémenter le saut et la gravité
- Créer un sol fixe (Ground)

### 🔹 Phase 2 : Obstacles
- Créer une scène `Obstacle.tscn`
- Faire défiler les obstacles vers la gauche
- Créer un spawner d’obstacles automatiques
- Détruire les obstacles hors écran

### 🔹 Phase 3 : Gestion des collisions et Game Over
- Détecter la collision joueur/obstacle
- Ajouter un écran de Game Over avec option de recommencer

---

## 🎮 Comment lancer le jeu

1. Ouvrir Godot Engine
2. Charger le projet `PetitNinjaRunner`
3. Ouvrir la scène principale `Main.tscn`
4. Cliquer sur **Play** (F5)

---

## 📁 Organisation des fichiers

- `Main.tscn` — scène principale
- `Player` (Node CharacterBody2D) — joueur avec sprite, collision et script
- `Ground` (StaticBody2D) — sol fixe
- `Obstacle.tscn` — scène obstacle avec sprite et collision
- `Spawner` — node qui génère les obstacles automatiquement

---

## 🛠️ Configuration Git & GitHub

- Branche principale : `develop`
- Utilisation de branches `feature/xxx` pour les fonctionnalités
- Pull Requests (PR) pour intégrer les fonctionnalités après revue
- Issues pour suivre les tâches et bugs

---

## 🎵 Sons & Images

- Sons stockés dans `/assets/sounds/`
- Images et sprites dans `/assets/images/`

---

## 📝 TODO / Features futures

- Ajouter sons pour sauts et collisions
- Ajouter animations au joueur
- Ajouter système de score
- Ajouter écran de pause et menus

---

## 📬 Contact

Pour toute question ou contribution, ouvre une issue ou PR sur GitHub.

---

*Amuse-toi bien avec PetitNinjaRunner !* 🥷🎉
