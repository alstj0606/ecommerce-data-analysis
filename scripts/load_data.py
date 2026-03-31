from pathlib import Path
import pandas as pd


BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DATA_DIR = BASE_DIR / "data" / "raw" / "archive"


def load_orders() -> pd.DataFrame:
    return pd.read_csv(RAW_DATA_DIR / "olist_orders_dataset.csv")


def load_customers() -> pd.DataFrame:
    return pd.read_csv(RAW_DATA_DIR / "olist_customers_dataset.csv")


def load_order_items() -> pd.DataFrame:
    return pd.read_csv(RAW_DATA_DIR / "olist_order_items_dataset.csv")


def load_all_data() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    orders = load_orders()
    customers = load_customers()
    order_items = load_order_items()
    return orders, customers, order_items