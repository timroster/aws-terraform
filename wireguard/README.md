# Wireguard gateway - WIP

Creates a `t2.micro` instance using a specified key pair and vpc security group. Rename the `terraform.tfvars_template` file to `terraform.tfvars` and update with the properties for your AWS account.

## Prerequisites

1. Create an AWS account and API key. It is recommended that you create a non-root shell-only user and then generate the API key under that user to use for provisioning.
2. Install [terraform](https://www.terraform.io) on the workstation/client
3. Install [wireguard](https://www.wireguard.com) on the workstation/client

## Initial Setup

Wireguard can implement a client to server VPN pattern with the "server" using NAT forwarding to hosts that it can reach. This code provides an implementation of this pattern capable of running on AWS free tier. Before using the terraform code to provision the server, on the workstation that will be the client run this command:

```
$ wgclient-setup
```

After the script completes, copy the customized `wgclient` script to `/usr/local/bin` or somewhere else in your PATH.

## Launching Wireguard server endpoint

Use the following standard steps with terraform to bring up the envrionment"

```
$ terraform init
$ terraform apply
```

## Connecting the client to the Wireguard server

The terraform code will output the IP address of the endpoint after the endpoint is up. Collect the public key from the endpoint using a remote shell something like:

```
$ WG_SERVER_PUBKEY=$(ssh -i ~/.ssh/aws-ec2 -o "StrictHostKeyChecking off" fedora@$(terraform output -raw public_ip_address) cat wg.pubkey)
```

Then run the wgclient script to bring up the connection:

```
$ wgclient ${WG_SERVER_PUBKEY} <ip-address-from-vm>
```

## Testing the connection

Check the routing to the Internet with something like:

```
$ traceroute to 8.8.8.8 (8.8.8.8), 64 hops max
  1   10.0.10.1  11.922ms  12.125ms  11.929ms 
  2   216.182.237.209  15.754ms  16.455ms  17.229ms 
  3   100.65.16.128  26.240ms  25.185ms  31.914ms 
  4   100.66.8.180  26.691ms  32.584ms  40.152ms 
  5   100.66.11.72  33.588ms  32.656ms  32.901ms 
  6   100.66.7.235  22.394ms  32.763ms  27.830ms 
  7   100.66.4.199  31.756ms  36.372ms  33.288ms 
  ...
```

The first hop being 10.0.10.1 means your workstation traffic to that IP address is crossing over the Wireguard VPN!

