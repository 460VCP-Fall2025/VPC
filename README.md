# AWS Virtual Private Cloud Deployer
By:
[Yahya G.](https://www.linkedin.com/in/yahya-guler-ab498a282/)
[Abdirahman H.](https://www.linkedin.com/in/abdirahman-hassan-9864ba2b2/)
[Dustin M.](https://www.linkedin.com/in/dustin-marsh-a3101524a/)
[Paul E.]()


<<<<<<< HEAD
------------------------------------------
=======
## **Note**: The terrafrom code currently will only successfully run on Unix Operating Systems (MacOs, Linux) and not Windows. When this issue is resolved, an updated note will be written.

------------------------------------------
![Diagram](ProjectDiagram.jpg)
>>>>>>> 595a316 (Edited README.md)
### VPC Infrastructure
**This VPC contains 3 subnets**:
**1 public subnet and**
**2 private subnets**

**Public Subnet:**  
<<<<<<< HEAD
An EC2 instances for the VPN which allows you to connect to the network and A AWS NAT gateway which allows internet traffic to and from the private servers
=======
An EC2 instance for the VPN, which allows you to connect to the network, and a NAT gateway, which allows internet traffic to and from the private servers
>>>>>>> 595a316 (Edited README.md)

**Private Subnets:**  
2 EC2 instances (blue and green) for the private servers and
a load balancer to properly distribute traffic to the 2 private servers

------------------------------------------
### VPN
<<<<<<< HEAD
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
=======
The VPN is run with an OpenVPN install. This allows you to connect to the network and interact with the instance's private IP addresses.

### NAT Gateway
The NAT Gateway allows the private servers to access the internet under one public IP address, redirecting incoming traffic to the respective server.

### Private Servers
We have 2 private servers to run blue green deployment, which allows a smooth transition to updated software or a second instance in case of a failure.
A load balancer forwards traffic to the currently running private server.

**Note** For the purposes of our project, we did not fully implement a Blue/Green deployment strategy. There is no option to rollback to previous versions. Instead, for simplicity's sake, all that is implemented is the switching between blue and green environments.
------------------------------------------
### Running the VPC
### Step 1: Prerequisites
First, ensure you have correctly installed/set up the following:

-An AWS account and IAM user

-[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

-[Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 

-[Packer CLI](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)

-[OpenVPN](https://openvpn.net/client)

After installing AWS CLI, you will have to configure it by using 
```console
aws configure
```
You can get your keys in your IAM account in  
*IAM > Users > Security Credentials > Create Access Key*  
While in Users, add the ***AdministratorAccess*** Permissions policies.

------------------------------------------
### Step 2: Running the Packer Files
After that, navigate into the private-server and vpn-ec2 directories, which are both in the packer directory, and run
>>>>>>> 595a316 (Edited README.md)

```console
packer init .
```
```console
packer build .
```

**Note**: Estimated build time: 10 minutes

<<<<<<< HEAD
**Note**: you can open two terminals and run each packer file in parallel to speed up process

------------------------------------------
### Step 3
After that finished for both folders folder, you can navigate to the terraform folder and run
=======
**Note**: you can open two terminals and run each packer file in parallel to speed up the process.

------------------------------------------
### Step 3: Running the Terraform files
After that finished for both folders folder, you can navigate to the terraform directory and run
>>>>>>> 595a316 (Edited README.md)
```console
terraform init
```

To set Blue environment on, run:
```console
 terraform apply -var="enable_blue_env=true" -var="enable_green_env=false"
```

To set Green environment on, run:
```console
terraform apply -var="enable_blue_env=false" -var="enable_green_env=true"
```
type yes and once it finishes you'll be given commands to SSH into the VPN which can be used to SSH into the other instances, and the command to get the .ovpn key.

**Note**: You must set one environment variable to true and the other environment variable to false. They cannot be both false or both true at the same time.

------------------------------------------
<<<<<<< HEAD
### Shutting down the VPC
Once you are done using the VPC make sure to run
=======
### Step 4: Connecting to the VPC via OpenVPN
After successfully applying the terraform files, the .opvn file from the vpn-ec2 instance should be copied onto your local machine into the terraform directory. 

In your OpenVPN Client GUI, create a new profile by uploading that .opvn then click connect.

------------------------------------------
### Step 5: Shutting down the VPC
Once you are done using the VPC, make sure to run
>>>>>>> 595a316 (Edited README.md)
```bash
terraform destroy -var="skip_validation=true"
```
To ensure you don't keep getting charged by AWS

--------------------------
<<<<<<< HEAD
**DATE OF COMPLETION: DEC 1,2025**
=======
>>>>>>> 595a316 (Edited README.md)
