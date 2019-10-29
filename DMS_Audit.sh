#Amazon Database Migration Service - Security Assessment Script
#https://www.cloudconformity.com/knowledge-base/aws/DMS/

for profile in `cat profiles`;do #Iterates through different accounts in your org account. 
	awsoolist > creds_dms #Gets temporary credentials
	for region in `AWS_SHARED_CREDENTIALS_FILE=creds aws ec2 describe-regions --profile $profile --r us-east-1 | jq -r ".Regions[].RegionName"`;do #Iterates through different regions in an account.
		for rep_instance in `AWS_SHARED_CREDENTIALS_FILE=creds_dms aws dms describe-replication-instances --region $region --profile $profile| jq -r ".ReplicationInstances[].ReplicationInstanceArn"`;do #Iterates through different replication instance
		#Check if AutoMinorVersionUpgrade feature is enabled or not - https://www.cloudconformity.com/knowledge-base/aws/DMS/auto-minor-version-upgrade.html
			AutoMinorVersionUpgrade=`AWS_SHARED_CREDENTIALS_FILE=creds_dms aws dms describe-replication-instances --region $region --filters Name=replication-instance-arn,Values=$rep_instance --profile $profile | jq -r ".ReplicationInstances[].AutoMinorVersionUpgrade"`  		
		#Check if the instance is encrypted using AWS or customer KMS key - https://www.cloudconformity.com/knowledge-base/aws/DMS/encrypted-with-cmk.html
			KmsKeyId=`AWS_SHARED_CREDENTIALS_FILE=creds_dms aws dms describe-replication-instances --region $region --filters Name=replication-instance-arn,Values=$rep_instance --profile $profile| jq -r ".ReplicationInstances[].KmsKeyId"`
			KeyManager=`AWS_SHARED_CREDENTIALS_FILE=creds_dms aws kms describe-key --region $region --key-id $KmsKeyId --profile $profile | jq -r ".KeyMetadata.KeyManager"`
		#Check for publicly accessible DMS Instances - https://www.cloudconformity.com/knowledge-base/aws/DMS/publicly-accessible.html
			PubliclyAccessible=`AWS_SHARED_CREDENTIALS_FILE=creds_dms aws dms describe-replication-instances --region $region --filters Name=replication-instance-arn,Values=$rep_instance --profile $profile | jq -r ".ReplicationInstances[].PubliclyAccessible"`
		#Printing the resultants		
			echo "Profile: "$profile 
			echo "Region: "$region
			echo "Replication Instance: "$rep_instance
			echo "AutoMinorVersionUpgradeEnabled? "$AutoMinorVersionUpgrade
			echo "PuliclyAccessible? "$PubliclyAccessible
			echo "KMSKeyID: "$KmsKeyId
			echo "KeyManager: "$KeyManager
			echo "-------------------------------------------------------------"
		done #endloop for different Replication Instance
	done #endloop for different regions
done #endloop for different AWS accounts
