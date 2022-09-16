variable "cidrs_block" {
  type        = list(object({
    cidr_block = string
    name = string
  }))
  description = "cidrs block, first for vpc, second - subnet"
}

variable avail_zone {}