#Amazon DocumentDB - Security Assessment Script
#https://www.cloudconformity.com/knowledge-base/aws/DocumentDB/

for profile in `cat profiles`;do #Iterates through profiles
	echo $profile
	awsoolist > creds #Gets temporary credentials
	for region in `AWS_SHARED_CREDENTIALS_FILE=creds aws ec2 describe-regions --profile $profile --r us-east-1 | jq -r ".Regions[].RegionName"`;do #Iterates through regions	
		for doc_dbcluster in `AWS_SHARED_CREDENTIALS_FILE=creds aws docdb describe-db-clusters --region $region --profile $profile| jq -r ".DBClusters[].DBClusterIdentifier"`;do #Iterates throught db-snapshots
			`AWS_SHARED_CREDENTIALS_FILE=creds aws docdb describe-db-clusters --region $region --db-cluster-identifier $doc_dbcluster --profile $profile > temp_resultant`
			#Checking if storage is encrypted. https://www.cloudconformity.com/knowledge-base/aws/DocumentDB/encrypted-with-cmk.html
      			StorageEncrypted=`cat temp_resultant | jq -r ".DBClusters[].StorageEncrypted"`
			#Checking for the backup retention period.https://www.cloudconformity.com/knowledge-base/aws/DocumentDB/sufficient-backup-retention-period.html
      			BackupRetentionPeriod=`cat temp_resultant | jq -r ".DBClusters[].BackupRetentionPeriod"`
			#Checking if logging is enabled.https://www.cloudconformity.com/knowledge-base/aws/DocumentDB/log-exports.html
      			EnabledCloudwatchLogsExports=`cat temp_resultant | jq -r ".DBClusters[].EnabledCloudwatchLogsExports"`
			#Checking if cluster is encrypted using KMS.https://www.cloudconformity.com/knowledge-base/aws/DocumentDB/encrypted-with-cmk.html
      			KmsKeyId=`cat temp_resultant|  jq -r ".DBClusters[].KmsKeyId"`
			KeyManager=`AWS_SHARED_CREDENTIALS_FILE=creds aws kms describe-key --region $region --key-id $KmsKeyId --profile $profile | jq -r "KeyMetadata.KeyManager"`
			echo $profile $region $doc_dbcluster $StorageEncrypted $EnabledCloudwatchLogsExports $KmsKeyId $KeyManager
			echo "-------------------------------------------------------------"
		done
	done #endloop for different regions
done #endloop for different profiles
