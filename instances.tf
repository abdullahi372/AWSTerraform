resource "aws_instance" "Web-Server" {
  count = 2

  ami             = "ami-033af134328c47f48"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.ws-sg.id}"]
  subnet_id       = element(aws_subnet.public.*.id, count.index)
  user_data       = file("install-httpd.sh")

  tags = {
    Name = "Web Server ${count.index + 1}"
  }
}
