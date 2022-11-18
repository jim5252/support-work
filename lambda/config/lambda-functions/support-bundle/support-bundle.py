import logging
import boto3
from botocore.exceptions import ClientError
import os
import json
from datetime import date
import subprocess
import sys 

# pip install custom package to /tmp/ and add to path # found on net as work around need to tidy
subprocess.call('pip install atlassian-python-api -t /tmp/ --no-cache-dir'.split(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
sys.path.insert(1, '/tmp/')
from atlassian import ServiceDesk

#Global Args to be parsed when executing script. 
format = "%(asctime)s: %(levelname)s - %(message)s"
logging.basicConfig(format=format, level=logging.INFO, datefmt="%H:%M:%S")
today = date.today()
day = today.strftime("%d-%m-%Y")

def generate_presigned_url(s3_client, client_method, method_parameters, expires_in):
    try:
        url = s3_client.generate_presigned_url(
            ClientMethod=client_method,
            Params=method_parameters,
            ExpiresIn=expires_in
        )
    except ClientError:
        logger.exception(
            "Couldn't get a presigned URL for client method '%s'.", client_method)
        raise
    return url

def create_script_file(put_url, customer):
    # Read in the file
    with open('kore-support-bundle.tpl', 'r') as file :
      template = file.read()
    template = template.replace('S3_PUT_URL', put_url)
    with open('/tmp/'+customer+'_kore-support-bundle', 'w') as file:
      file.write(template)
    
def upload_to_s3(customer, ticket, file_name, bucket, object_name=None):
    if object_name is None:
        object_name = file_name
    s3_client = boto3.client('s3')
    try:
        response = s3_client.upload_file(file_name, bucket, 'appvia-support/scripts/' + customer + '/' + ticket + '/' + customer + '_kore-support-bundle')
    except ClientError as e:
        logging.error(e)
        return False
    return True

def upload_to_jira(ticket, comment):
    jira_username = os.environ.get('JIRA_USER')
    jira_api_token = os.environ.get('JIRA_TOKEN')
    sd = ServiceDesk(
        url='https://appvia.atlassian.net/',
        username=jira_username,
        password=jira_api_token,
        cloud=True)
    sd.create_request_comment(ticket, comment, public=False)

def lambda_handler(event, context):
    body = json.loads(event['body'])
    ticket = body['key']
    try:
        org = body['fields']['customfield_10002'][0]['name']
        customer = org.lower()
    except: 
        print("No organization provided in request payload, setting customer to private.")
        customer = "private"
    bucket = os.environ.get('S3_BUCKET')
    logging.info("Generating the pre signed urls to access the script.")
    # generate presigned links to access script and upload log files to. 
    s3_client = boto3.client('s3')
    get_url = generate_presigned_url(
        s3_client, 'get_object', {'Bucket':  bucket,
         'Key': 'appvia-support/scripts/' + customer + '/' + ticket + '/' + customer + '_kore-support-bundle'},
          259200)
    put_url = generate_presigned_url(
        s3_client, 'put_object', {'Bucket': bucket,
         'Key': 'appvia-support/input/' + customer + '/' + ticket + '/' + day + '/support-bundle.tar.gz'},
          259200)
    create_script_file(put_url, customer)
    logging.info("uploading customer script to S3 ready to be accessed.")
    upload_to_s3(customer, ticket,'/tmp/'+customer+'_kore-support-bundle',  bucket)
    os.remove('/tmp/'+customer+'_kore-support-bundle')
    logging.info("uploading pre-signed url to jira.")
    upload_to_jira(ticket, "Link to bundle script: %s" % get_url)
