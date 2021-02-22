# Statistical Analysis of Medicare Payments
### Overview
Medicare Payments data is mergied with the Inpatient Prospect Payment System (IPPS) and the Total Performance Score(TPS) of the hospitals. Clinical Outcomes Score, Efficiency and Cost Reduction Score, Safety Score, Community and Engagement Score, these four types of hospital scores are considered to get the results. With the introduction of the Inpatient Prospective Payment System (IPPS), it is assumed that all DRGs are paid out uniformly to the various hospitals with an adjustment for location and prevailing wage index. However, Medicare costs have been rising year on year. While this increase is in part due to the increasing costs of drugs and its monopolization by pharma cos, hospitals are also constantly investing money in improving their facilities. With the hospitals seeking to make a profit on their investments, the concern over hospital overbilling Medicare arises.

#### analysis aims to answer the following questions,
- Are medical providers paid the same across the United States by Medicare for each Diagnosis Related Group (DRG)?
- How do extra charges (service charges) vary across different medical facilities in the state of Florida?
- How do out-of-pocket charges vary across the United State for each Diagnosis Related Group (DRG)?

### Data Source and Exploration 
Our primary data source for the analysis was the Data portal on the Centers for Medicare & Medicaid Services’ website. The Inpatient Prospective Payment System data file for 2017 provides a provider-level summary for the top 100 Diagnosis Related Groups. Each record represents an aggregated measure of medicare payments, provider billing and total covered charges for every combination of DRG & hospitals participating in the program.

In order to control for the impact of the hospital’s performance measures on the medicare payouts, we integrated the Hospital Value Based Purchasing System (HVBPS) data. Each record represents a participating medical provider’s score summary across the four domains - safety, community & engagement, clinical outcomes and efficiency.

Finally, we used the Census Bureau's 2017 estimates for population across the various counties, cities and states and prevailing wage estimates to control for the differences in population and cost of living during our analysis.

### Exploratory Data Analysis

