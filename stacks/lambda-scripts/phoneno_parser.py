import re
import boto3
import uuid
from datetime import datetime

# Regular expression pattern for German phone numbers
pattern = r'(\+49\d{11}|0049\d{11})'
bucket_name = 'german-phonenos'
table_name = 'german-phonenos'
region_name='ap-southeast-1'

class PhoneNoParser:

    def __init__(self):
        self.s3 = boto3.client("s3", region_name=region_name)
        self.dynamodb = boto3.client("dynamodb", region_name=region_name)
        self.dynamodb_resource = boto3.resource('dynamodb', region_name=region_name)

    def extract_data(self, file_content_str):        
        lines = file_content_str.splitlines()
        print("Lines in file:", len(lines))

        unique_lines = set()
        result_list = []
        
        for line in lines:
            line = line.strip().replace(" ", "") # Remove leading, trailing whitespaces and space
            
            if line and line not in unique_lines:  # Ignore empty and duplicate lines
                unique_lines.add(line)
                result_list.append(line)

        self.extracted_data = result_list 
        print("No of raw phone numbers ", len(self.extracted_data))


    def transform_data(self):
        self.german_numbers = []

        for string in self.extracted_data:
            matches = re.findall(pattern, string)
            if len(matches) > 0:
                self.german_numbers.extend(matches)

        print("transformed data list ", len(self.german_numbers))


    def load_data(self):
        unique_id = str(uuid.uuid1())
        file_name = unique_id+".txt"
        comma_sep_numbers = ', '.join(self.german_numbers)

        with open("/tmp/"+file_name, "w") as f:
            f.write(f"{comma_sep_numbers}")
        print('File generated')
        
        current_timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        self.s3.upload_file("/tmp/"+file_name, bucket_name, file_name)
        print('File uploaded ',file_name)

        response = self.dynamodb.put_item(
            TableName = table_name,
            Item={
                'task_id': {'S': unique_id},
                's3_reference': {'S': file_name},
                'timestamp': {'S': current_timestamp}
            }
        )
        print("Dynamo DB resposne ", response)
        return "Task Id "+unique_id+" created"
    

    def find_all_tasks(self):
        table = self.dynamodb_resource.Table(table_name)
        response = table.scan()
        all_task_ids = []

        for item in response['Items']:
            if 'task_id' in item:
                all_task_ids.append(item['task_id'])
        
        return all_task_ids

    
    def find_task_by_id(self, task_id):
        table = self.dynamodb_resource.Table(table_name)

        s3_file_name = self.get_s3_file_name_by_task_id(table, task_id)

        if s3_file_name:
            print("Item found:", s3_file_name)
            response = self.s3.get_object(Bucket=bucket_name, Key=s3_file_name)
            file_content = response['Body'].read()
            file_as_string = file_content.decode('utf-8')
            return file_as_string

        else:
            return "Invalid Task Id!"


    def delete_task_by_id(self, task_id):
        table = self.dynamodb_resource.Table(table_name)

        s3_file_name = self.get_s3_file_name_by_task_id(table, task_id)

        response = self.s3.delete_object(
            Bucket=bucket_name,
            Key=s3_file_name
        )

        # Check if the delete was successful
        if response['ResponseMetadata']['HTTPStatusCode'] == 204:
            print(f"Successfully deleted {s3_file_name} from {bucket_name}.")
            
            response = table.delete_item(
                Key={
                    'task_id': task_id
                }
            )

            if response['ResponseMetadata']['HTTPStatusCode'] == 200:
                return "Successfully deleted item with task_id: "+task_id
            else:
                return "Failed to delete table item."
            
        else:
            return "Failed to delete the s3 file."



    def get_s3_file_name_by_task_id(self, table, task_id):
        response = table.get_item(
            Key={
                'task_id': task_id
            }
        )

        item = response.get('Item', None)

        if item:
            s3_reference = item.get('s3_reference', "")
            if s3_reference:
                return s3_reference

        return ""