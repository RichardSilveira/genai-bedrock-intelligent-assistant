# Observability Components Module

This module provides a collection of observability and security monitoring components that can be enabled or disabled individually. It follows a modular approach where each component (AWS Config, CloudTrail, etc.) can be toggled independently through variables, allowing for granular control over which observability features are deployed.

The AWS Config component monitors security groups for SSH access from the internet by default, with the ability to expand monitoring to additional resource types and compliance rules in the future. All components follow security best practices and are designed to work together while maintaining independence.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->