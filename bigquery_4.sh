#!/bin/bash

echo ""
echo "🚀 Starting BigQuery Task..."
echo ""

# Set variables
PROJECT_ID=$(gcloud config get-value project)
DATASET_NAME="products"
TABLE_NAME="products_information"
BUCKET_NAME="qwiklabs-gcp-03-873ca497ab9d-bucket"

# ✅ Check if the CSV file exists in the bucket
echo "🔍 Checking for the CSV file in Cloud Storage..."
CSV_FILE=$(gsutil ls "gs://$BUCKET_NAME/" | grep ".csv" | head -n 1)

if [ -z "$CSV_FILE" ]; then
  echo "❌ Error: No CSV file found in gs://$BUCKET_NAME/"
  exit 1
else
  echo "✅ Found CSV file: $CSV_FILE"
fi

# ✅ Upload CSV data to BigQuery Table
echo "📂 Uploading CSV data to BigQuery..."
bq load --source_format=CSV --autodetect "$DATASET_NAME.$TABLE_NAME" "$CSV_FILE"

# ✅ Create a Search Index on All Columns
echo "🔍 Creating Search Index on $TABLE_NAME..."
bq query --use_legacy_sql=false "
CREATE SEARCH INDEX product_search_index
ON $DATASET_NAME.$TABLE_NAME (*);
"

# ✅ Run Query to Search for "22 oz Water Bottle"
echo "🔎 Searching for '22 oz Water Bottle' in all columns..."
bq query --use_legacy_sql=false "
SELECT * FROM $DATASET_NAME.$TABLE_NAME 
WHERE SEARCH(STRUCT(*), '22 oz Water Bottle');
"

echo ""
echo "✅ Task Completed Successfully!"
echo ""
