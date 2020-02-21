#Amazon Active Directory - Security Assessment Script
#https://www.cloudconformity.com/knowledge-base/aws/WorkDocs/mfa-enabled.html

echo "Profile Region DescribeDirectories RadiusStatus"
for profile in `cat profiles`;do #Iterates through profiles
	awsoolist role > creds #Gets temporary credentials
	for region in `AWS_SHARED_CREDENTIALS_FILE=creds aws ec2 describe-regions --profile $profile --r us-east-1 | jq -r ".Regions[].RegionName"`;do #Iterates through regions	
		for DescribeDirectories in `AWS_SHARED_CREDENTIALS_FILE=creds aws ds describe-directories --region $region --profile $profile | jq -r ".DirectoryDescriptions[].DirectoryId"`;do #Iterates through Active directories
			RadiusStatus=`AWS_SHARED_CREDENTIALS_FILE=creds1 aws ds describe-directories --region $region --directory-ids $DescribeDirectories | jq -r ".DirectoryDescriptions[].RadiusStatus"` #MFACheck
			echo $profile $region $DescribeDirectories $RadiusStatus
		done #Forloop for Active directories
	done #Forloop for regions
done #Forloop for profiles
