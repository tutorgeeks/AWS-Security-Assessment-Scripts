#Amazon SNS - SNS Subscription Assessment Script
#https://www.cloudconformity.com/knowledge-base/aws/SNS/appropriate-subscribers.html

for profile in `cat profiles`;do #Iterates through profiles
	awsoolist > creds #Gets temporary credentials
	  for region in `AWS_SHARED_CREDENTIALS_FILE=creds aws ec2 describe-regions --profile $profile --r us-east-1 | jq -r ".Regions[].RegionName"`;do #Iterates through regions	
		    for subscriptions in `AWS_SHARED_CREDENTIALS_FILE=creds aws sns list-subscriptions --region $region --profile $profile | jq -r ".Subscriptions[].SubscriptionArn"`;do #Fetch SubscriptionArn
			  #Checking for appropriate subscribers.https://www.cloudconformity.com/knowledge-base/aws/SNS/appropriate-subscribers.html
        subscription_attributes=`AWS_SHARED_CREDENTIALS_FILE=creds aws sns get-subscription-attributes --region $region --subscription-arn $subscriptions --profile $profile` #Fetch Subscription Attributes
			  echo $profile $region $subscriptions $subscription_attributes
        done
	  done #endloop for different regions
done #endloop for different profiles
