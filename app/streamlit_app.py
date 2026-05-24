from pathlib import Path

import pandas as pd
import plotly.express as px
import streamlit as st


BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data" / "sample"


@st.cache_data
def load_csv(filename: str) -> pd.DataFrame:
    return pd.read_csv(DATA_DIR / filename)


st.set_page_config(
    page_title="Snowflake Mobility Analytics",
    page_icon="🚕",
    layout="wide",
)

PLOTLY_CONFIG = {
    "displayModeBar": True,
    "responsive": True
}

st.title("🚕 Snowflake Mobility Analytics")
st.caption("NYC Yellow Taxi + Weather analytics demo built on Snowflake")

pipeline_summary = load_csv("ops_pipeline_summary.csv")
data_quality = load_csv("ops_data_quality_report.csv")
pickup_zones = load_csv("gold_pickup_zone_metrics.csv")
top_routes = load_csv("gold_top_routes_by_revenue.csv")
weather_bucket = load_csv("gold_weather_impact_by_bucket.csv")
cost_summary = load_csv("ops_cost_monitoring_summary.csv")


st.header("Project summary")

col1, col2, col3, col4 = st.columns(4)

raw_rows = int(pipeline_summary["RAW_ROW_COUNT"].iloc[0])
valid_rows = int(pipeline_summary["VALID_ROW_COUNT"].iloc[0])
valid_pct = float(pipeline_summary["VALID_ROW_PERCENTAGE"].iloc[0])
total_revenue = float(pipeline_summary["TOTAL_REVENUE"].iloc[0])

col1.metric("Raw taxi rows", f"{raw_rows:,}")
col2.metric("Valid taxi rows", f"{valid_rows:,}")
col3.metric("Valid rows", f"{valid_pct:.2f}%")
col4.metric("Total revenue", f"${total_revenue:,.0f}")

st.header("Cost monitoring")

cost1, cost2, cost3, cost4 = st.columns(4)

credits_used = float(cost_summary["CREDITS_USED_TOTAL"].iloc[0])
estimated_cost = float(cost_summary["ESTIMATED_COST_USD"].iloc[0])
budget_used = float(cost_summary["ESTIMATED_TRIAL_BUDGET_USED_PCT"].iloc[0])
budget_remaining = float(cost_summary["ESTIMATED_TRIAL_BUDGET_REMAINING_USD"].iloc[0])

cost1.metric("Credits used", f"{credits_used:.4f}")
cost2.metric("Estimated cost", f"${estimated_cost:.2f}")
cost3.metric("Trial budget used", f"{budget_used:.2f}%")
cost4.metric("Budget remaining", f"${budget_remaining:.2f}")

st.header("Pickup zone performance")

top_n = st.slider("Top N pickup zones", min_value=5, max_value=30, value=15)

top_pickups = (
    pickup_zones.sort_values("TRIPS_COUNT", ascending=False)
    .head(top_n)
)

fig_pickups = px.bar(
    top_pickups,
    x="TRIPS_COUNT",
    y="PICKUP_ZONE",
    orientation="h",
    hover_data=["PICKUP_BOROUGH", "TOTAL_REVENUE", "AVG_TOTAL_AMOUNT"],
    title="Top pickup zones by trip count",
)
fig_pickups.update_layout(yaxis={"categoryorder": "total ascending"})
st.plotly_chart(fig_pickups, config=PLOTLY_CONFIG)

st.header("Top revenue routes")

route_n = st.slider("Top N routes", min_value=5, max_value=30, value=15)

top_routes_view = top_routes.sort_values("TOTAL_REVENUE", ascending=False).head(route_n).copy()
top_routes_view["ROUTE"] = (
    top_routes_view["PICKUP_ZONE"].astype(str)
    + " → "
    + top_routes_view["DROPOFF_ZONE"].astype(str)
)

fig_routes = px.bar(
    top_routes_view,
    x="TOTAL_REVENUE",
    y="ROUTE",
    orientation="h",
    hover_data=["TRIPS_COUNT", "AVG_TOTAL_AMOUNT", "AVG_TRIP_DISTANCE"],
    title="Top routes by revenue",
)
fig_routes.update_layout(yaxis={"categoryorder": "total ascending"})
st.plotly_chart(fig_routes, config=PLOTLY_CONFIG)

st.header("Weather impact")

fig_weather = px.bar(
    weather_bucket,
    x="TEMPERATURE_BUCKET",
    y="AVG_TRIPS_PER_HOUR",
    color="HAS_PRECIPITATION",
    barmode="group",
    hover_data=["HOURS_COUNT", "TRIPS_COUNT", "TOTAL_REVENUE"],
    title="Average trips per hour by temperature bucket and precipitation",
)
st.plotly_chart(fig_weather, config=PLOTLY_CONFIG)

st.header("Data quality")

quality = data_quality.iloc[0]

quality_rows = pd.DataFrame(
    {
        "check": [
            "Pickup before January 2024",
            "Pickup after January 2024",
            "Invalid time order",
            "Non-positive distance",
            "Negative fare",
            "Negative total",
        ],
        "count": [
            quality["PICKUP_BEFORE_JAN_2024"],
            quality["PICKUP_AFTER_JAN_2024"],
            quality["INVALID_TIME_ORDER"],
            quality["NON_POSITIVE_DISTANCE"],
            quality["NEGATIVE_FARE"],
            quality["NEGATIVE_TOTAL"],
        ],
    }
)

fig_quality = px.bar(
    quality_rows,
    x="count",
    y="check",
    orientation="h",
    title="Data quality findings in raw taxi data",
)
fig_quality.update_layout(yaxis={"categoryorder": "total ascending"})
st.plotly_chart(fig_quality, config=PLOTLY_CONFIG)

with st.expander("Raw tables used by dashboard"):
    st.subheader("Pipeline summary")
    st.dataframe(pipeline_summary, width="stretch")

    st.subheader("Cost summary")
    st.dataframe(cost_summary, width="stretch")

    st.subheader("Pickup zones")
    st.dataframe(pickup_zones, width="stretch")

    st.subheader("Top routes")
    st.dataframe(top_routes, width="stretch")

    st.subheader("Weather impact by bucket")
    st.dataframe(weather_bucket, width="stretch")

    st.subheader("Data quality report")
    st.dataframe(data_quality, width="stretch")