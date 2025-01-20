# Utiliser une image de base légère qui supporte Python
FROM python:3.9-slim

ENV PYTHONBUFFED 1
ENV PYTHONDONTWRITEBYTECODE 1

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers nécessaires dans le conteneur
COPY . /app

# Installer les dépendances définies dans requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Exposer le port sur lequel l'API sera disponible
EXPOSE 8000

# Lancer le serveur avec Uvicorn
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

