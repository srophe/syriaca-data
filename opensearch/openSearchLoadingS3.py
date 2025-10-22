import urllib.request
import json
import time
import boto3
import os
import base64


# OpenSearch Configuration
OPENSEARCH_URL = os.getenv("OPENSEARCH_URL")
OPENSEARCH_USER = os.getenv("OPENSEARCH_USER")
OPENSEARCH_PASSWORD = os.getenv("OPENSEARCH_PASSWORD")

# S3 Configuration
# S3_BUCKET_NAME = os.getenv("S3_BUCKET")

# AWS S3 Client
s3_client = boto3.client("s3")

def load_json_from_s3(bucket, key):
    """Fetch JSON file from S3."""
    response = s3_client.get_object(Bucket=bucket, Key=key)
    return response["Body"].read().decode("utf-8")


def bulk_index(data, opensearch_url, username, password):
    """Send data to OpenSearch in bulk."""
    headers = {"Content-Type": "application/json"}
    request = urllib.request.Request(
        f"{opensearch_url}/_bulk",
        data=data.encode("utf-8"),
        headers=headers,
        method="POST"
    )
    auth = f"{username}:{password}".encode("utf-8")
    # request.add_header("Authorization", f"Basic {urllib.request.base64.b64encode(auth).decode('utf-8')}")
    request.add_header("Authorization", f"Basic {base64.b64encode(auth).decode('utf-8')}")

    try:
        with urllib.request.urlopen(request) as response:
            response_data = response.read().decode("utf-8")
            return {
                "status_code": response.getcode(),
                "body": json.loads(response_data)
            }
    except urllib.error.HTTPError as e:
        return {
            "status_code": e.code,
            "body": e.read().decode("utf-8")
        }
    except Exception as e:
        return {
            "status_code": 500,
            "body": str(e)
        }

def lambda_handler(event, context):
    try:
        S3_KEY = event['Records'][0]['s3']['object']['key']
        S3_BUCKET_NAME = event['Records'][0]['s3']['bucket']['name']

      bulk_data = load_json_from_s3(S3_BUCKET_NAME, S3_KEY)
        entries = bulk_data.strip().split("\n")  # Ensure newline-delimited JSON
        chunk_size = 100

        for i in range(0, len(entries), chunk_size):
            chunk = "\n".join(entries[i:i+chunk_size]) + "\n"
            print(f"Uploading chunk {i//chunk_size + 1}...")

            response = bulk_index(chunk, OPENSEARCH_URL, OPENSEARCH_USER, OPENSEARCH_PASSWORD)

            if response["status_code"] == 429:
                print("Too many requests. Retrying after delay...")
                time.sleep(60)
                continue
            elif response["status_code"] >= 400:
                print(f"Error indexing chunk {i//chunk_size + 1}: {response['body']}")
                s3_client.put_object(
                    Bucket=S3_BUCKET_NAME,
                    Key=f"error-logs/failed_raw_chunk_{i}.json",
                    Body=chunk.encode("utf-8")
                )
            else:
                body = response["body"]
                if body.get("errors"):
                    print(f"❌ Errors occurred while indexing chunk {i//chunk_size + 1} from {S3_KEY}")
                    
                    failed_docs = []
                    for item in body["items"]:
                        action_type = next(iter(item))
                        action = item[action_type]
                        if "error" in action:
                            doc_id = action.get("_id", "unknown-id")
                            error = action["error"]
                            error_type = error.get("type", "unknown-error")
                            reason = error.get("reason", "no reason provided")

                            # Try to extract the field name from caused_by
                            caused_by = error.get("caused_by", {})
                            field = caused_by.get("field", "unknown field")
                            caused_by_reason = caused_by.get("reason", "")

                            print(f"❌ Failed to index document ID: {doc_id}")
                            print(f"   Error: {error_type} — {reason}")
                            if caused_by_reason:
                                print(f"   Caused by: {caused_by_reason}")
                            if field != "unknown field":
                                print(f"   Problematic field: {field}")

                            failed_docs.append({
                                "id": doc_id,
                                "error_type": error_type,
                                "reason": reason,
                                "caused_by": caused_by,
                                "field": field
                            })

                    # Save failed docs to S3 for debugging (optional)
                    s3_client.put_object(
                        Bucket=S3_BUCKET_NAME,
                        Key=f"error-logs/failed_chunk_{i}.json",
                        Body=json.dumps(failed_docs, indent=2).encode("utf-8")
                    )

            time.sleep(2)

    except Exception as e:
        print(f"Unhandled exception: {e}")

