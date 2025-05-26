locals {

  combined_tags = merge(
    var.tags,
    {
      Component = "bedrock-rag"
    }
  )
}
