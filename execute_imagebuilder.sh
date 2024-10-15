#!/bin/bash
# "AVAILABLE" is desired end state for the image builder pipeline

export CDK_STACK_BASE_NAME_LOWER="tekpossible-stratagem"
export IMAGE_PIPELINE_ARN=$(aws ssm get-parameter --name $CDK_STACK_BASE_NAME_LOWER-imagebuilder-arn --query 'Parameter.Value' | sed 's/"//g')
export IMAGE_VERSION_ARN=$(aws imagebuilder start-image-pipeline-execution --image-pipeline-arn $IMAGE_PIPELINE_ARN --query 'imageBuildVersionArn' | sed 's/"//g')
export IMAGE_STATE=$(aws imagebuilder get-image --image-build-version-arn $IMAGE_VERSION_ARN --query 'image.state.status'  | sed 's/"//g')
echo "The Image Builder Pipeline started. Please go to the imagebuilder pipeline console if you wish to see more about this build"
echo "The image version ARN is $IMAGE_VERSION_ARN"

while [ "$IMAGE_STATE" != "AVAILABLE" ]
do 
	if [ "$IMAGE_STATE" = 'FAILED' ]; then 
		echo "Failure in image builder pipeline. Please look at the image builder logs"  
		exit 1 
	fi
	export IMAGE_STATE=$(aws imagebuilder get-image --image-build-version-arn $IMAGE_VERSION_ARN --query 'image.state.status'  | sed 's/"//g')
done

echo "Image builder succeeded. Working on commiting the AMI ID to the infrastructure repo..."
export AMI_IMAGE_ID=$(aws ec2 describe-images --filters "Name=tag:Ec2ImageBuilderArn,Values=$IMAGE_VERSION_ARN" --query 'Images[0].ImageId' | sed 's/"//g')
echo "The following AMI ID will be used: $AMI_IMAGE_ID"