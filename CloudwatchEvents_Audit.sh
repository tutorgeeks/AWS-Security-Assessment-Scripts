#Amazon Cloudwatch Events - Security Assessment Script
#https://www.cloudconformity.com/knowledge-base/aws/CloudWatchEvents/

echo "Profile Region Policy"
for profile in `cat profiles`;do #Iterates through profiles
	awsoolist > creds_cloud_watch #Gets temporary credentials
	for region in `AWS_SHARED_CREDENTIALS_FILE=creds_cloud_watch aws ec2 describe-regions --profile $profile --r us-east-1 | jq -r ".Regions[].RegionName"`;do #Iterates through regions	
			#rules=`AWS_SHARED_CREDENTIALS_FILE=creds aws events list-rules --region $region --profile $profile| jq -r ".Rules[].Name"` #Fetch the rule
			#Auditing the event policy
			#Public Exposure.https://www.cloudconformity.com/knowledge-base/aws/CloudWatchEvents/event-bus-exposed.html
			#Cross Account access.https://www.cloudconformity.com/knowledge-base/aws/CloudWatchEvents/event-bus-cross-account-access.html
			policy=`AWS_SHARED_CREDENTIALS_FILE=creds_cloud_watch aws events describe-event-bus --region $region --profile $profile | jq -r ".Policy"` #Fetch the policy
			echo $profile $region $policy  
	done #endloop for different regions
done #endloop for different profiles
