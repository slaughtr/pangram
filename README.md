# Pangram

> You will receive a string as input, potentially a mixture of upper and lower case, numbers, special characters etc. The task is to determine if the string contains at least one of each letter of the alphabet. Return true if all are found and false if not. Write it as a RESTful web service (no authentication necessary)


# Plan
- [x] Setup repo
- [x] Write tests
- [x] Write code
- [ ] Write Terraform
- [ ] Deploy
- [ ] End to end testing (Postman against HTTP API)

# Findings

Having done this before (on exorcism, I belive) I knew there were a few ways to handle the problem - the "smart" way of using a map, using regex, or utilizing array methods. I had a feeling that the most naive way to do this would be the fastest, and since latency would be a consideration in a web service I decided to benchmark my options. [You can find those results and run the tests here.](https://jsperf.com/pangram-method-comparison/1)

As I suspected, the most naive approach is by far the fastest - using `.indexOf(letter) !== -1` - coming out 90%= faster than other method other than `includes()`, which is just a fancy way of checking the same thing.

With this in mind, I will use that method for this project.
