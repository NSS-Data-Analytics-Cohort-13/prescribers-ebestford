SELECT *
FROM cbsa

SELECT * 
FROM drug

SELECT *
FROM fips_county

SELECT *
FROM overdose_deaths

SELECT *
FROM population

SELECT * 
FROM prescriber

SELECT * 
FROM prescription

SELECT *
FROM zip_fips



--1.  a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, total_claim_count
FROM prescription
ORDER BY total_claim_count DESC;

--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT  prescrip.npi AS npi, prescrib.nppes_provider_first_name AS nppes_provider_first_name, prescrib.nppes_provider_last_org_name AS nppes_provider_last_org_name,  prescrib.specialty_description AS specialty_description, prescrip.total_claim_count AS total_claim_count
FROM prescription AS prescrip
INNER JOIN prescriber AS prescrib
ON prescrip.npi=prescrib.npi
ORDER BY total_claim_count DESC;
--something funky with my on and wanting it to be the alias

--2. a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT prescrib.specialty_description AS specialty_description, prescrip.total_claim_count AS total_claim_count
FROM prescription AS prescrip
INNER JOIN prescriber AS prescrib
ON prescrip.npi=prescrib.npi
ORDER BY total_claim_count DESC;
--Family Practice

--b. Which specialty had the most total number of claims for opioids?

SELECT drug.opioid_drug_flag AS opioid_drug_flag, prescrib.specialty_description AS specialty_description, prescrip.total_claim_count AS total_claim_count
FROM prescriber AS prescrib
INNER JOIN prescription AS prescrip
ON prescrib.npi=prescrip.npi
INNER JOIN drug 
ON drug.drug_name=prescrip.drug_name
WHERE  opioid_drug_flag ='Y'
ORDER BY total_claim_count DESC;
--Family Practice

--3. a. Which drug (generic_name) had the highest total drug cost?
SELECT drug.generic_name AS generic_name, prescrip.total_drug_cost AS total_drug_cost
FROM prescription AS prescrip
LEFT JOIN drug AS drug
ON prescrip.drug_name=drug.drug_name
ORDER BY total_drug_cost DESC;
--PIRFENIDONE

--b. Which drug (generic_name) has the hightest total cost per day? 
SELECT drug.generic_name AS generic_name, CAST(total_drug_cost as float)/total_30_day_fill_count AS total_cost_per_day
FROM prescription 
LEFT JOIN drug AS drug
ON prescription.drug_name=drug.drug_name
ORDER BY total_cost_per_day DESC;
--ASFOTASE ALFA
--Come back to understand CAST function more

--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT 
	drug_name, 
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
		ELSE 'Neither'
END AS drug_type
FROM drug;

--4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT 
	total_drug_cost
	drug_name, 
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
		ELSE 'Neither'
END AS drug_type
FROM drug;
