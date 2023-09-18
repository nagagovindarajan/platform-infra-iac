from phoneno_parser import PhoneNoParser

def lambda_handler(event, context):
    phoneNoParser = PhoneNoParser() 
    all_task_ids = phoneNoParser.find_all_tasks()
    print("All task_ids: ", all_task_ids)
    return {
        'statusCode': 200,
        'body': str(all_task_ids)
    }