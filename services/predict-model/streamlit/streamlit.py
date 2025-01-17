import streamlit as st
import pandas as pd
import numpy as np
import altair as alt


st.header("Graphic Crypto:")

col1, col2 = st.columns(2)

col1.metric("total wallet", "1000")
col2.metric("tomorrow's forecast", "1200", "4%")

# Generate realistic data for the past 30 days with closer variations
dates = pd.date_range(end=pd.Timestamp.today(), periods=30)
data = {
    "date": np.tile(dates, reps= 1),
    "Crypto monnaie": np.repeat("Bitcoins", 30),
    "value": np.concatenate([
        np.random.randn(30) * 1000 + 35000,  # Bitcoins prices
    ])
}

chart_data = pd.DataFrame(data)

st.line_chart(chart_data, x="date", y="value", color="Crypto monnaie")


# Generate realistic data for the past 30 days
dates = pd.date_range(end=pd.Timestamp.today(), periods=30)
values = np.random.randn(30) * 1000 + 35000  # Simulate Bitcoin prices
percent_changes = np.diff(values) / values[:-1] * 100

# Create DataFrame for the bar chart
data = {
    "date": dates[1:],
    "percent_change": np.round(percent_changes, 2)  # Round to 2 decimal places
}

chart_data = pd.DataFrame(data)

color_scale = alt.condition(
    alt.datum.percent_change > 0,
    alt.value('#3A9D23'),  # Green for positive changes
    alt.value('#FF0000')   # Red for negative changes
)

bar_chart = alt.Chart(chart_data).mark_bar(size=30).encode(  # Increase bar size
    x=alt.X('date:T', axis=alt.Axis(format='%d %b', title='Date')),  # Display all days
    y=alt.Y('percent_change:Q', title='Percentage Change'),
    color=color_scale
).properties(
    width=800  # Adjust width if needed
)

st.altair_chart(bar_chart, use_container_width=True)
