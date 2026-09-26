# organizational_units.tf

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.main.roots[0].id

  tags = merge(local.common_tags, {
    Name = "Security"
  })
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = aws_organizations_organization.main.roots[0].id

  tags = merge(local.common_tags, {
    Name = "Infrastructure"
  })
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.main.roots[0].id

  tags = merge(local.common_tags, {
    Name = "Workloads"
  })
}

resource "aws_organizations_organizational_unit" "production" {
  name      = "Production"
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = merge(local.common_tags, {
    Name = "Production"
  })
}

resource "aws_organizations_organizational_unit" "nonproduction" {
  name      = "NonProduction"
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = merge(local.common_tags, {
    Name = "NonProduction"
  })
}