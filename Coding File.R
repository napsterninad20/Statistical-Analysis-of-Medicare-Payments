rm(list=ls())
#-----------------IMPORTING LIBRARIES-----------------------------------

library(readxl)
library(plyr)
library(tidyr)
library(lme4) 
library(dplyr)

#-----------------IMPORTING THE DATASETS------------------------------------
#-----------------IMPORTING HVP PERFORMACE SCORES---------------------------

perf_score = read_excel("performance_scores.xlsx")
colnames(perf_score) = tolower(make.names(colnames(perf_score)))
attach(perf_score)
summary(perf_score)

#-----------------IPPS FY 2017 DATA---------------------------

ipps_payment = read_excel("IPPS FY 2017 Data.xlsx")
colnames(ipps_payment) = tolower(make.names(colnames(ipps_payment)))
attach(ipps_payment)
summary(ipps_payment)

#-----------------Statewise Population--------------------------
population = read_excel("State County Level Population 2017.xlsx")
colnames(population) = tolower(make.names(colnames(population)))
attach(population)
summary(population)

#----------------- Statewise Average Income ---------------------------

income = read_excel("house_income.xlsx")
colnames(income) = tolower(make.names(colnames(income)))
attach(income)
summary(income)

#-----------------RENAMING VARIABLE/FEATURES TO MAKE THEM CONSISTENT----------------

names(ipps_payment)
names(perf_score)

names(perf_score)[names(perf_score) == "?..facility.id"] <- "facility.id"
names(ipps_payment)[names(ipps_payment) == "provider.id"] <- "facility.id"

#-----------------PERFORMING INNER JOIN TO COMBINE BOTH DATASETS BASED ON 'FACILITY_ID'-----------

master_dataset = join(ipps_payment, perf_score, type = "inner") # Join should be by facility ID
income_population = join(population, income, type = "inner") #Merging Income and Population Dataset
master_dataset = join(master_dataset, income_population, type = "inner") #Final dataset

#--------------------DATA PREPROCESSING-----------------------------------------------------

names(master_dataset)
master_dataset = separate(data = master_dataset, col = drg.definition, into = c("drg.code", "drg.description"), sep = "\\-")
master_dataset = separate(data = master_dataset, col = hospital.referral.region..hrr..description, into = c("hospital.state", "hospital.region"), sep = "\\-")

#---------------IMPORTING FINAL PREPROCESSED DATA INTO A NEW DATAFRAME-----------------------------------------

clean_dataset = subset(master_dataset, select = -c(facility.name, address, city, state, zip.code, location, hospital.state, hospital.region))

clean_dataset <- clean_dataset[!(clean_dataset$unweighted.normalized.clinical.outcomes.domain.score == "Not Available"
                                  | clean_dataset$weighted.normalized.clinical.outcomes.domain.score == "Not Available"
                                  | clean_dataset$unweighted.person.and.community.engagement.domain.score == "Not Available"
                                  | clean_dataset$weighted.person.and.community.engagement.domain.score == "Not Available"
                                  | clean_dataset$unweighted.normalized.safety.domain.score == "Not Available"
                                  | clean_dataset$weighted.safety.domain.score == "Not Available"
                                  | clean_dataset$unweighted.normalized.efficiency.and.cost.reduction.domain.score == "Not Available"
                                  | clean_dataset$weighted.efficiency.and.cost.reduction.domain.score == "Not Available"
                                 ),]


#------------------------Changing Columns names---------------------------------

