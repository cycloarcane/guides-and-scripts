#!/bin/bash

set -euo pipefail

# Make sure jq is installed
if ! command -v jq &> /dev/null; then
  echo "❌ 'jq' is required. Install it first: sudo pacman -S jq"
  exit 1
fi

regions=($(aws ec2 describe-regions --query "Regions[*].RegionName" --output text))

for region in "${regions[@]}"; do
  echo -e "\n🌍 REGION: $region"

  ## 🔥 Terminate EC2 instances
  instances=$(aws ec2 describe-instances --region $region --query "Reservations[*].Instances[*].InstanceId" --output text)
  if [[ -n "$instances" ]]; then
    echo "🔥 Terminating instances: $instances"
    aws ec2 terminate-instances --instance-ids $instances --region $region
  else
    echo "✅ No EC2 instances found."
  fi

  ## 💽 Delete EBS volumes
  volumes=$(aws ec2 describe-volumes --region $region --query "Volumes[*].VolumeId" --output text)
  for vol in $volumes; do
    echo "🧹 Deleting volume: $vol"
    aws ec2 delete-volume --volume-id $vol --region $region || true
  done

  ## 🗂️ Delete snapshots (owned by you)
  snapshots=$(aws ec2 describe-snapshots --owner-ids self --region $region --query "Snapshots[*].SnapshotId" --output text)
  for snap in $snapshots; do
    echo "🧼 Deleting snapshot: $snap"
    aws ec2 delete-snapshot --snapshot-id $snap --region $region || true
  done

  ## 🌐 Release Elastic IPs
  eips=$(aws ec2 describe-addresses --region $region --query "Addresses[*].AllocationId" --output text)
  for eip in $eips; do
    echo "🌐 Releasing Elastic IP: $eip"
    aws ec2 release-address --allocation-id $eip --region $region || true
  done

  ## 🧠 Delete customer-managed prefix lists (skip AWS-managed)
  echo "🔍 Checking prefix lists in $region..."
  prefix_data=$(aws ec2 describe-managed-prefix-lists --region $region --output json)

  echo "$prefix_data" | jq -c '.PrefixLists[]' | while read -r item; do
    owner_id=$(echo "$item" | jq -r '.OwnerId')
    prefix_list_id=$(echo "$item" | jq -r '.PrefixListId')
    prefix_list_name=$(echo "$item" | jq -r '.PrefixListName')

    if [[ "$owner_id" != "aws" && ! "$prefix_list_name" =~ ^com\.amazonaws\. ]]; then
      echo "❌ Deleting customer-managed prefix list: $prefix_list_id"
      aws ec2 delete-managed-prefix-list --prefix-list-id "$prefix_list_id" --region $region || true
    else
      echo "🔒 Skipping AWS-managed prefix list: $prefix_list_id ($prefix_list_name)"
    fi
  done

  ## 💥 Delete all VPCs (takes out subnets, gateways, route tables, etc.)
  vpcs=$(aws ec2 describe-vpcs --region $region --query "Vpcs[*].VpcId" --output text)
  for vpc in $vpcs; do
    echo "💣 Deleting VPC: $vpc"
    aws ec2 delete-vpc --vpc-id $vpc --region $region || true
  done
done

echo -e "\n✅ AWS account is clean. Wiped user-owned resources across all regions."
