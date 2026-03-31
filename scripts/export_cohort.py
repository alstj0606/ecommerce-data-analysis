from pathlib import Path
import pandas as pd

from load_data import load_all_data


BASE_DIR = Path(__file__).resolve().parent.parent
PROCESSED_DIR = BASE_DIR / "data" / "processed"


def build_order_summary():
    orders, customers, order_items = load_all_data()

    orders["order_purchase_timestamp"] = pd.to_datetime(
        orders["order_purchase_timestamp"]
    )

    delivered_orders = orders[orders["order_status"] == "delivered"].copy()

    order_summary = (
        delivered_orders.merge(
            customers[["customer_id", "customer_unique_id"]],
            on="customer_id",
            how="left",
        )
        .merge(
            order_items[["order_id", "order_item_id", "price", "freight_value"]],
            on="order_id",
            how="left",
        )
        .groupby(
            ["order_id", "customer_unique_id", "order_purchase_timestamp", "order_status"],
            as_index=False,
        )
        .agg(
            items_count=("order_item_id", "count"),
            order_revenue=("price", "sum"),
            freight_total=("freight_value", "sum"),
        )
    )

    order_summary["order_month"] = order_summary["order_purchase_timestamp"].dt.to_period("M")

    return order_summary


def build_cohort_retention(order_summary: pd.DataFrame) -> pd.DataFrame:
    cohort_df = order_summary[["customer_unique_id", "order_purchase_timestamp"]].copy()
    cohort_df["order_month"] = cohort_df["order_purchase_timestamp"].dt.to_period("M")

    first_purchase = (
        cohort_df.groupby("customer_unique_id", as_index=False)
        .agg(cohort_month=("order_month", "min"))
    )

    cohort_df = cohort_df.merge(first_purchase, on="customer_unique_id", how="left")

    cohort_df["cohort_index"] = (
        (cohort_df["order_month"].dt.year - cohort_df["cohort_month"].dt.year) * 12
        + (cohort_df["order_month"].dt.month - cohort_df["cohort_month"].dt.month)
        + 1
    )

    cohort_counts = (
        cohort_df.groupby(["cohort_month", "cohort_index"])["customer_unique_id"]
        .nunique()
        .reset_index(name="customers")
    )

    cohort_pivot = cohort_counts.pivot(
        index="cohort_month",
        columns="cohort_index",
        values="customers",
    )

    cohort_size = cohort_pivot.iloc[:, 0]
    retention = cohort_pivot.divide(cohort_size, axis=0) * 100

    cohort_retention = (
        retention.reset_index()
        .melt(id_vars="cohort_month", var_name="cohort_index", value_name="retention_pct")
        .dropna()
    )

    cohort_retention["cohort_month"] = cohort_retention["cohort_month"].astype(str)
    cohort_retention["cohort_index"] = cohort_retention["cohort_index"].astype(int)
    cohort_retention["retention_pct"] = cohort_retention["retention_pct"].round(2)

    return cohort_retention


if __name__ == "__main__":
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

    order_summary = build_order_summary()
    cohort_retention = build_cohort_retention(order_summary)

    cohort_retention.to_csv(PROCESSED_DIR / "cohort_retention.csv", index=False)

    print(cohort_retention.head(10))
    print("saved:", PROCESSED_DIR / "cohort_retention.csv")