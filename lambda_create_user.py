import boto3
import json
import os
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        body = json.loads(event['body']) if isinstance(event.get('body'), str) else event.get('body', {})
        
        # Validate input
        if not body.get('name') or not body.get('email'):
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'status': 'error',
                    'message': 'name and email are required'
                })
            }
        
        user_id = str(uuid.uuid4())
        user = {
            'id': user_id,
            'name': body['name'],
            'email': body['email'],
            'created_at': datetime.utcnow().isoformat()
        }
        
        table.put_item(Item=user)
        
        return {
            'statusCode': 201,
            'body': json.dumps({
                'status': 'success',
                'user': user
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'status': 'error',
                'message': str(e)
            })
        }