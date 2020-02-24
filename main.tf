#VPC con 3 capas de subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # que le permite contar con 65.536 IPs privadas.
  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
     Name = "main"
     env = "terraform"
  }
}
#-----------------------------------------------------------
#.......................
###Subnets Públicas### salida y entrada desde internet.
#.......................

#Public Subnet 1
resource "aws_subnet" "public-subnet-1" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.128.0/20"
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-1"
    env       = "terraform"
    layer     = "public"
  }
}

#Public Subnet 2
resource "aws_subnet" "public-subnet-2" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.144.0/20"
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-2"
    env       = "terraform"
    layer     = "public"
  }
}

#Public Subnet 3
resource "aws_subnet" "public-subnet-3" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.160.0/20"	
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-3"
    env       = "terraform"
    layer     = "public"
  }
}

#------------------------------------------------------------
###############################
## Internet_gateway and route table
###############################

resource "aws_internet_gateway" "main-igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name      = "main-igw"
    env       = "terraform"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-igw.id}" 
  }

  tags = {
    Name      = "public-rt"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "public-subnets-assoc-1" {
  subnet_id      = "${element(aws_subnet.public-subnet-1.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
resource "aws_route_table_association" "public-subnets-assoc-2" {
  subnet_id      = "${element(aws_subnet.public-subnet-2.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
resource "aws_route_table_association" "public-subnets-assoc-3" {
  subnet_id      = "${element(aws_subnet.public-subnet-3.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}


#--------------------------------------------------------------
#..................
#Private Subnets A = con salida a internet sin acceso desde internet.
#..................
 
#Public Subnet A1
resource "aws_subnet" "private-subnet-A1" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.0.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A1"
    env       = "terraform"
    layer     = "private"
  }
}

#Public Subnet A2
resource "aws_subnet" "private-subnet-A2" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.32.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A2"
    env       = "terraform"
    layer     = "private"
  }
}

#Public Subnet A3
resource "aws_subnet" "private-subnet-A3" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.64.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A3"
    env       = "terraform"
    layer     = "private"
  }
}
#--------------------------------------------------------------
###########################
# Nat Gateways x 3 HA
###########################

resource "aws_eip" "natgw-A1" {
  vpc = true
  tags = {
    Name = "natgw-A1"
  }
}

resource "aws_nat_gateway" "natgw-A1" {
  allocation_id = "${aws_eip.natgw-A1.id}"
  subnet_id     = "${aws_subnet.public-subnet-1.id}"
  tags = {
    Name = "natgw-A1"
  }
}


resource "aws_route_table" "private-rt-A1" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw-A1.id}"
  }

  tags = {
    Name      = "private-rt-A1"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "private-subnets-assoc-1" {
  subnet_id      = "${element(aws_subnet.private-subnet-A1.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-A1.id}"
}

#-----------------------------------------

resource "aws_eip" "natgw-A2" {
  vpc = true
  tags = {
    Name = "natgw-A2"
  }
}

resource "aws_nat_gateway" "natgw-A2" {
  allocation_id = "${aws_eip.natgw-A2.id}"
  subnet_id     = "${aws_subnet.public-subnet-2.id}"
  tags = {
    Name = "natgw-A2"
  }
}


resource "aws_route_table" "private-rt-A2" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw-A2.id}"
  }

  tags = {
    Name      = "private-rt-A2"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "private-subnets-assoc-2" {
  subnet_id      = "${element(aws_subnet.private-subnet-A2.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-A2.id}"
}
  
#--------------------------------------------------------

resource "aws_eip" "natgw-A3" {
  vpc = true
  tags = {
    Name = "natgw-A3"
  }
}

resource "aws_nat_gateway" "natgw-A3" {
  allocation_id = "${aws_eip.natgw-A3.id}"
  subnet_id     = "${aws_subnet.public-subnet-3.id}"
  tags = {
    Name = "natgw-A3"
  }
}

resource "aws_route_table" "private-rt-A3" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw-A3.id}"
  }

  tags = {
    Name      = "private-rt-A3"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "private-subnets-assoc-3" {
  subnet_id      = "${element(aws_subnet.private-subnet-A3.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-A3.id}"
}

#---------------------------------------------------------
#..................
#Private Subnets B = sin salida ni entrada (internet)
#..................

#Private Subnet B1
resource "aws_subnet" "private-subnet-B1" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.192.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B1"
    env       = "terraform"
    layer     = "private"
  }
}

#Private Subnet B2
resource "aws_subnet" "private-subnet-B2" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.200.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B2"
    env       = "terraform"
    layer     = "private"
  }
}

#Private Subnet B3
resource "aws_subnet" "private-subnet-B3" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.208.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B3"
    env       = "terraform"
    layer     = "private"
  }
}

resource "aws_route_table" "private-rt-B" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name      = "private-rt-B"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "private2-subnets-assoc-1" {
  subnet_id      = "${element(aws_subnet.private-subnet-B1.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-B.id}"
}

resource "aws_route_table_association" "private2-subnets-assoc-2" {
  subnet_id      = "${element(aws_subnet.private-subnet-B2.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-B.id}"
}

resource "aws_route_table_association" "private2-subnets-assoc-3" {
  subnet_id      = "${element(aws_subnet.private-subnet-B3.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt-B.id}"
}

#-----------------------------------------------------------

