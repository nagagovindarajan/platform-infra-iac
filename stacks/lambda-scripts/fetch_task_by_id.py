from phoneno_parser import PhoneNoParser
import json

def lambda_handler(event, context):
    body = json.loads(event.get('body', '{}'))
    task_id = body.get('task_id')
    phoneNoParser = PhoneNoParser() 
    task_result = phoneNoParser.find_task_by_id(task_id)
    return {
        'statusCode': 200,
        'body': task_result
    }