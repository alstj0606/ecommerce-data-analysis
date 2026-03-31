from pathlib import Path

from preprocess_data import preprocess_all


BASE_DIR = Path(__file__).resolve().parent.parent
PROCESSED_DATA_DIR = BASE_DIR / "data" / "processed"
PROCESSED_DATA_DIR.mkdir(parents=True, exist_ok=True)


def export_processed_files() -> None:
    order_summary, customer_summary = preprocess_all()

    order_summary.to_csv(PROCESSED_DATA_DIR / "order_summary.csv", index=False)
    customer_summary.to_csv(PROCESSED_DATA_DIR / "customer_summary.csv", index=False)

    print("Saved:")
    print(PROCESSED_DATA_DIR / "order_summary.csv")
    print(PROCESSED_DATA_DIR / "customer_summary.csv")


if __name__ == "__main__":
    export_processed_files()