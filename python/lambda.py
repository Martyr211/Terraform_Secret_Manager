import boto3
import secrets
import string
import random
import json

def lambda_handler(event, context):

    client = boto3.client('secretsmanager')
    
    #Random Password Generator
    password = list(''.join((secrets.choice(string.ascii_letters + string.digits) for i in range(16))))
    random.shuffle(password)
    password = ''.join(password)

    response = client.get_secret_value(
        SecretId=event['SecretId']
    )

    response = json.loads(response['SecretString'])
    response['password'] = password
    
    response = client.put_secret_value(
        SecretId=event['SecretId'],
        SecretString=json.dumps(response)
    )
    
    return response


