# GitHub Archive Data Engineering and Analytics Project

1. [Introduction](#introduction)
2. [Objective](#objective)
3. Solution Design
4. Data Pipeline
   - Ingestion
   - Processing
   - Storing
   - Tranformations
   - Visualization
5. Performance Optimization
6. Outcome and Impact
7. Tools & Technologies

# Introduction
The GitHub Archive Data Engineering and Analytics project aims to transform raw [GitHub](https://www.gharchive.org/) event data into meaningful insights about platform usage and activity trends. GitHub, as a leading platform for version control and collaboration, generates vast amounts of data daily, encompassing millions of user interactions, repository contributions, and events. This project captures, processes, and analyzes this data to provide valuable information, including user engagement levels, the most active repositories, bot identification, popular event types, and daily commit patterns. By developing a robust data pipeline and analytics framework, this project enables stakeholders to gain deeper insights into how GitHub is utilized, revealing trends in developer activity, popular project contributions, and overall platform health. The resulting data-driven insights support product, engineering, and community initiatives aimed at improving the GitHub experience for developers worldwide.

# Objective
The main objective of this project is as below:
- Develop an efficient data engineering pipeline using PySpark to extract data from a web API and ingest it into Google Cloud Storage (GCS).
- Transform and load raw data from GCS into Google BigQuery as the data warehousing solution.
- Use dbt Cloud to transform raw data into a star schema and create materialized views based on this schema for optimized analysis.
- Visualize the data using Looker, leveraging materialized views for enhanced performance and insights.
