# Utiliser une image de base légère qui supporte Python
FROM python:3.9-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier les fichiers nécessaires dans le conteneur
COPY . /app

# Installer les dépendances définies dans requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Définir la commande par défaut du conteneur pour lancer le script d'entraînement
CMD ["python", "train.py"]

