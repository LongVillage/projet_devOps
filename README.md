# Projet MLOps - README

## Introduction

Ce projet est un Proof of Concept (PoC) visant à mettre en place une architecture complète d'un pipeline MLOps pour le déploiement de modèles de Machine Learning. L'objectif est de permettre l'automatisation des différentes étapes du cycle de vie des modèles : extraction des données, entraînement, prédiction, monitoring du drift des modèles et réentraînement automatique lorsque des seuils sont atteints. Le tout est déployé sur Kubernetes avec une intégration CI/CD, et inclut l'utilisation d'outils tels que Docker, Helm, et AWS SageMaker.

## Structure du Projet

Voici la structure actuelle du projet :

```
/mon-projet-mlops/
├── charts/                         # Charts Helm pour gérer les services
│   ├── extract-data/               # Chart Helm pour le service d'extraction des données
│   │   ├── Chart.yaml              # Metadata du chart Helm
│   │   ├── values.yaml             # Valeurs utilisées dans les templates Helm
│   │   └── templates/              # Templates des ressources Kubernetes
│   │       ├── job.yaml            # Template pour le Job d'extraction des données
│   ├── train-model/                # Chart Helm pour le service d'entraînement
│   │   ├── Chart.yaml              # Metadata du chart Helm
│   │   ├── values.yaml             # Valeurs utilisées dans les templates Helm
│   │   └── templates/              # Templates des ressources Kubernetes
│   │       ├── job.yaml            # Template pour le Job d'entraînement
│   └── predict-model/              # Chart Helm pour le service de prédiction
│       ├── Chart.yaml              # Metadata du chart Helm
│       ├── values.yaml             # Valeurs utilisées dans les templates Helm
│       └── templates/              # Templates des ressources Kubernetes
│           ├── deployment.yaml     # Template pour le Déploiement du service de prédiction
│           ├── service.yaml        # Template pour exposer le déploiement
├── services/                       # Dossier contenant chaque service
│   ├── extract-data/               # Service d'extraction des données
│   │   ├── Dockerfile              # Dockerfile pour construire l'image du service
│   │   ├── requirements.txt        # Dépendances Python
│   │   ├── main.py                 # Script principal (vide pour le moment)
│   │   └── k8s/                    # Manifests Kubernetes spécifiques
│   │       ├── job.yaml            # Job pour l'extraction (version non Helm)
│   │       ├── secret.yaml         # Secret pour accéder à AWS (version non Helm)
│   ├── train-model/                # Service d'entraînement des modèles
│   │   ├── Dockerfile              # Dockerfile pour construire l'image du service
│   │   ├── requirements.txt        # Dépendances Python
│   │   ├── train.py                # Script d'entraînement (en attente de validation)
│   │   └── k8s/                    # Manifests Kubernetes spécifiques
│   │       ├── job.yaml            # Job Kubernetes pour l'entraînement
│   ├── predict-model/              # Service de prédiction des modèles
│   │   ├── Dockerfile              # Dockerfile pour le service de prédiction
│   │   ├── requirements.txt        # Dépendances Python
│   │   ├── predict.py              # Script pour gérer les prédictions
│   │   └── k8s/                    # Manifests Kubernetes spécifiques
│   │       ├── deployment.yaml     # Déploiement Kubernetes pour le service de prédiction
│   │       ├── service.yaml        # Service Kubernetes pour exposer le déploiement
├── .gitlab-ci.yml                  # CI/CD pour orchestrer les services
└── README.md                       # Documentation
```

## Commandes Pertinentes

Voici un ensemble de commandes importantes pour interagir avec le projet.

### 1. **Docker**

Pour construire et pousser les images Docker sur votre repository AWS ECR :

- **Construire l'image Docker** :

  ```bash
  docker build -t [your-aws-ecr-repo]/[service-name]:latest ./services/[service-name]
  ```

- **Se connecter à AWS ECR** :

  ```bash
  aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin [your-aws-ecr-repo]
  ```

- **Pousser l'image Docker vers ECR** :

  ```bash
  docker push [your-aws-ecr-repo]/[service-name]:latest
  ```

### 2. **Kubernetes (kubectl)**

- **Appliquer un fichier Kubernetes** :

  ```bash
  kubectl apply -f services/[service-name]/k8s/[manifest-file].yaml
  ```

- **Vérifier l'état d'un job** :

  ```bash
  kubectl get jobs -n data-processing
  ```

- **Voir les logs d'un job** :

  ```bash
  kubectl logs job/[job-name] -n data-processing
  ```

- **Créer un namespace** :

  ```bash
  kubectl create namespace data-processing
  ```

### 3. **Helm**

- **Lint le Chart Helm** :

  ```bash
  helm lint charts/[service-name]
  ```

- **Déployer le Chart Helm** :

  ```bash
  helm upgrade --install [service-name] charts/[service-name] --namespace data-processing
  ```

- **Visualiser les fichiers YAML générés** :

  ```bash
  helm template charts/[service-name]
  ```

### 4. **CI/CD (GitLab)**

- La pipeline CI/CD est définie dans le fichier **`.gitlab-ci.yml`**, et comporte des stages de build, push, et deploy pour chaque service. Chaque modification pushée sur le repository déclenchera automatiquement ces processus.

## Ce Qui Est Mis en Place

Voici un résumé de ce qui est déjà en place :

- **Service d'Extraction des Données** : Récupération des données d'une source externe et stockage dans un bucket S3.
- **Service d'Entraînement des Modèles** : Déclenchement de l'entraînement de modèles ML (en attente de validation des détails du script d'entraînement).
- **Service de Prédiction** : Fourniture d'une API REST permettant de faire des prédictions à partir des modèles déployés.
- **CI/CD** : Automatisation des processus de construction, push, et déploiement des images Docker via GitLab CI/CD.
- **Helm** : Gérer et déployer les services avec une approche modulaire adaptable aux différents environnements.

## Ce Qu'il Reste à Faire

1. **Authentification des Utilisateurs** : Créer un service backend permettant l'inscription, la connexion, et la gestion des utilisateurs (login/password).
2. **Ajout d'Ingress** : Utiliser un Ingress Kubernetes pour rendre les services accessibles publiquement.
3. **Monitoring et MLOps** : Intégrer des outils de monitoring comme **Prometheus** et **Grafana** pour surveiller les modèles en production et détecter le drift des données.
4. **Gestion des Modèles Multiples** : Modifier le service de prédiction pour permettre aux utilisateurs de choisir parmi plusieurs modèles (comme régression linéaire, logistique, et random forest).
5. **Base de Données** : Ajouter une base de données poursauvegarder les informations d'utilisateur (identifiants et informations de sessions) et potentiellement les métadonnées des prédictions réalisées.


   # Conclusion
   Cette documentation est un guide complet de ce qui a été mis en place jusqu'à présent, ainsi que des prochaines étapes à réaliser pour atteindre les objectifs du projet. N'hésitez pas à consulter chaque section, tester les différentes commandes, et me faire part de vos questions ou besoins de clarification.


