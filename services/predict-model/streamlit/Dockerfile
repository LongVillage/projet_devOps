# Utilise une image Python de base
FROM python:3.9-slim

# Définit le répertoire de travail
WORKDIR /app

# Copie le fichier requirements.txt dans le conteneur depuis le dossier streamlit
COPY requirements.txt ./requirements.txt

# Installe les dépendances nécessaires
RUN pip install --no-cache-dir -r requirements.txt

# Copie tout le contenu du dossier streamlit dans le répertoire de travail
COPY . .

# Expose le port par défaut utilisé par Streamlit
EXPOSE 8501

# Commande pour lancer Streamlit
CMD ["streamlit", "run", "streamlit.py"]
