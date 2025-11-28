# 📦 GestStock

Application Flutter de gestion de stock moderne et simple, parfaite pour les petites entreprises et commerces.

## ✨ Fonctionnalités

### 🏠 Tableau de bord
- Vue d'ensemble du stock total et de sa valeur
- Statistiques des ventes du jour
- Alertes pour les produits en stock bas
- Liste des dernières ventes

### 📦 Gestion des produits
- Ajouter, modifier, supprimer des produits
- Recherche de produits
- Filtrage par catégorie
- Alerte automatique pour stock bas (≤ 5 unités)
- Affichage de la valeur totale du stock

### 🗂️ Gestion des catégories
- Créer des catégories personnalisées
- Voir le nombre de produits par catégorie
- Modifier et supprimer des catégories

### 💳 Gestion des ventes
- Enregistrer une vente
- Diminution automatique du stock
- Historique complet des ventes
- Statistiques détaillées (ventes du jour, revenu total, panier moyen)
- Calcul automatique du total

## 🎨 Design

- Interface moderne et épurée
- Palette de couleurs professionnelle (Indigo & Cyan)
- Cards avec coins arrondis et ombres légères
- Design Material 3
- Responsive et optimisé pour mobile

## 🛠️ Technologies utilisées

- **Flutter** 3.0+
- **Dart** 3.0+
- **Provider** - State Management
- **SQLite** (sqflite) - Base de données locale
- **Intl** - Formatage des dates et prix

## 📁 Structure du projet

```
lib/
├── main.dart                  # Point d'entrée
├── app.dart                   # Configuration app + navigation
├── models/                    # Modèles de données
│   ├── product.dart
│   ├── category.dart
│   └── sale.dart
├── services/                  # Services CRUD
│   ├── database_helper.dart
│   ├── product_service.dart
│   ├── category_service.dart
│   └── sale_service.dart
├── providers/                 # State management
│   ├── product_provider.dart
│   ├── category_provider.dart
│   └── sale_provider.dart
├── screens/                   # Écrans de l'app
│   ├── home/
│   ├── products/
│   ├── categories/
│   └── sales/
├── widgets/                   # Widgets réutilisables
│   ├── custom_button.dart
│   ├── product_card.dart
│   ├── sale_card.dart
│   ├── category_chip.dart
│   ├── dashboard_card.dart
│   └── empty_state.dart
└── utils/                     # Utilitaires
    ├── constants.dart
    ├── theme.dart
    └── helpers.dart
```

## 🚀 Installation

### Prérequis
- Flutter SDK installé (≥ 3.0.0)
- Android Studio / VS Code
- Un émulateur ou appareil physique

### Étapes

1. **Cloner le projet**
```bash
git clone [votre-repo]
cd kora_stock_manager
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Lancer l'application**
```bash
flutter run
```

## 📱 Utilisation

### Premier lancement
1. L'app crée automatiquement 3 catégories par défaut :
   - Aliment
   - Cosmétique
   - Boisson

2. Vous pouvez ensuite :
   - Ajouter vos propres catégories
   - Ajouter des produits
   - Enregistrer des ventes

### Workflow typique
1. **Créer des catégories** (optionnel, 3 sont déjà créées)
2. **Ajouter des produits** avec leur catégorie, prix et quantité
3. **Enregistrer des ventes** - le stock se met à jour automatiquement
4. **Consulter les statistiques** sur le dashboard

## 🎯 Fonctionnalités clés

### Alertes automatiques
- Un produit avec ≤ 5 unités en stock apparaît dans "Alertes stock bas"
- Badge rouge sur les cards de produits

### Calculs automatiques
- Valeur totale du stock = Σ(prix × quantité)
- Total vente = prix unitaire × quantité vendue
- Panier moyen = revenu total ÷ nombre de ventes

### Validation des données
- Vérification des stocks avant vente
- Validation des prix et quantités
- Confirmation avant suppression

## 🎨 Palette de couleurs

- **Primary** : `#4F46E5` (Indigo)
- **Accent** : `#0EA5E9` (Cyan)
- **Background** : `#F3F4F6` (Gris clair)
- **Success** : `#10B981` (Vert)
- **Warning** : `#F59E0B` (Orange)
- **Error** : `#EF4444` (Rouge)

## 📊 Base de données

### Tables SQLite

**categories**
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- description (TEXT)

**products**
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- categoryId (INTEGER)
- price (REAL)
- quantity (INTEGER)
- imagePath (TEXT)
- createdAt (TEXT)

**sales**
- id (INTEGER PRIMARY KEY)
- productId (INTEGER)
- productName (TEXT)
- quantity (INTEGER)
- unitPrice (REAL)
- totalPrice (REAL)
- date (TEXT)

## 🔧 Personnalisation

### Changer les couleurs
Modifier les constantes dans `lib/utils/constants.dart`

### Modifier le seuil de stock bas
```dart
// Dans constants.dart
static const int lowStockThreshold = 5; // Changer cette valeur
```

### Ajouter une devise différente
```dart
// Dans constants.dart
static const String currency = 'FCFA'; // Modifier ici
```

## 📝 TODO / Améliorations possibles

- [ ] Export des données en CSV/Excel
- [ ] Graphiques de ventes (charts)
- [ ] Historique des mouvements de stock
- [ ] Scanner de code-barres
- [ ] Mode sombre
- [ ] Sauvegarde cloud
- [ ] Multi-utilisateurs
- [ ] Rapports PDF

## 👨‍💻 Auteur

Projet scolaire - Gestion de stock Flutter

## 📄 Licence

Ce projet est libre d'utilisation pour des fins éducatives.

---

**Version** : 1.0.0  
**Dernière mise à jour** : 2025