#!/bin/bash

echo ""
echo "🚀 Starting BigQuery CSV Upload and Search Task..."
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

# ✅ Upload CSV data to the existing BigQuery Table
echo "📂 Uploading CSV data to BigQuery Table: $DATASET_NAME.$TABLE_NAME..."
bq load --source_format=CSV --autodetect --replace "$DATASET_NAME.$TABLE_NAME" "$CSV_FILE"

if [ $? -eq 0 ]; then
  echo "✅ CSV data uploaded successfully!"
else
  echo "❌ Error: Failed to upload CSV data."
  exit 1
fi

# ✅ Verify that data is fetched using SEARCH function
echo "🔎 Searching for '22 oz Water Bottle' in all columns..."
bq query --use_legacy_sql=false "
SELECT * FROM \`$DATASET_NAME.$TABLE_NAME\`
WHERE SEARCH(STRUCT(*), '22 oz Water Bottle');
"

echo ""
echo "✅ Task Completed Successfully!"
echo ""
