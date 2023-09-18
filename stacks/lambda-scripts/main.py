from phoneno_parser import PhoneNoParser

import base64

def file_to_base64(file_path):
    try:
        with open(file_path, 'rb') as file:
            file_bytes = file.read()            
            base64_string = base64.b64encode(file_bytes)          
            return base64_string
            
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def test_submit():
    file_path = '/home/orangepi/Documents/git/german-phones-parser-iac/test-data/phone_numbers_1.txt'
    base64_string = file_to_base64(file_path)
    file_content = base64.b64decode(base64_string).decode('utf-8')
    phoneNoParser = PhoneNoParser() 
    phoneNoParser.extract_data(file_content)
    phoneNoParser.transform_data()
    load_data_response = phoneNoParser.load_data()
    print(load_data_response)


def test_list():
    phoneNoParser = PhoneNoParser() 
    all_task_ids = phoneNoParser.find_all_tasks()
    print("All task_ids: ", all_task_ids)

def test_find_by_id():
    phoneNoParser = PhoneNoParser() 
    task_result = phoneNoParser.find_task_by_id("b54d13d8-4fef-11ee-a454-26a0a098dd65")
    print("Result: ", task_result)

def test_delete_by_id():
    phoneNoParser = PhoneNoParser() 
    delete_response = phoneNoParser.delete_task_by_id('b70cf8d9-4f33-11ee-930d-d49e0bfc1e34')
    print("delete_response: ", delete_response)

def main():
    # test_submit()
    test_list()
    test_find_by_id()
    # test_delete_by_id()
    

if __name__ == "__main__":
    main()