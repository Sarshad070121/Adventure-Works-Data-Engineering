# AdventureWorks Azure Data Engineering Project

An end-to-end Azure data engineering project built using **Azure Data Factory, Azure Data Lake Storage Gen2, Azure Databricks, PySpark, Azure Synapse Analytics, and Power BI**.

The project follows a **Bronze → Silver → Gold** architecture and covers the complete flow from data ingestion to reporting.

---

## Architecture

```text
                         ┌──────────────────┐
                         │   AdventureWorks │
                         │      Dataset     │
                         └────────┬─────────┘
                                  │
                                  ▼
                    ┌─────────────────────────┐
                    │    Azure Data Factory   │
                    │                         │
                    │  • Data Ingestion       │
                    │  • Parameterization     │
                    │  • Pipeline Orchestration│
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │       ADLS Gen2         │
                    │      Bronze Layer       │
                    │                         │
                    │      Raw Data           │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │    Azure Databricks     │
                    │        PySpark          │
                    │                         │
                    │  • Data Transformation  │
                    │  • Data Cleaning        │
                    │  • Data Processing      │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │       ADLS Gen2         │
                    │       Silver Layer      │
                    │                         │
                    │        Parquet          │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │    Azure Synapse        │
                    │                         │
                    │  • Gold Views           │
                    │  • OPENROWSET()         │
                    │  • External Tables      │
                    │  • External Data Sources│
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │    Synapse SQL Endpoint │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │        Power BI         │
                    │       Reporting         │
                    └─────────────────────────┘
```

---

## Project Overview

The objective of this project was to build an end-to-end cloud data pipeline using the AdventureWorks dataset.

The pipeline separates the different stages of data processing:

* **Azure Data Factory** handles data ingestion and orchestration.
* **ADLS Gen2 Bronze** stores the incoming raw data.
* **Azure Databricks + PySpark** performs data transformation.
* **ADLS Gen2 Silver** stores the transformed data in Parquet format.
* **Azure Synapse** provides the Gold layer through views and external tables.
* **Power BI** connects through the Synapse SQL endpoint for reporting.

This project helped me work through the different components of an Azure data engineering pipeline rather than focusing only on the transformation layer.

---

# Technologies Used

| Technology                   | Purpose                                               |
| ---------------------------- | ----------------------------------------------------- |
| Azure Data Factory           | Data ingestion and pipeline orchestration             |
| Azure Data Lake Storage Gen2 | Bronze and Silver data storage                        |
| Azure Databricks             | Data processing environment                           |
| PySpark                      | Data transformation                                   |
| Azure Synapse Analytics      | Gold layer and external data access                   |
| Parquet                      | Silver data storage format                            |
| Power BI                     | Reporting and visualization                           |
| Managed Identity             | Authentication for external data access               |
| SQL                          | Views, external data sources, file formats and tables |

---

# Pipeline Stages

## 1. Data Ingestion — Azure Data Factory

Azure Data Factory was used to move the AdventureWorks source data into ADLS Gen2.

I implemented:

* A single data-pull pipeline
* A dynamic data-pull pipeline
* Parameterized source configuration
* Parameterized sink configuration
* Copy activities for data movement

The dynamic pipeline allows the same pipeline structure to be used for different datasets instead of creating separate configurations for each one.

### ADF Pipeline

![Azure Data Factory Pipeline](screenshots/adf-pipeline.png)

> Add your actual screenshot path here if you store the screenshots inside the repository.

---

# 2. Bronze Layer — ADLS Gen2

The data ingested through Azure Data Factory was stored in the Bronze layer of ADLS Gen2.

The Bronze layer acts as the raw landing area before transformation.

```text
Source
  ↓
Azure Data Factory
  ↓
ADLS Gen2
  ↓
Bronze
```

---

# 3. Data Transformation — Azure Databricks + PySpark

The Bronze data was then processed using Azure Databricks and PySpark.

The transformation stage included:

* Reading data from the Bronze layer
* Working with PySpark DataFrames
* Cleaning and transforming datasets
* Applying data types
* Preparing datasets for downstream consumption
* Writing the processed data to the Silver layer

```text
Bronze
   ↓
Azure Databricks
   ↓
PySpark
   ↓
Transformations
   ↓
Silver
```

---

# 4. Silver Layer — ADLS Gen2

The transformed datasets were written to the Silver layer in ADLS Gen2.

The data was stored in **Parquet format**.

The Silver layer contains datasets including:

* Calendar
* Customers
* Products
* Returns
* Sales
* Subcategories
* Territories

```text
ADLS Gen2
└── Silver
    ├── AdventureWorks_Calendar
    ├── AdventureWorks_Customers
    ├── AdventureWorks_Products
    ├── AdventureWorks_Returns
    ├── AdventureWorks_Sales
    ├── AdventureWorks_SubCategories
    └── AdventureWorks_Territories
```

---

# 5. Gold Layer — Azure Synapse Analytics

The Gold layer was created using Azure Synapse Analytics.

Instead of creating another physical copy of the Silver data, I created views in the `gold` schema.

The views use `OPENROWSET()` to read the Silver Parquet files directly from ADLS Gen2.

Example:

```sql
CREATE VIEW gold.sales
AS
SELECT 
    *
FROM 
    OPENROWSET
    (
        BULK 'https://<storage-account>.blob.core.windows.net/silver/AdventureWorks_Sales/',
        FORMAT = 'PARQUET'
    ) AS QUERY1;
```

