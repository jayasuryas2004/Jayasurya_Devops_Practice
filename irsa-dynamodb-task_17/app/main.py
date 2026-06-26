import boto3
import os
import time

# Region and Table Name
REGION = os.getenv("AWS_REGION", "us-east-1")
TABLE_NAME = "TaskTable" # The table you created in Phase 1

def test_dynamodb():
    print(f"🚀 Starting DynamoDB IRSA Test on table: {TABLE_NAME}...")
    
    # Boto3 automatically finds the IRSA credentials injected by EKS!
    dynamodb = boto3.resource('dynamodb', region_name=REGION)
    table = dynamodb.Table(TABLE_NAME)

    try:
        # 1. PutItem
        print("\n[1] Putting item into DynamoDB...")
        table.put_item(Item={'id': 'user_001', 'task': 'Example Task', 'status': 'Started'})
        print(" ✅ PutItem successful!")

        # 2. GetItem
        print("\n[2] Getting item from DynamoDB...")
        response = table.get_item(Key={'id': 'user_001'})
        print(f" ✅ GetItem successful! Data: {response.get('Item')}")

        # 3. UpdateItem
        print("\n[3] Updating item in DynamoDB...")
        table.update_item(
            Key={'id': 'user_001'},
            UpdateExpression="set #s = :stat",
            ExpressionAttributeNames={'#s': 'status'},
            ExpressionAttributeValues={':stat': 'Completed'}
        )
        print(" ✅ UpdateItem successful!")

        # Verify Update
        updated_response = table.get_item(Key={'id': 'user_001'})
        print(f" ✅ Verified Update! New Data: {updated_response.get('Item')}")

    except Exception as e:
        print(f"\n❌ Error accessing DynamoDB: {e}")

if __name__ == "__main__":
    test_dynamodb()
    print("\n💤 Sleeping... (Keeping pod alive so we can read the logs)")
    while True:
        time.sleep(60)