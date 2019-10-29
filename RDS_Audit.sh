# Amazon RDS - Security Assessment Script
# https://www.cloudconformity.com/knowledge-base/aws/RDS/

for profile in `cat profiles`;do #Iterates through profiles
	awsoolist > creds_rds #Gets temporary credentials
	for region in `AWS_SHARED_CREDENTIALS_FILE=creds_rds aws ec2 describe-regions --profile  $profile --r us-east-1 | jq -r ".Regions[].RegionName"`;do #Iterates through regions	
		for db_snapshots in `AWS_SHARED_CREDENTIALS_FILE=creds_rds aws rds describe-db-snapshots --region $region --profile $profile | jq -r ".DBSnapshots[].DBSnapshotIdentifier"`;do #Iterates throught db-snapshots
			#Testing for RDS PublicSnapshots
			public_snapshots=`AWS_SHARED_CREDENTIALS_FILE=creds_rds aws rds describe-db-snapshot-attributes --region $region --db-snapshot-identifier $db_snapshots --profile $profile | jq -r ".DBSnapshotAttributesResult.DBSnapshotAttributes[].AttributeValues"`  
			echo $profile $region $db_snapshots "RDSPublicSnapshots:" $public_snapshots
		done #endloop for different snapshots
		for db_instances in `AWS_SHARED_CREDENTIALS_FILE=creds_rds aws rds describe-db-instances --region $region --profile $profile | jq -r ".DBInstances[].DBInstanceIdentifier"`;do
			#Testing for RDS Encryption enablement 
			instance_types=`AWS_SHARED_CREDENTIALS_FILE=creds_rds aws rds describe-db-instances --region $region --profile $profile | jq -r ".DBInstances[].DBInstanceClass"`
			`AWS_SHARED_CREDENTIALS_FILE=creds_rds aws rds describe-db-instances --region $region --db-instance-identifier $db_instances --profile $profile > describe_db_instances_temp`
			echo $profile $region $db_instances "StorageEncrypted:" `cat describe_db_instances_temp | jq -r ".DBInstances[].StorageEncrypted"`
			#Testing for publicly accessible RDS database
			echo $profile $region $db_instances "PubliclyAccessible:" `cat describe_db_instances_temp | jq -r ".DBInstances[].PubliclyAccessible"`
			#Testing for IAM Database Authentication
			echo $profile $region $db_instances "IAMDatabaseAuthenticationEnabled:"  `cat describe_db_instances_temp | jq -r ".DBInstances[].IAMDatabaseAuthenticationEnabled"` 
			#Testing for RDS Deletion protection"
			echo $profile $region $db_instances "DeletionProtection:" `cat describe_db_instances_temp | jq -r ".DBInstances[].DeletionProtection"`
			#Testing for RDS Backup Retention Period"
			echo $profile $region $db_instances "BackupRetentionPeriod:" `cat describe_db_instances_temp | jq -r ".DBInstances[].BackupRetentionPeriod"`
			#Testing for performance insights"
			echo $profile $region $db_instances "PerformanceInsightsEnabled:" `cat describe_db_instances_temp | jq -r ".DBInstances[].PerformanceInsightsEnabled"`
			#Testing for RDS Auto Minor Version Upgrade
			echo $profile $region $db_instances "RDSAutoMinorVersionUpgrade:" `cat describe_db_instances_temp | jq -r ".DBInstances[].AutoMinorVersionUpgrade"`
			#Testing for RDS Copy Tags to Snapshots
			echo $profile $region $db_instances "CopyTagsToSnapshot:" `cat describe_db_instances_temp | jq -r ".DBInstances[].CopyTagsToSnapshot"`
			#Checking if CloudWatch is enabled
			echo $profile $region $db_instances "EnabledCloudwatchLogsExports:" `cat describe_db_instances_temp | jq -r ".DBInstances[].EnabledCloudwatchLogsExports"`
			#Checking RDS Port
			echo $profile $region $db_instances "Port:" `cat describe_db_instances_temp | jq -r ".DBInstances[].Endpoint.Port"`
			#Checking RDS MasterUserName
			echo $profile $region $db_instances "MasterUsername:" `cat describe_db_instances_temp | jq -r ".DBInstances[].MasterUsername"`
			rm describe_db_instances_temp
			echo $profile $region $db_instances "InstanceTypes":$instance_types
			echo "-------------------------------------------------------------"
		done
	done #endloop for different regions
done #endloop for different profiles
