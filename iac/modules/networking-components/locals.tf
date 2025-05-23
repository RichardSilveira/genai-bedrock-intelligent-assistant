locals {
  combined_tags = merge(
    var.tags,
    {
      Component = "networking-components"
    }
  )
}
