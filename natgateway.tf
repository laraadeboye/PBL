# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.ig]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat-eip"
    }
  )
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id # Place the NAT Gateway in the first public subnet


  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat"
    }
  )

  depends_on = [aws_internet_gateway.ig]
}
