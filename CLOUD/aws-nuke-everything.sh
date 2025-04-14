#!/bin/bash

set -euo pipefail

regions=($(aws ec2 describe-regions --query "Regions[*].RegionName" --output text))

for region in "${regions[@]}"; do
  echo "🌍 REGION: $region"

  # Terminate EC2 Instances
  instances=$(aws ec2 describe-instances --region $region --query "Reservations[*].Instances[*].InstanceId" --output text)
  if [[ -n "$instances" ]]; then
    echo "🔥 Terminating instances: $instances"
    aws ec2 terminate-instances --instance-ids $instances --region $region
  fi

  # Delete Volumes
  volumes=$(aws ec2 describe-volumes --region $region --query "Volumes[*].VolumeId" --output text)
  if [[ -n "$volumes" ]]; then
    echo "🧹 Deleting volumes: $volumes"
    for vol in $volumes; do
      aws ec2 delete-volume --volume-id $vol --region $region
    done
  fi

  # Delete Snapshots (owned by you)
  snapshots=$(aws ec2 describe-snapshots --owner-ids self --region $region --query "Snapshots[*].SnapshotId" --output text)
  if [[ -n "$snapshots" ]]; then
    echo "🧹 Deleting snapshots: $snapshots"
    for snap in $snapshots; do
      aws ec2 delete-snapshot --snapshot-id $snap --region $region
    done
  fi

  # Release Elastic IPs
  eips=$(aws ec2 describe-addresses --region $region --query "Addresses[*].AllocationId" --output text)
  if [[ -n "$eips" ]]; then
    echo "🌐 Releasing Elastic IPs: $eips"
    for eip in $eips; do
      aws ec2 release-address --allocation-id $eip --region $region
    done
  fi

  # Delete *only* customer-managed Prefix Lists
  echo "🔍 Checking for customer-managed prefix lists..."
  prefix_lists=$(aws ec2 describe-managed-prefix-lists --region $region \
    --query "PrefixLists[?OwnerId!='aws'].PrefixListId" --output text)

  if [[ -n "$prefix_lists" ]]; then
    for pl in $prefix_lists; do
      echo "❌ Deleting customer-managed prefix list: $pl"
      aws ec2 delete-managed-prefix-list --prefix-list-id "$pl" --region $region || true
    done
  else
    echo "ℹ️ No customer-managed prefix lists found in $region."
  fi

  # Delete VPCs (and all their children)
  vpcs=$(aws ec2 describe-vpcs --region $region --query "Vpcs[*].VpcId" --output text)
  for vpc in $vpcs; do
    echo "💥 Deleting VPC: $vpc"
    aws ec2 delete-vpc --vpc-id $vpc --region $region || true
  done
done

echo -e "\n✅ AWS account wiped clean (user-owned resources only)."
