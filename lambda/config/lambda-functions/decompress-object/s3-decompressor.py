import boto3
import botocore
import tarfile
import glob 

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    tmp_key = key.replace("input","output")                                   # Update 'input' to 'output' in s3 key. 
    new_key = tmp_key[0:tmp_key.rfind("/")+1]                                 # Strip the file name from s3 key in preparation to upload new files.
    print(new_key)
    s3 = boto3.resource('s3')
    s3.meta.client.download_file(bucket, key, '/tmp/support-bundle.tar.gz')   # Download to lambda tmp directory
    tar = tarfile.open('/tmp/support-bundle.tar.gz', "r:gz")                  # Open and extract files from zip file
    tar.extractall(path="/tmp/")
    tar.close()
    file_list = glob.glob('/tmp/support_bundle/*.log')                        # List extracted files in directory
    print(file_list)                           
    for files in file_list:                                                   # Iterate through files and upload individually to new generated s3 key.
        file_name = files[files.rfind("/")+1:]                                # Strip the file name from file list to upload the correctly to s3.
        s3.meta.client.upload_file(files, bucket, new_key + file_name)
