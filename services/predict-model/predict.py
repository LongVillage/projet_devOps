from fastapi import FastAPI, HTTPException
import joblib
import os
import numpy as np

# Charger le modèle ML sauvegardé
model_path = os.getenv('MODEL_PATH', 'model/model.joblib')
try:
    model = joblib.load(model_path)
except Exception as e:
    raise RuntimeError(f"Erreur lors du chargement du modèle: {e}")

# Créer l'instance de FastAPI
app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Service de prédiction de modèle ML"}

@app.post("/predict/")
def predict(data: dict):
    try:
        # Extraire les features du payload JSON
        features = np.array(data['features']).reshape(1, -1)
        prediction = model.predict(features)
        return {"prediction": prediction.tolist()}
    except KeyError:
        raise HTTPException(status_code=400, detail="Payload incorrect, 'features' manquant")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur interne : {e}")

