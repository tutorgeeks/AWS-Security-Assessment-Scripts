#Amazon SNS - SNS Security Assessment Script
#https://www.cloudconformity.com/knowledge-base/aws/SNS/

echo "Profile Region Encrypted Policy"
for profile in `cat profiles`;do #Iterates through profiles
	awsoolist > creds #Gets temporary credentials
	for region in `AWS_SHARED_CREDENTIALS_FILE=creds aws ec2 describe-regions --profile $profile --r us-east-1 | jq -r ".Regions[].RegionName"`;do #Iterates through regions	
		for topics in `AWS_SHARED_CREDENTIALS_FILE=creds aws sns list-topics --region $region --profile $profile| jq -r ".Topics[].TopicArn"`;do #Fetch SNS topics
			#Auditing the SNS policy
			#https://www.cloudconformity.com/knowledge-base/aws/SNS/sns-topic-exposed.html
			#https://www.cloudconformity.com/knowledge-base/aws/SNS/sns-cross-account-access.html
			#https://www.cloudconformity.com/knowledge-base/aws/SNS/topics-everyone-publish.html
			Policy=`AWS_SHARED_CREDENTIALS_FILE=creds aws sns get-topic-attributes --topic-arn $topics --region $region --query 'Attributes.Policy' --profile $profile`  
			#Checking if SNS is encrypted.https://www.cloudconformity.com/knowledge-base/aws/SNS/server-side-encryption.html
			Encrypted=`AWS_SHARED_CREDENTIALS_FILE=creds aws sns get-topic-attributes --topic-arn $topics --region $region --query 'Attributes.KmsMasterKeyId' --profile $profile`
			echo $profile $region $topics $Encrypted $Policy
		done
	done #endloop for different regions
done #endloop for different profiles
