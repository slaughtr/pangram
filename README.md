# Pangram

> You will receive a string as input, potentially a mixture of upper and lower case, numbers, special characters etc. The task is to determine if the string contains at least one of each letter of the alphabet. Return true if all are found and false if not. Write it as a RESTful web service (no authentication necessary)

# Usage

In order to test, build, and deploy this, you will need the following tools and resources:
- npm
- terraform (0.12 or later)
- AWS account with sufficient permissions
- AWS CLI

### Testing

Testing this code is done using the usual libraries - `mocha` and `chai`. I have also opted to use `nyc`, which outputs code coverage in a nice table.
In order to run tests, you must first install the testing dependencies with `npm i` in the `src` directory. After you have installed the libraries, testing is executed by simply running `npm test`

### Deploying

Deployment of resources in this repo is done via Terraform. You must have version 0.12 or later - 0.11 will not work.
To deploy the resources, first run `terraform init` from the root of the repo. You will need to provide an S3 bucket name and prefix for remote state storage, and the bucket must already exist. This will configure your environment and download the proper providers.
It is recommended to run `terraform plan` and verify that everything looks correct. This is especially important in a populated AWS account, make sure you don't destroy any resources via name conflicts etc. Once you've verified the plan is correct, run `terraform apply` to deploy the resources. This will also deploy the code to the Lambda function the first time it is run.
If you would like to make changes to the Lambda code and have those deployed, modify the `--profile` parameter in the `deploy` script in package.json to match your desired profile. Once that is done, you can use `npm run deploy` to deploy _only_ the Lambda code.

# Architecture

This project utilizes a traditional AWS API Gateway deployment with a Lambda proxy integration. This proxies requests to the HTTP API directly to the Lambda function, with parameters available in the `event` object. When utilizing the proxy integration, query string parameters are available in the `queryStringParameters` property. The Lambda code looks for a query string parameter named `string` and checks that value for all letters of the alphabet, returning a JSON response with a property of `isPangram` which is either `true` or `false`. The API returns a 200 status code in either case. The API will return a 503 status code if the `string` parameter is not provided, or in the case of unknown errors.

# Findings

Having done this before (on exorcism, I belive) I knew there were a few ways to handle the problem - the "smart" way of using a map, using regex, or utilizing array methods. I had a feeling that the most naive way to do this would be the fastest, and since latency would be a consideration in a web service I decided to benchmark my options. [You can find those results and run the tests here.](https://jsperf.com/pangram-method-comparison/1)

As I suspected, the most naive approach is by far the fastest - using `.indexOf(letter) !== -1` - coming out 90%= faster than other method other than `includes()`, which is just a fancy way of checking the same thing and generally ends up being just a tiny bit slower.

With this in mind, I will use that method for this project.

### Possible Improvements

Some improvements over the current architecture could be made, mostly around permissions. 
- Currently there is some naive usage of `*` in policies. In production, these should be limited to the appropriate resources.
- While technically "RESTful", the API will support any valid HTTP method as long as the proper query strings are provided. In a production environment, this may need to be limited to GET only, especially if further method support is desired.
- There is no authorization on the API.
- Better error handling with customized messaging would be desirable in production.
- Networking config.
- Minimize/compress deployment package (including removing test directory)


# Plan
- [x] Setup repo
- [x] Write tests
- [x] Write code
- [x] Write Terraform
- [x] Deploy
- [x] End to end testing (Postman against HTTP API)

# Technolgoies Used
- git
- nodejs
- npm
- mocha, chai, nyc for testing
- Terraform
- AWS Lambda
- AWS API Gateway
- AWS CLI