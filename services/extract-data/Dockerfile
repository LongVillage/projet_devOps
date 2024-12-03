# Utiliser une image de base légère (ex. Python Alpine)
FROM python:3.9-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier tous les fichiers de code dans le conteneur
COPY . /app

# Installer les dépendances à partir du fichier requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Définir la commande par défaut du conteneur
CMD ["python", "main.py"]

