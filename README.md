# AWS Virtual Private Cloud Deployer
By:
[Yahya G.](https://www.linkedin.com/in/yahya-guler-ab498a282/)
[Abdirahman H.](https://www.linkedin.com/in/abdirahman-hassan-9864ba2b2/)
[Dustin M.](https://www.linkedin.com/in/dustin-marsh-a3101524a/)
[Paul E.]()


------------------------------------------
### VPC Infrastructure
**This VPC contains 2 subnets a public and a private**

**Public Subnet:**  
An EC2 instances for the VPN which allows you to connect to the network and A AWS NAT gateway which allows internet traffic to and from the private servers

**Private Subnet:**  
2 EC2 instances for the private servers and
a load balancer to properly distribute traffic to the 2 private servers

------------------------------------------
### VPN
The VPN is ran with an openVPN install, This allows you to connect to the network and interact with the instances private IP addresses.
To connect run the command given after the ```terraform apply``` a .ovpn file will be downloaded, use that file in openVPN Connect to connect to the network

### NAT Gateway
The NAT Gateway allows the private servers to access the internet under one IP public address, redirecting incoming traffic to the respected server.

### Private Servers
We have 2 private servers to run blue green deployment, which allows smooth transition to updated software or a second instance in case of a failure.
A load balancer controls which server is currently active.

------------------------------------------
### Running the VPC
### Step 1
First you will need a AWS and IAM account and have to install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli), and [packer CLI](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)

After installing AWS CLI you will have to configure it by using 
```console
aws configure
```
you can get your keys in your IAM account in  
*IAM > Users > Security Credentials > Create Access Key*  
While in Users add the ***AdministratorAccess*** Permissions policies this is needed to run the project

------------------------------------------
### Step 2
After that navigate into the private-server and vpn-ec2 and run

```console
packer init .
```
```console
packer build .
```
------------------------------------------
### Step 3
After that finished for both folders folder, you can navigate to the terraform folder and run
```console
terraform init
```
```console
terraform apply
```
type yes and once it finishes you'll be given commands to SSH into the VPN which can be used to SSH into the other instances, and the command to get the .ovpn key.

------------------------------------------
### Shutting down the VPC
Once you are done using the VPC make sure to run
```console
terraform destroy
```
To ensure you don't keep getting charged by AWS

--------------------------
**DATE OF COMPLETION: DEC 1,2025**