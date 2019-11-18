#Amazon VPC - Flowlog Security Assessment Script
#https://www.cloudconformity.com/knowledge-base/aws/VPC/vpc-flow-logs-enabled.html

for profile in `cat profiles`;do #Iterates through profiles
	awsoolist > creds #Gets temporary credentials
	for region in `AWS_SHARED_CREDENTIALS_FILE=creds aws ec2 describe-regions --profile $profile --r us-east-1 | jq -r ".Regions[].RegionName"`;do #Iterates through regions
		for VpcId in `AWS_SHARED_CREDENTIALS_FILE=cred aws ec2 describe-vpcs --region $region --profile $profile | jq -r ".Vpcs[].VpcId"`;do #Iterates through VPCID's
			#Checking if flowlog is enabled.https://www.cloudconformity.com/knowledge-base/aws/VPC/vpc-flow-logs-enabled.html
			flowlogs=`AWS_SHARED_CREDENTIALS_FILE=cred aws ec2 describe-flow-logs --region $region --filter "Name=resource-id,Values=$VpcId" --profile $profile`	
			echo $profile $region $VpcId $flowlogs
		done
	done #endloop for different regions
done #endloop for different profiles
