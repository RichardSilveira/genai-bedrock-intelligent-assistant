locals {
  combined_tags = merge(
    var.tags,
    {
      Component = "observability-components"
    }
  )
}