# AWS Virtual Private Cloud Deployer
------------------------------------------
### VPC Infrastructure
**This VPC contains 2 subnets a public and a private**

**Public Subnet**
An EC2 instance for the VPN
A NAT gateway to allow internet traffic to and from the private server

**Private Subnet**
2 EC2 instances for the private servers
A load balancer to properly distribute traffic to the 2 private servers

------------------------------------------
### VPN
The VPN is ran with an openVPN install, This allows you to connect to the network and interact with the instances private IP addresses.
To connect run the command given after the ```terraform apply``` a .ovpn file will be downloaded, use that file in openVPN Connect to connect to the network

### NAT Gateway
The NAT Gateway allows the private servers to access the internet under one IP public address, redirecting incoming traffic to the respected server.
**MORE INFO? IDK IF WE ARE USING CUSTOM OR AWS**

### Private Servers
We have 2 private servers to run blue green deployment, which allows smooth transition to updated software or a second instance in case of a failure.
A load balancer controls which server is currently active.

### Running the VPC
First you will need a AWS account and have to install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli), and [packer CLI](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)
**BELOW MIGHT BE A LITTLE WRONG DEPENDING IF WE REMOVE NAT**
After that navigate into the nat, private-server, and vpn-ec2 and run

```console
packer init .
```
```console
packer build .
```
After that finished for each folder, you can navigate to the terraform folder and run
```console
terraform init
```
```console
terraform apply
```
type yes and once it finishes you'll be given commands to SSH into the VPN which can be used to SSH into the other instances, and the command to get the .ovpn key.


DATE OF COMPLETION: DEC 1,2025