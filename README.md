# DFLY-CI-CD

DFLY is NodeJS app hosted on EKS with CI/CD pipelines. 
=======

DFly is a software development platform that enables developers to seamlessly develop and deploy their applications to public cloud. For now,
dfly offers its PaaS on AWS. To develop applications on dfly, it is expected that developers are familiar with Kubernetes ecosystem and basic usage of kubectl.
**************************|**************************|**************************|**************************
Candidate should provide every developer a website with a simple message: "Welcome to Dfly"
**************************|**************************|**************************|**************************
1. Candidate can develop their web applications on Java/NodeJS/Python/Golang or any programming language of their chouce. The purpose of that 
web application is to show the message "Welcome to Dragonfly" on the browser (It can be Nginx or Apache)
2. The web application should be checked into a git repository (github or gitlab) and should be open for other developers to submit Pull-Requests
3. The repository should be equipped with a CI-CD pipeline. It can be a Jenkins/Travis-CI/Circle-CI/any-CI pipieline that does the continuous deployments
4. Provision a Kubernetes Cluster on AWS - can be EKS or KOPS using Terraform or CloudFormation
5. Dockerize the application developed in step(1) and deploy the application to the kubernetes cluster provisioned above
6. Submit a Pull-Request to the git repository in step(2) and the CI-CD pipeline should push the changes to Kubernetes cluster

===========================================================
===========================================================
   **************** Project Walk through **************
===========================================================
===========================================================

Tools Used

  Terraform:
  
    - To create the VPC resources and EKS Cluster.
    - State files are in the S3 bucket
    - EKS cluster runs Deployment service, that has pods running
      the Node Js app and listening on port 8080.
      EKS cluster has the Load Balancer configured to expose this pods port 8080
      to port 80 of the Load Balancer.

  Node js:
    - To host the web server application to display "Welcome to Dfly"
    - Runs on Post 8080

  Docker:
    - To containerize the Node js web server application.

  CircleCI:
    - For doing CI/CD pipeline
    - in DFLY-CI-CD/.circleci/config.yml file the Build pipeline is there.  (<----- CI part ----->)
    
      (i)   The pipeline is configured to download the github repo where Node Js app code is stored.
      
      (ii)  It will Build the docker image from the Dockerfile
      
      (iii) Push the Node js Docker Image to ECR repository
        - In DFLY-CI-CD/ci-cd/config.yaml file I have tried to come up with complete CI/CD pipeline for circleci.
          In the above step BUILD (CI part) is a success but CD part I was running into more issues and needed more 
          time to debug. So I have kept it as a separate directory to display the idea on which I was trying to 
          get full CI/CD portion of the problem statement.

  Github:
    - For distributed version control of the source code of entire problem solution.
    - I have made the repository public but in Github there is no provision to give open access to approve Pull Requests.
      Please send me the email address so that I can give admin access to approve your own PRs and see CircleCI building
      the nodejs docker image and push it to the ECR Docker Image repo.
      Or can do a demo with the screen share while I approve your PR.

#Note: Please look inside each file. It has detailed description about AWS-IAM-AUTHENTICATOR, VPC and Kubeconfig usecase. 

#Proposed Improvements in my solution:

- Make CD part of the pipeline workflow work 
- Introduce Health Checks for the application and the Load Balancer


