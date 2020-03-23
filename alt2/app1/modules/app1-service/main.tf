variable name {}

# build here all the resources for service 1
# this example does not work, but should illustrate the point

resource "ec2-instance" "app-server" {
  name = var.name
}

resource "ec2-role" "app-server-role" {
  name = var.name
}
