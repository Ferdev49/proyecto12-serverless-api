import boto3
import json
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        user_id = event['pathParameters']['id']
        body = json.loads(event['body']) if isinstance(event.get('body'), str) else event.get('body', {})
        
        # Check if user exists
        response = table.get_item(Key={'id': user_id})
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': json.dumps({
                    'status': 'error',
                    'message': f'User {user_id} not found'
                })
            }
        
        # Update user
        update_expression = 'SET '
        expression_values = {}
        
        if 'name' in body:
            update_expression += 'name = :name, '
            expression_values[':name'] = body['name']
        
        if 'email' in body:
            update_expression += 'email = :email, '
            expression_values[':email'] = body['email']
        
        update_expression += 'updated_at = :updated_at'
        expression_values[':updated_at'] = datetime.utcnow().isoformat()
        
        table.update_item(
            Key={'id': user_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_values
        )
        
        # Get updated user
        updated = table.get_item(Key={'id': user_id})
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'status': 'success',
                'user': updated['Item']
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