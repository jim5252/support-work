# Decompress s3 files Lambda function

## Description 
This Lambda function is used within the support bundle process. Its purpose is to extract log files from the tar file and reupload to a S3 key staged for logstash to ingest.  

## The Script (high level)
![High Level Diagram](https://github.com/appvia/support-bundle/blob/main/terraform/aws/config/lambda-functions/decompress-object/lambda-decompression.png)

## Diagram key
1. The support bundle script is executed by the client and a zip file is uploaded to the input s3 key.  
2. Lambda will detect the object creation within that input prefix and will invoke the lambda function. 
3. This will copy the tar file to the `/tmp` directory. 
4. The tarfile python library is used to extract all files. 
5. The script will then iterate through all files and push to the output s3 key for logstash to ingest and push to Elasticsearch.