names(clean_dataset)[names(clean_dataset) == "drg.code"] <- "drg_code"
names(clean_dataset)[names(clean_dataset) == "drg.description"] <- "drg_description"
names(clean_dataset)[names(clean_dataset) == "facility.id"] <- "facility_id"
names(clean_dataset)[names(clean_dataset) == "provider.name"] <- "provider_name"
names(clean_dataset)[names(clean_dataset) == "provider.street.address"] <- "provider_street_address"
names(clean_dataset)[names(clean_dataset) == "provider.city"] <- "provider_city"
names(clean_dataset)[names(clean_dataset) == "provider.zip.code"] <- "provider_zipcode"
names(clean_dataset)[names(clean_dataset) == "provider.state"] <- "provider_state"
names(clean_dataset)[names(clean_dataset) == "total.discharges"] <- "total_discharges"
names(clean_dataset)[names(clean_dataset) == "average.covered.charges"] <- "avg_covered_charges"
names(clean_dataset)[names(clean_dataset) == "average.total.payments"] <- "avg_total_pymnts"
names(clean_dataset)[names(clean_dataset) == "average.medicare.payments"] <- "avg_medicare_pymnts"
names(clean_dataset)[names(clean_dataset) == "county.name"] <- "county"
names(clean_dataset)[names(clean_dataset) == "unweighted.normalized.clinical.outcomes.domain.score"] <- "unweighted_clinical_score"
names(clean_dataset)[names(clean_dataset) == "weighted.normalized.clinical.outcomes.domain.score"] <- "weighted_clinical_score"
names(clean_dataset)[names(clean_dataset) == "unweighted.person.and.community.engagement.domain.score"] <- "unweighted_community_score"
names(clean_dataset)[names(clean_dataset) == "weighted.person.and.community.engagement.domain.score"] <- "weighted_community_score"
names(clean_dataset)[names(clean_dataset) == "unweighted.normalized.safety.domain.score"] <- "unweighted_safety_score"
names(clean_dataset)[names(clean_dataset) == "weighted.safety.domain.score"] <- "weighted_safety_score"
names(clean_dataset)[names(clean_dataset) == "unweighted.normalized.efficiency.and.cost.reduction.domain.score"] <- "unweighted_costreduction_score"
names(clean_dataset)[names(clean_dataset) == "weighted.efficiency.and.cost.reduction.domain.score"] <- "weighted_costreduction_score"
names(clean_dataset)[names(clean_dataset) == "total.performance.score"] <- "total_performance_score"
names(clean_dataset)[names(clean_dataset) == "average.income.per.household"] <- "avg_income/house"

#---------------------- Generating Features ------------------------------

clean_dataset$avg_outofpocket_pymnts = (clean_dataset$avg_total_pymnts - clean_dataset$avg_medicare_pymnts)

clean_dataset$avg_extra_pymnts = clean_dataset$avg_covered_charges - clean_dataset$avg_total_pymnts

#----------------------converting scores to numeric and removing outlier values--------------

clean_dataset$unweighted_clinical_score = as.numeric(clean_dataset$unweighted_clinical_score)
clean_dataset$weighted_clinical_score = as.numeric(clean_dataset$weighted_clinical_score)
clean_dataset$unweighted_community_score = as.numeric(clean_dataset$unweighted_community_score)
clean_dataset$weighted_community_score = as.numeric(clean_dataset$weighted_community_score)
clean_dataset$unweighted_safety_score = as.numeric(clean_dataset$unweighted_safety_score)
clean_dataset$weighted_safety_score = as.numeric(clean_dataset$weighted_safety_score)
clean_dataset$unweighted_costreduction_score = as.numeric(clean_dataset$unweighted_costreduction_score)
clean_dataset$weighted_costreduction_score = as.numeric(clean_dataset$weighted_costreduction_score)
is.num <- sapply(clean_dataset, is.numeric)
is.num
clean_dataset[is.num] <- lapply(clean_dataset[is.num], round, 4)

#----------------------------------Some Visualization---------------------------
library(lattice)
bwplot(~avg_outofpocket_pymnts | provider_state, data=clean_dataset, 
       main = "Out of Pocket Payments")

bwplot(~avg_covered_charges | provider_state, data=clean_dataset, 
       main = "Covered Charges")



