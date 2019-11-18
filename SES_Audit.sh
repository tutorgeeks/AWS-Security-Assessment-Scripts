#Amazon SES - Security Assessment Script
#https://www.cloudconformity.com/knowledge-base/aws/SES/

echo "Profile Region Encrypted Policy"
for profile in `cat profiles`;do #Iterates through profiles
	awsoolist > creds #Gets temporary credentials
	for region in `AWS_SHARED_CREDENTIALS_FILE=creds aws ec2 describe-regions --profile $profile --r us-east-1 | jq -r ".Regions[].RegionName"`;do #Iterates through regions	
		echo $profile $region
		for identies in `AWS_SHARED_CREDENTIALS_FILE=creds aws ses list-identities --region $region --profile $profile | jq -r ".Identities[]"`;do #Iterates throught db-snapshots
			Attributes=`AWS_SHARED_CREDENTIALS_FILE=creds aws ses get-identity-dkim-attributes --identities $identies --region $region --profile $profile`  
			for identity_policies in `AWS_SHARED_CREDENTIALS_FILE=creds aws ses list-identity-policies --identity $identies --region $region --profile $profile | jq -r ".PolicyNames[]"`;do
				resultant=`AWS_SHARED_CREDENTIALS_FILE=creds aws ses get-identity-policies --region $region --identity $identies --policy-names $identity_policies`
				echo $profile $region $identies $identity_policies $resultant
			done
		done
	done #endloop for different regions
done #endloop for different profiles
