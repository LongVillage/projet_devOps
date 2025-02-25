import streamlit as st
import pandas as pd
import numpy as np
import altair as alt
import requests

# Ton endpoint public
ENDPOINT_URL = "https://01ce0xnund.execute-api.eu-west-3.amazonaws.com/dev/prediction"


@st.cache_data
def fetch_prediction():
    try:
        response = requests.post(ENDPOINT_URL)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erreur lors de l'appel à l'endpoint : {e}")
        return None


# Appel API au chargement de la page
predicted_value = fetch_prediction()

if predicted_value is not None:
    col1, col2 = st.columns(2)
    total_wallet = 1000
    total_wallet_tomorrow = round(total_wallet + ((total_wallet * predicted_value) / 100), 2)

    col1.metric("Total Wallet", total_wallet)
    col2.metric("Prévision pour demain", f"{total_wallet_tomorrow}", f"{predicted_value}%")

    # Génération des dates pour la semaine du 3 mars 2025
    dates = pd.date_range("2025-03-03", periods=7)

    # Estimation stable des valeurs entre 30 000 et 40 000 (exemple : tendance haussière)
    bitcoin_prices = [32000, 32500, 33000, 34000, 35000, 35500, 36000]

    # Création du DataFrame
    data = pd.DataFrame({
        "date": dates,
        "value": bitcoin_prices
    })

    # Création du graphique avec Altair en fixant les limites de l'axe Y
    chart = alt.Chart(data).mark_line().encode(
        x="date:T",
        y=alt.Y("value:Q", scale=alt.Scale(domain=[30000, 40000]))
    ).properties(
        title="Estimation du Bitcoin (Semaine du 3 mars 2025)"
    )

    # Affichage du graphique
    st.altair_chart(chart, use_container_width=True)
else:
    st.error("Format de réponse inconnu ou clé 'prediction' manquante")