#--------------------------------------Scaling variables-------------------------------------------
clean_dataset$total_discharges = scale(clean_dataset$total_discharges)
clean_dataset$avg_covered_charges = scale(clean_dataset$avg_covered_charges)
clean_dataset$avg_total_pymnts = scale(clean_dataset$avg_total_pymnts)
clean_dataset$avg_medicare_pymnts = scale(clean_dataset$avg_medicare_pymnts)

clean_dataset$weighted_clinical_score = scale(clean_dataset$weighted_clinical_score)
clean_dataset$weighted_community_score = scale(clean_dataset$weighted_community_score)
clean_dataset$weighted_safety_score = scale(clean_dataset$weighted_safety_score)
clean_dataset$weighted_costreduction_score = scale(clean_dataset$weighted_costreduction_score)

#clean_dataset$avg_outofpocket_pymnts = scale(clean_dataset$avg_outofpocket_pymnts)
#clean_dataset$avg_extra_pymnts = scale(clean_dataset$avg_extra_pymnts)

colSums(is.na(clean_dataset))
sum(is.na(clean_dataset))

attach(clean_dataset)
#-------------------storing updated dataframe into the file for reference-------------
write.csv(clean.dataset, "project_dataset.csv")
#dataset = read.csv("project_combined_dataset_final.csv")

#-------------------DATA EXPLORATION-----------------------------------------------

#-------------------EXLORING THE DISTRIBUTION OF THE PREDICTORS------------------------------------------

hist(total_discharges, col="skyblue") #Rightskewed
hist(log(total_discharges), col="green") #Looks better hence could be used as the predictor. 

hist(avg_outofpocket_pymnts, col = "blue")
hist(log(avg_outofpocket_pymnts), col = "pink")

hist(avg_extra_pymnts, col = "blue")
hist(log(avg_extra_pymnts), col = "pink")

#-------------------CONVERTING CATEGORICAL VARIABLES INTO FACTORS----------------------------------------
clean_dataset$drg_code <- factor(clean_dataset$drg_code)
levels(clean_dataset$drg_code)

clean_dataset$provider_city <- factor(clean_dataset$provider_city)
levels(clean_dataset$provider_city)

clean_dataset$provider_state <- factor(clean_dataset$provider_state)
levels(clean_dataset$provider_state)

clean_dataset$county <- factor(clean_dataset$county)
levels(clean_dataset$county)

clean_dataset$facility_id <- factor(clean_dataset$facility_id)
levels(clean_dataset$facility_id)

#---------------- Random Effect Model Average Payment varying across DRG codes in Different states

#4) How much Out of pocket expense vary according to state?
avg_outofpocket_pymnts_states = 
  lmer(avg_outofpocket_pymnts ~ total_discharges + avg_covered_charges
                                     + avg_medicare_pymnts + weighted_clinical_score
                                     + weighted_community_score + weighted_costreduction_score
                                     + weighted_safety_score + (1 | provider_state) + (1 |drg_code),
                                     data = clean_dataset, REML = FALSE)
summary(avg_outofpocket_pymnts_states)

confint(avg_outofpocket_pymnts_states)
AIC(avg_outofpocket_pymnts_states)
fixef(avg_outofpocket_pymnts_states)        # Magnitude of fixed effect
ranef(avg_outofpocket_pymnts_states)        # Magnitude of random effect
coef(avg_outofpocket_pymnts_states) 


tempo = subset(clean_dataset, provider_state == "FL")
attach(tempo)
avg_extra_pymnts_fl = 
  lmer(avg_extra_pymnts ~ total_discharges + avg_covered_charges + 
       + avg_medicare_pymnts + weighted_clinical_score
       + weighted_community_score + weighted_costreduction_score
       + weighted_safety_score + (1 | facility_id) + (1 | drg_code),
       data = tempo , REML = FALSE)
summary(avg_extra_pymnts_fl)
options(max.print = 99999999)
ranef(avg_extra_pymnts_fl)



