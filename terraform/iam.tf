resource "aws_iam_user" "demo_user" {
  #checkov:skip=CKV_AWS_273:this is a demo user used for a template
  name = "iam_for_${var.service}-${terraform.workspace}"
  path = "/users/demo_user/"

  tags = {
    Org : "Alamy",
    Environment : title(terraform.workspace),
    Service : "${var.service}"
    Name : "${var.service}-${terraform.workspace}"
  }
}

resource "aws_iam_access_key" "demo_access_key" {
  user = aws_iam_user.demo_user.name
}

resource "aws_iam_user_policy" "demo_policy" {
  #checkov:skip=CKV_AWS_40:We want a single user with direct write access not a role
  name   = "iam_for_${var.service}-${terraform.workspace}"
  user   = aws_iam_user.demo_user.name
  policy = data.aws_iam_policy_document.demo_policy_document.json
}

data "aws_iam_policy_document" "demo_policy_document" {
  statement {
    effect = "Allow"

    # Be as granular as possible with actions, avoid wildcard (*) where possible
    actions = []

    resources = []
  }
}