Gold views created:

```text
gold.calendar
gold.customers
gold.products
gold.returns
gold.sales
gold.subcat
gold.territories
```

This approach allowed the Gold layer to expose the processed Silver data without creating another copy of the underlying Parquet files.

---

# 6. Synapse External Data Access

I also worked with external tables in Synapse to understand how Synapse can access data stored outside the database.

## Database Master Key

The setup started with a database master key:

```sql
CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'your_password_here';
```

> Never commit the actual password to GitHub.

---

## Database-Scoped Credential

A database-scoped credential was created using Managed Identity:

```sql
CREATE DATABASE SCOPED CREDENTIAL cred_arshad
WITH
    IDENTITY = 'Managed Identity';
```

This allows Synapse to use the workspace Managed Identity for accessing the external data.

---

# 7. External Data Sources

External data sources were created for the Silver and Gold locations in ADLS Gen2.

### Silver

```sql
CREATE EXTERNAL DATA SOURCE source_silver
WITH
(
    LOCATION = 'https://<storage-account>.blob.core.windows.net/silver',
    CREDENTIAL = cred_arshad
);
```

### Gold

```sql
CREATE EXTERNAL DATA SOURCE source_gold
WITH
(
    LOCATION = 'https://<storage-account>.blob.core.windows.net/gold',
    CREDENTIAL = cred_arshad
);
```

The storage account URL has been replaced with a placeholder in this README.

---

# 8. External File Format

Since the data was stored as Parquet, I created an external file format:

```sql
CREATE EXTERNAL FILE FORMAT format_parquet
WITH
(
    FORMAT_TYPE = PARQUET,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
);
```

This defines Parquet as the external file format and specifies the compression codec.

---

# 9. External Table

I then created an external table for the Sales data using the Gold external data source and Parquet file format.

```sql
CREATE EXTERNAL TABLE gold.extsales
WITH
(
    LOCATION = 'extsales',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)
AS
SELECT * FROM gold.sales;
```

The table was then queried to verify the data:

```sql
SELECT * FROM gold.extsales;
```

The external table setup can be summarized as:

```text
Managed Identity
       ↓
Database Scoped Credential
       ↓
External Data Source
       ↓
External File Format
       ↓
External Table
       ↓
Gold Sales Data
```

---

# 10. Power BI Integration

The final stage was connecting the Synapse layer to Power BI.

Power BI was connected using the **Synapse SQL endpoint**.

The reporting flow was:

```text
ADLS Gen2 Silver
       ↓
Azure Synapse
       ↓
Gold Views / External Tables
       ↓
Synapse SQL Endpoint
       ↓
Power BI
```

Power BI was then used to work with the data exposed through the Synapse layer.

---

# Data Validation

I performed checks at different stages of the pipeline, including:

* Dataset availability
* Record counts
* Column names
* Data types
* Silver-layer output
* Parquet data accessibility
* Gold view results
* External table results
* Power BI data availability

These checks helped verify that the data was moving correctly between the different layers.

---

# Project Structure

A suggested repository structure is:

```text
AdventureWorks-Azure-Data-Engineering/
│
├── README.md
│
├── ADF/
│   ├── pipelines/
│   ├── datasets/
│   └── linked-services/
│
├── Databricks/
│   └── notebooks/
│
├── Synapse/
│   ├── views/
│   ├── external-data-sources/
│   ├── external-file-format/
│   └── external-tables/
│
├── PowerBI/
│   └── screenshots/
│
└── screenshots/
    ├── adf-pipeline.png
    ├── bronze-layer.png
    ├── databricks.png
    ├── silver-layer.png
    ├── synapse-gold.png
    ├── external-table.png
    └── powerbi.png
```

Adjust the structure based on the actual files you have in the repository.

---

# Key Concepts Covered

Through this project, I worked with:

* Azure Data Factory pipelines
* Parameterized data ingestion
* ADLS Gen2
* Bronze/Silver/Gold architecture
* Azure Databricks
* PySpark transformations
* Parquet
* Azure Synapse Analytics
* `OPENROWSET()`
* Synapse views
* Database master keys
* Managed Identity
* Database-scoped credentials
* External data sources
* External file formats
* External tables
* Synapse SQL endpoint
* Power BI integration
* Data validation

---

# End-to-End Flow

```text
                    AdventureWorks
                          │
                          ▼
                Azure Data Factory
                          │
                          ▼
                    ADLS Gen2
                   Bronze Layer
                          │
                          ▼
                Azure Databricks
                     PySpark
                          │
                          ▼
                    ADLS Gen2
                   Silver Layer
                     Parquet
                          │
                          ▼
                 Azure Synapse
                          │
             ┌────────────┴────────────┐
             │                         │
        Gold Views               External Tables
       OPENROWSET()                     │
             │                         │
             └────────────┬────────────┘
                          ▼
                  Synapse SQL Endpoint
                          │
                          ▼
                      Power BI
```

---

# Dataset

The AdventureWorks dataset used in this project was sourced from Kaggle: https://www.kaggle.com/datasets/ukveteran/adventure-works

---

# Reference

This project was built using **Ansh Lamba's AdventureWorks Data Engineering project and walkthrough as a reference**.

[The implementation was used as a hands-on exercise to work through the Azure services and pipeline architecture.](https://github.com/anshlambaoldgit/Adventure-Works-Data-Engineering-Project/tree/main)

---
