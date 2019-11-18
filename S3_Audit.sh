#Amazon s3 bucket - Security Assessment Script
#https://www.cloudconformity.com/knowledge-base/aws/S3/

for profile in `cat profiles`;do #Iterates through different accounts in your org account.
	awsoolist > creds_bucket #Gets temporary credentials
		for buckets in `AWS_SHARED_CREDENTIALS_FILE=creds_bucket aws s3api list-buckets --profile $profile | jq -r ".Buckets[].Name"`;do #Fetch the s3 buckets from an account
			bucket_policy=`AWS_SHARED_CREDENTIALS_FILE=creds_bucket aws s3api get-bucket-acl --bucket $buckets --profile $profile | jq -r ".Grants[].Grantee.URI"`  #Fetch the bucket policy of a particular s3 bucket.
			echo $profile $buckets $bucket_policy
		done
done
