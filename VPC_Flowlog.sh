#Amazon VPC - Security Assessment Script
#https://www.cloudconformity.com/knowledge-base/aws/VPC/

echo "profile region requester_accepter_id VpcId flowlogs NetworkAcls inexgress_output VpcEndpointId PolicyDocument"
for profile in `cat profiles`;do #Iterates through profiles
	awsoolist > creds #Gets temporary credentials
	for region in `AWS_SHARED_CREDENTIALS_FILE=creds aws ec2 describe-regions --profile $profile --r us-east-1 | jq -r ".Regions[].RegionName"`;do #Iterates through regions	
		
		requester_accepter_id=`AWS_SHARED_CREDENTIALS_FILE=cred aws ec2 describe-vpc-peering-connections --region $region --filters Name=status-code,Values=active --query 'VpcPeeringConnections[*].{RequesterId: RequesterVpcInfo.OwnerId, AccepterId:AccepterVpcInfo.OwnerId}' --profile $profile`
		
		#Auditing the policydocument.https://www.cloudconformity.com/knowledge-base/aws/VPC/endpoint-exposed.html
		for VpcEndpointId in `AWS_SHARED_CREDENTIALS_FILE=creds aws ec2 describe-vpc-endpoints --region $region --profile $profile| jq -r ".VpcEndpoints[].VpcEndpointId"`;do #Iterates throught db-snapshots
			PolicyDocument=`AWS_SHARED_CREDENTIALS_FILE=creds aws ec2 describe-vpc-endpoints --vpc-endpoint-ids $VpcEndpointId --region $region --profile $profile | jq -r ".VpcEndpoints[].PolicyDocument"`  
		done
		
		#Checkinng for VPC Flowlogs.https://www.cloudconformity.com/knowledge-base/aws/VPC/vpc-flow-logs-enabled.html
		for VpcId in `AWS_SHARED_CREDENTIALS_FILE=cred aws ec2 describe-vpcs --region $region --profile $profile | jq -r ".Vpcs[].VpcId"`;do
			flowlogs=`AWS_SHARED_CREDENTIALS_FILE=cred aws ec2 describe-flow-logs --region $region --filter "Name=resource-id,Values=$VpcId" --profile $profile`	
		done

		for NetworkAcls in `AWS_SHARED_CREDENTIALS_FILE=cred aws ec2 describe-network-acls --region $region --profile $profile | jq -r ".NetworkAcls[].NetworkAclId"`;do #Fetching Network ACL's
			#Checking the ingress and exgress
			#https://www.cloudconformity.com/knowledge-base/aws/VPC/network-acl-inbound-traffic-all-ports.html
			#https://www.cloudconformity.com/knowledge-base/aws/VPC/network-acl-outbound-traffic-all-ports.html
			inexgress_output=`AWS_SHARED_CREDENTIALS_FILE=cred aws ec2 describe-network-acls --network-acl-ids $NetworkAcls --region $region --profile $profile | jq -r ".NetworkAcls[].Entries[]"`
		done
		echo "$profile $region $requester_accepter_id $VpcId $flowlogs $NetworkAcls $inexgress_output $VpcEndpointId $PolicyDocument"
	done #endloop for different regions
done #endloop for different profiles
