
---

````md
# OpenSearch Index Reset Instructions for Syriaca

This guide walks you through the full process of resetting and re-ingesting the OpenSearch indices for:

- `syriaca-index-12`

The indices are backed by newline-delimited JSON (`.ndjson`) or (`.json`) files in S3 and loaded via a Lambda function that performs bulk indexing.
---

## 📥 Step 1: Upload New JSON Data to S3

1. Prepare your JSON files:

Run the github workflow "batch_loading.yaml" file for each file type and also the cbss batch loading workflow file. They can be run from Actions or by commiting changes to the files.

---

## ⚙️ Step 2: Confirm Environment Variables for Lambda

Ensure the following environment variables are correctly set in your ingestion Lambda function:

| Variable              | Description                        |
| --------------------- | ---------------------------------- |
| `OPENSEARCH_URL`      | Full URL to the OpenSearch cluster |
| `OPENSEARCH_USER`     | Basic Auth username                |
| `OPENSEARCH_PASSWORD` | Basic Auth password                |

These values may be stored in plaintext in the Lambda config or injected via secrets.

---

## 🏗️ Step 4: Trigger the Lambda

Trigger the Lambda by uploading the file to the S3 `json-data` prefix (if set up as S3 event source), or manually via test event:

<details>
<summary>Sample test event for manual Lambda trigger</summary>

```json
{
  "Records": [
    {
      "s3": {
        "bucket": {
          "name": "your-bucket"
        },
        "object": {
          "key": "json-data/syriaca-index-12_2025-10-21.json"
        }
      }
    }
  ]
}
```

</details>


---

## 🧪 Step 5: Verify Index Creation and Data Import

You can test whether the data has been successfully indexed using the following OpenSearch queries:

### Review from terminal

```bash
# Replace with your OpenSearch endpoint
ENDPOINT="https://your-opensearch-endpoint"

# Basic auth
USER="your-user"
PASS="your-password"
```

```bash
curl -u $USER:$PASS "$ENDPOINT/syriaca-index-12/_search?q=*" | jq
```

Or issue a simple match-all query:

```bash
curl -X POST "$ENDPOINT/syriaca-index-12/_search" -u $USER:$PASS -H 'Content-Type: application/json' -d '{"query": {"match_all": {}}, "size": 1}'
```

---

## 🐛 Common Errors

| Error                          | Cause                 | Solution                                        |
| ------------------------------ | --------------------- | ----------------------------------------------- |
| `401 Unauthorized`             | Incorrect credentials | Verify environment variables in Lambda and curl |
| `index_not_found_exception`    | Index not yet created | Confirm Lambda ran successfully                 |
| `413 Request Entity Too Large` | Bulk payload too big  | Reduce `chunk_size` in Lambda (default = 100)   |
| `429 Too Many Requests`        | Rate limited          | Add retry + backoff (already in Lambda)         |

* Ensure your OpenSearch domain access policy allows access from your Lambda's execution role.

---

## 📁 Related Files

* `openSearchLoadingS3.py` – Lambda function to load data from s3 into OpenSearch
* `s3://your-bucket/json-data/` – Source of JSON files
* OpenSearch indices: `mappings`

---

## 🧼 Optional: Clean Up Failed Chunks

Failed chunks are saved to:

```
s3://your-bucket/error-logs/
```

You can reprocess these manually or inspect them to debug problematic entries.

---

```
