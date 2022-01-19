# Pangram

> API to determine if an input string is a pangram (contains each letter of the alphabet). Input may be mixed case, contain numbers, special characters, etc.

## Usage

In order to test, build, and deploy this, you will need the following tools and resources:
- npm
- terraform (0.12 or later)
- AWS account with sufficient permissions
- AWS CLI

## Testing

Testing this code is done using the usual libraries - `mocha` and `chai`. I have also opted to use `nyc`, which outputs code coverage in a nice table.
In order to run tests, you must first install the testing dependencies with `npm i` in the `src` directory. After you have installed the libraries, testing is executed by simply running `npm test`

## Continuous Integration / Continuous Delivery
This repository uses [Github Actions](https://docs.github.com/en/actions) to automate CI/CD workflows. Github Actions are configured via YAML files located in a repo's `.github/workflows` directory. Github Actions can be [triggered from various different events](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows), perform virtually [any action you can imagine](https://github.com/marketplace?type=actions), and are [free for many use cases](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration#about-billing-for-github-actions). They are also an increasingly popular CI/CD platform with a [growing demand on the job market](https://discovery.hgdata.com/product/github-actions). As an extra bonus, they can also [do](https://github.com/fabasoad/twilio-fax-action/) [other](https://www.swyx.io/github-scraping/) [interesting](https://github.com/marketplace/actions/hue-action) [things](https://towardsdatascience.com/automate-your-job-search-with-python-and-github-actions-1dc818844c0).

Over the course of the branches in this repo, we'll look at how to use Github Actions for some common use cases - ones you may even find handy today! Each branch in the series will be numbered with only the necessary workflow included. A final branch with all workflows will be the last in the series.

This branch - `talk/gha-2-pull-request-metadata` - shows how you could add information (via comments) to a pull request. One common reason you might want to do this is to alert when a specific file changes. In this case, we will add a comment and tag a person (me) in that comment when our `package.json` is updated.

* The file `.github/workflows/ci-check-package-file.yml` is our focus
* In that file, we define a workflow `Check package.json on PR Open/Updated`
  * This will run the workflow when a pull request is opened (`opened`) or has commits added (`synchronize`)
  * This will also _only run_ when `src/package.json` is changed 
* If `src/package.json` is changed, the workflow runs - it checks out the repo, gets the diff of the change to the file, and comments on the PR with those changes.
    * The action won't actually post the diff in the comment, as there is some issue running `git diff` in the runner. But that's OK, the comment is made and the code owner is notified!
  * It is _magnificent_

## Deploying

Deployment of resources in this repo is done via Terraform. You must have version 0.12 or later - 0.11 is not compatible.
To deploy the resources, first run `terraform init` from the root of the repo. You will need to provide an S3 bucket name and prefix for remote state storage, and the bucket must already exist. This will configure your environment and download the proper providers.
It is recommended to run `terraform plan` and verify that everything looks correct. This is especially important in a populated AWS account, make sure you don't destroy any resources via name conflicts etc. Once you've verified the plan is correct, run `terraform apply` to deploy the resources. This will also deploy the code to the Lambda function the first time it is run.
If you would like to make changes to the Lambda code and have those deployed, modify the `--profile` parameter in the `deploy` script in package.json to match your desired profile. Once that is done, you can use `npm run deploy` to deploy _only_ the Lambda code.

# Architecture

This project utilizes a traditional AWS API Gateway deployment with a Lambda proxy integration. This proxies requests to the HTTP API directly to the Lambda function, with parameters available in the `event` object. When utilizing the proxy integration, query string parameters are available in the `queryStringParameters` property. The Lambda code looks for a query string parameter named `string` and checks that value for all letters of the alphabet, returning a JSON response with a property of `isPangram` which is either `true` or `false`. The API returns a 200 status code in either case. The API will return a 503 status code if the `string` parameter is not provided, or in the case of unknown errors.

# Findings

Having done this before (on exorcism, I belive) I knew there were a few ways to handle the problem - the "smart" way of using a map, using regex, or utilizing array methods. I had a feeling that the most naive way to do this would be the fastest, and since latency would be a consideration in a web service I decided to benchmark my options. [You can find those results and run the tests here. (dead link, jsperf has been down for some time)](https://jsperf.com/pangram-method-comparison/1)

As I suspected, the most naive approach is by far the fastest - using `.indexOf(letter) !== -1` - coming out 90%+ faster than other methods other than `includes()`, which is just a fancy way of checking the same thing and generally ends up being just a tiny bit slower.

With this in mind, I used the `.indexOf` method for this project.

## Possible Improvements

Some improvements over the current architecture could be made, mostly around permissions. 
- Currently there is some naive usage of `*` in policies. In production, these should be limited to the appropriate resources.
- While technically "RESTful", the API will support any valid HTTP method as long as the proper query strings are provided. In a production environment, this may need to be limited to GET only, especially if further method support is desired.
- There is no authorization on the API.
- Better error handling with customized messaging would be desirable in production.
- Networking config.
- Minimize/compress deployment package (including removing test directory)

# Technolgoies Used
- git
- nodejs
- npm
- mocha, chai, nyc for testing
- Terraform
- AWS Lambda
- AWS API Gateway
- AWS CLI