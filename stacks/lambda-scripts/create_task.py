import json
from phoneno_parser import PhoneNoParser
import base64

def lambda_handler(event, context):
    try:
        decoded_content = ''
        body_content = event.get('body', '')
        print('data received in lamda ')
        
        try:
            # Try decoding as base64
            decoded_content = base64.b64decode(body_content)

        except base64.binascii.Error:
            # If it's not base64 encoded, use the original bytes
            print('cant decode base64')
            decoded_content = body_content

        phoneNoParser = PhoneNoParser() 
        phoneNoParser.extract_data(decoded_content)
        phoneNoParser.transform_data()
        load_data_response = phoneNoParser.load_data()
        print(load_data_response)
        return {
            'statusCode': 200,
            'body': load_data_response
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
