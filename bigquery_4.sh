#!/bin/bash

echo ""
echo "🚀 Starting BigQuery Task..."
echo ""

# Set variables
PROJECT_ID=$(gcloud config get-value project)
DATASET_NAME="products"
TABLE_NAME="products_information"
BUCKET_NAME="qwiklabs-gcp-03-873ca497ab9d-bucket"
CSV_FILE="your_file.csv"  # Replace with actual CSV filename

# ✅ Upload CSV to BigQuery Table
echo "📂 Uploading CSV data from $BUCKET_NAME to BigQuery table..."
bq load --source_format=CSV --autodetect "$DATASET_NAME.$TABLE_NAME" "gs://$BUCKET_NAME/$CSV_FILE"

# ✅ Create Search Index on All Columns
echo "🔍 Creating Search Index on $TABLE_NAME..."
bq query --use_legacy_sql=false "
CREATE OR REPLACE SEARCH INDEX product_search_index
ON $DATASET_NAME.$TABLE_NAME (SKU, name, orderedQuantity, stockLevel, restockingLeadTime);
"

# ✅ Run Query to Search for "22 oz Water Bottle"
echo "🔎 Searching for '22 oz Water Bottle'..."
bq query --use_legacy_sql=false "
SELECT * FROM $DATASET_NAME.$TABLE_NAME 
WHERE SEARCH(STRUCT(SKU, name, orderedQuantity, stockLevel, restockingLeadTime), '22 oz Water Bottle');
"

echo ""
echo "✅ Task Completed Successfully!"
echo ""
