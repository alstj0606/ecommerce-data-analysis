import pandas as pd

from load_data import load_all_data


def convert_datetime_columns(orders: pd.DataFrame) -> pd.DataFrame:
    orders = orders.copy()

    datetime_cols = [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ]

    for col in datetime_cols:
        orders[col] = pd.to_datetime(orders[col], errors="coerce")

    return orders


def filter_delivered_orders(orders: pd.DataFrame) -> pd.DataFrame:
    return orders[orders["order_status"] == "delivered"].copy()


def build_base_df(
    orders: pd.DataFrame,
    customers: pd.DataFrame,
    order_items: pd.DataFrame,
) -> pd.DataFrame:
    orders_customers = orders.merge(
        customers,
        on="customer_id",
        how="left",
    )

    base_df = orders_customers.merge(
        order_items,
        on="order_id",
        how="left",
    )

    return base_df


def build_order_summary(base_df: pd.DataFrame) -> pd.DataFrame:
    order_summary = (
        base_df.groupby("order_id", as_index=False)
        .agg(
            customer_unique_id=("customer_unique_id", "first"),
            order_purchase_timestamp=("order_purchase_timestamp", "first"),
            order_status=("order_status", "first"),
            items_count=("order_item_id", "count"),
            order_revenue=("price", "sum"),
            freight_total=("freight_value", "sum"),
        )
    )

    return order_summary


def add_order_month(order_summary: pd.DataFrame) -> pd.DataFrame:
    order_summary = order_summary.copy()
    order_summary["order_month"] = (
        order_summary["order_purchase_timestamp"].dt.to_period("M").astype(str)
    )
    return order_summary


def build_customer_summary(order_summary: pd.DataFrame) -> pd.DataFrame:
    customer_summary = (
        order_summary.groupby("customer_unique_id", as_index=False)
        .agg(
            first_order_date=("order_purchase_timestamp", "min"),
            last_order_date=("order_purchase_timestamp", "max"),
            total_orders=("order_id", "count"),
            total_revenue=("order_revenue", "sum"),
            total_freight=("freight_total", "sum"),
        )
    )

    return customer_summary


def preprocess_all() -> tuple[pd.DataFrame, pd.DataFrame]:
    orders, customers, order_items = load_all_data()

    orders = convert_datetime_columns(orders)
    orders = filter_delivered_orders(orders)

    base_df = build_base_df(orders, customers, order_items)
    order_summary = build_order_summary(base_df)
    order_summary = add_order_month(order_summary)

    customer_summary = build_customer_summary(order_summary)

    return order_summary, customer_summary


if __name__ == "__main__":
    order_summary, customer_summary = preprocess_all()

    print("order_summary shape:", order_summary.shape)
    print("customer_summary shape:", customer_summary.shape)
    print(order_summary.head())
    print(customer_summary.head())