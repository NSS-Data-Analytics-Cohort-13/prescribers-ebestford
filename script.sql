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
--PIRFENIDONE,::MONEY?

--b. Which drug (generic_name) has the hightest total cost per day? 
SELECT drug.generic_name AS generic_name, CAST(total_drug_cost as float)/total_30_day_fill_count AS total_cost_per_day
FROM prescription 
LEFT JOIN drug AS drug
ON prescription.drug_name=drug.drug_name
ORDER BY total_cost_per_day DESC;
--ASFOTASE ALFA
--Come back to understand CAST function more
--NEED TO FINISH, NOT CORRECT


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
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
		ELSE 'Neither'
END AS drug_type,
	SUM(total_drug_cost) AS total_cost
FROM drug
JOIN prescription
ON drug.drug_name=prescription.drug_name
WHERE opioid_drug_flag = 'Y' OR antibiotic_drug_flag = 'Y' 
GROUP BY drug_type
ORDER BY total_cost DESC;
--Opioid's have the higher drug cost
--Figure out ::MONEY

--5. a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT(cbsaname)
FROM cbsa
WHERE cbsaname ILIKE '%TN%'
--58


--b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT cbsa, MAX(population) AS highest_population, MIN(population) AS smallest_population
FROM cbsa
JOIN population
ON cbsa.fipscounty=population.fipscounty
GROUP BY cbsa;
--DONT THINK THIS IS IT

SELECT cbsa, population
FROM cbsa
INNER JOIN population
ON cbsa.fipscounty=population.fipscounty
ORDER BY population DESC;
--Highest population CBSA 32820,937847

SELECT cbsa, population
FROM cbsa
INNER JOIN population
ON cbsa.fipscounty=population.fipscounty
ORDER BY population;
--Lowest population CBSA 34980, 8773

--c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT cbsa,cbsaname, population
FROM zip_fips
INNER JOIN population
ON zip_fips.fipscounty=population.fipscounty
LEFT JOIN cbsa
ON cbsa.fipscounty=population.fipscounty
WHERE cbsa IS NULL
	AND cbsaname IS NOT NULL
ORDER BY population DESC 
--Not right, trying to figure it out

--6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000

-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT prescrip.drug_name AS drug_name, prescrip.total_claim_count AS total_claim_count, drug.opioid_drug_flag AS opioid_drug_flag
FROM prescriber AS prescrib
INNER JOIN prescription AS prescrip
ON prescrib.npi=prescrip.npi
INNER JOIN drug AS drug
ON prescrip.drug_name=drug.drug_name
WHERE total_claim_count >= 3000
	AND opioid_drug_flag = 'Y';

--c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT prescrip.drug_name AS drug_name, prescrip.total_claim_count AS total_claim_count, drug.opioid_drug_flag AS opioid_drug_flag, prescrib.nppes_provider_first_name AS nppes_provider_first_name, prescrib.nppes_provider_last_org_name AS nppes_provider_last_org_name
FROM prescriber AS prescrib
INNER JOIN prescription AS prescrip
ON prescrib.npi=prescrip.npi
INNER JOIN drug AS drug
ON prescrip.drug_name=drug.drug_name
WHERE total_claim_count >= 3000
	AND opioid_drug_flag = 'Y';

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT drug.drug_name, specialty_description, nppes_provider_city, opioid_drug_flag
FROM prescriber
INNER JOIN prescription
ON prescriber.npi=prescription.npi
INNER JOIN drug AS drug
ON drug.drug_name=prescription.drug_name
WHERE opioid_drug_flag = 'Y'
	AND specialty_description= 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE';
--35 rows

--b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
SELECT prescrip.npi, prescrib.nppes_provider_last_org_name AS nppes_provider_last_org_name, drug_name, total_claim_count
FROM prescription AS prescrip
LEFT JOIN  prescriber AS prescrib
ON prescrib.npi=prescrip.npi
WHERE total_claim_count = 'Null' AS '0'
--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

