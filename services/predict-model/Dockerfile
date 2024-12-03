# Utiliser une image de base légère qui supporte Python
FROM python:3.9-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers nécessaires dans le conteneur
COPY . /app

# Installer les dépendances définies dans requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Exposer le port sur lequel l'API sera disponible
EXPOSE 8000

# Lancer le serveur avec Uvicorn
CMD ["uvicorn", "predict:app", "--host", "0.0.0.0", "--port", "8000"]

