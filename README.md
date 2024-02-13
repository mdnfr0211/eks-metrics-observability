# Centralized Metrics Aggregator using ADOT + Victoria Metrics

This repository offers an example deployment code for a robust and efficient centralized metrics aggregator using ADOT (AWS Distro for OpenTelemetry) and Victoria Metrics. The solution is well-suited for collecting and storing metric data at scale in real-time while maintaining ease of use and cost-effectiveness.

![centralized_metrics_aggregator](https://github.com/mdnfr0211/eks-metrics-observability/assets/55761300/467ada65-da7d-48c3-a5cb-00fc74cb1cd5)

## Prerequisites
Before you begin, ensure you have the following:

- Terraform installed on your local machine.
- An AWS account with the necessary permissions.

## Components

- ADOT: Acts as a Metric Scraper, Pulling Data from Various Sources and Forwarding it to Victoria Metrics using Prometheus Remote Write.
    
- Victoria Metrics: Comprises three core components:
  - Select: Performs Incoming Queries by fetching the needed Data from all the Configured ```vmstorage``` Nodes
  - Insert: Accepts the Ingested Data and Spreads it among ```vmstorage``` Nodes according to consistent hashing over the metric name and all its labels
  - Storage: Stores the Raw Data and returns the Queried data on the given time range for the given label filters
  
- Grafana: Provides a user-friendly interface for visualizing and analyzing metrics stored in Victoria Metrics

## Why Choose Victoria Metrics?

When choosing a metrics storage solution, Victoria Metrics stands out for the following reasons:

- Performance: Victoria Metrics is optimized for high performance, ensuring fast query responses and efficient resource utilization.
- Cost-Effective: With its efficient storage format, Victoria Metrics provides a cost-effective solution for the long-term storage of time-series data.
- Simplicity: Victoria Metrics has a straightforward architecture with three components, making it easy to set up and maintain.
- Scalability: The scalability of Victoria Metrics allows for handling large volumes of metrics data, making it suitable for both small and large-scale applications.
- Prometheus Compatibility: Victoria Metrics seamlessly integrates with Prometheus, allowing for easy migration and compatibility with existing Prometheus setups.
- Community Support: Victoria Metrics has an active community, ensuring ongoing development, support, and improvement.

When compared to alternatives like Cortex, Thanos, or Mimir, Victoria Metrics stands out in terms of simplicity, performance, and cost-effectiveness. Choose Victoria Metrics for a robust and efficient centralized metrics aggregation solution.

## Result
<img width="1909" alt="Screenshot 2024-02-12 164634" src="https://github.com/mdnfr0211/eks-metrics-observability/assets/55761300/07c65065-8a24-4172-9076-f8761d532461">

## Additional Notes

This example offers a starting point. You can customize the infrastructure and configuration to match your specific needs.
Refer to the official documentation for detailed information on ADOT, Victoria Metrics, and Grafana.
