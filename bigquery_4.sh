#!/bin/bash

echo ""
echo "Welcome to Google Cloud BigQuery & Cloud Spanner Integration!"
echo ""

# Prompt user for REGION
read -p "Enter REGION: " REGION

# Get the current GCP Project ID
export PROJECT_ID=$(gcloud projects list --format="value(PROJECT_ID)")

# Create a BigQuery connection to Cloud Spanner
bq mk --connection \
    --connection_type='CLOUD_SPANNER' \
    --properties='{"database":"projects/'$PROJECT_ID'/instances/ecommerce-instance/databases/ecommerce"}' \
    --location=$REGION \
    my_connection_id

# Run an External Query to fetch data from Cloud Spanner
bq query --use_legacy_sql=false "
SELECT * FROM EXTERNAL_QUERY('$PROJECT_ID.$REGION.my_connection_id', 'SELECT * FROM orders;');
"

# Create a BigQuery View from Cloud Spanner data
bq query --use_legacy_sql=false "
CREATE OR REPLACE VIEW ecommerce.order_history AS 
SELECT * FROM EXTERNAL_QUERY('$PROJECT_ID.$REGION.my_connection_id', 'SELECT * FROM orders;');
"

echo ""
echo "✅ Integration Complete! You can now query 'ecommerce.order_history' in BigQuery."
echo ""
