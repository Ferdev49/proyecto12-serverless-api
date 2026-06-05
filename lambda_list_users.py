import boto3
import json
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        response = table.scan()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'status': 'success',
                'users': response.get('Items', []),
                'count': response.get('Count', 0)
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