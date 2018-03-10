#!/bin/bash

# Steve Bonds (sbonds@gmail.com)
# Mar 9 2018

# Turn a CentOS 7 Amazon Web Services VM into a Terraform host for creating more AWS images

# FEATURE ADD: Auto-determine the most recent Terraform release and use that version

bail() {
  echo "ERROR: $1"
  exit 1
}

TERRAFORM_VERSION=0.11.3


# Import the Terraform signing key if not present
# ID from https://www.hashicorp.com/security.html
gpg --list-keys 51852D87348FFC4C > /dev/null 2>&1 || gpg --recv-keys 51852D87348FFC4C || bail "Terraform GPG key download FAILED"

# Download the Terraform software
if curl -C - -O "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig" && \
  curl -C - -O "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
  curl -C - -O "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
then
  echo download OK 
else
  bail "Download FAILED"
fi

# Confirm the signature file is valid based on the Hashicorp GPG key. This is important since this software is the basis for our
# entire AWS environment. If it's not right, very bad things could spread very quickly.
gpg --verify "terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig" || bail "Unable to verify GPG signature on SHA256SUMS file"

# Make sure the software itself is valid, trusted, and uncorrupted 
if grep "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" "terraform_${TERRAFORM_VERSION}_SHA256SUMS" > "terraform_${TERRAFORM_VERSION}_SHA256SUMS-just-amd64"
then 
  sha256sum -c "terraform_${TERRAFORM_VERSION}_SHA256SUMS-just-amd64" 
else
  bail "Unable to verify SHA256 digest for .zip"
fi

rm -f terraform

if unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
then 
  echo uncompress OK
else
  bail "Uncompress FAILED"
fi
