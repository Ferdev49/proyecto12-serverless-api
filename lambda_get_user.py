import boto3
import json
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        user_id = event['pathParameters']['id']
        
        response = table.get_item(Key={'id': user_id})
        
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': json.dumps({
                    'status': 'error',
                    'message': f'User {user_id} not found'
                })
            }
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'status': 'success',
                'user': response['Item']
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