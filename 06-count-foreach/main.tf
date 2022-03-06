provider "aws" {
  region = "ap-northeast-2"
}

#not using for_each, count..
/*
resource "aws_iam_user" "user_1" {
  name = "user-1"
}

resource "aws_iam_user" "user_2" {
  name = "user-2"
}

resource "aws_iam_user" "user_3" {
  name = "user-3"
}

output "user_arns" {
  value = [
    aws_iam_user.user_1.arn,
    aws_iam_user.user_2.arn,
    aws_iam_user.user_3.arn,
  ]
}
*/

#count -> resource, data, module 
/*
resource "aws_iam_user" "count" {
  count = 10 #meta argument, declare on top(coding convention)

  name = "count-user-${count.index}"
}

output "count_user_arns" {
  value = aws_iam_user.count.*.arn
}
*/

#for_each + set
/*
resource "aws_iam_user" "for_each_set" {

  for_each = toset(
    [
      "for-each-set-user-1",
      "for-each-set-user-2",
      "for-each-set-user-3"
    ]
  )
  name = each.key
}

output "for_each_set_user_arns" {
  value = values(aws_iam_user.for_each_set).*.arn
}
*/


#for_each + map
resource "aws_iam_user" "for_each_map" {

  # map's values must have to string value.
  for_each = {
    alice = {
      level = "low"
      manager= "zkaryaJo"
    }
    bob = {
      level = "mid"
      manager= "zkaryaJo"
    }
    john = {
      level = "high"
      manager= "zkaryaJo"
    }
  }
  name = each.key
  tags = each.value
}

output "for_each_map_user_arns" {
  value = values(aws_iam_user.for_each_map).*.arn
}

