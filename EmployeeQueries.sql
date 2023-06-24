-- Table: public.EmployeeSalaries

-- DROP TABLE IF EXISTS public."EmployeeSalaries";

CREATE TABLE IF NOT EXISTS public."EmployeeSalaries"
(
    lastName text,
    middleInitial text,
    firstName text,
    jobClass text,
    agencyName text,
    agencyID text,
    annualSalary numeric,
    grossPay double precision,
    hireDate date,
    fiscalYear text,
    ObjectId integer
);

ALTER TABLE IF EXISTS public."EmployeeSalaries"
    OWNER TO postgres;
	
SELECT *
FROM public."EmployeeSalaries"
	
-- Who were the top ten highest paid employees in 2021 according to salary?
SELECT firstName, lastName, annualSalary, grossPay
FROM public."EmployeeSalaries"
WHERE fiscalYear = 'FY2021'
ORDER BY annualSalary DESC
LIMIT 10;

-- Who were the top ten highest paid employees in 2021 according to gross pay?
SELECT firstName, lastName, annualSalary, grossPay
FROM public."EmployeeSalaries"
WHERE fiscalYear = 'FY2021'
ORDER BY grossPay DESC
LIMIT 10;

-- How many employees were there in each job class in FY2021?
SELECT jobClass, COUNT(*) AS employeeCount
FROM public."EmployeeSalaries"
WHERE fiscalYear = 'FY2021'
GROUP BY jobClass
ORDER BY employeeCount DESC;

-- What is the average gross pay for each agency in FY2021?
SELECT agencyName, ROUND(AVG(grossPay)::numeric, 2) AS averageGrossPay
FROM public."EmployeeSalaries"
WHERE fiscalYear = 'FY2021'
GROUP BY agencyName
ORDER BY averageGrossPay DESC;

-- Side by side comparison for each agency FY2011-FY2021
SELECT * FROM crosstab(
  'SELECT agencyName, fiscalYear, ROUND(AVG(grossPay)::numeric, 2) AS averageGrossPay
   FROM public."EmployeeSalaries"
   WHERE fiscalYear BETWEEN ''FY2011'' AND ''FY2021''
   GROUP BY agencyName, fiscalYear
   ORDER BY agencyName, fiscalYear'
) AS (
  "Agency Name" text,
  "FY2011" numeric, "FY2012" numeric, "FY2013" numeric,
  "FY2014" numeric, "FY2015" numeric, "FY2016" numeric,
  "FY2017" numeric, "FY2018" numeric, "FY2019" numeric,
  "FY2020" numeric, "FY2021" numeric
);

-- Which employees have been with the city the longest based on their hire date (excluding 1900-01-01)?
SELECT firstName, lastName, hireDate
FROM public."EmployeeSalaries"
WHERE hireDate != '1900-01-01'
ORDER BY hireDate ASC
LIMIT 10;

-- What is the total annual salary expenditure for each fiscal year and the number of employees?
SELECT fiscalYear, TO_CHAR(SUM(annualSalary), '9,999,999,999') AS totalExpenditure, COUNT(*) AS employeeCount
FROM public."EmployeeSalaries"
GROUP BY fiscalYear
ORDER BY fiscalYear;

-- What is the highest annual salary earned by an employee in each agency?
SELECT agencyName, MAX(annualSalary) AS highestSalary
FROM public."EmployeeSalaries"
WHERE fiscalYear = 'FY2021'
GROUP BY agencyName
ORDER BY highestSalary DESC;

-- Find the employees with the highest gross pay relative to their annual salary:
SELECT firstName, lastName, jobClass, agencyName, annualSalary, grossPay,
       CASE WHEN annualSalary <> 0 THEN (grossPay / annualSalary) ELSE NULL END AS grossPayRatio
FROM public."EmployeeSalaries"
WHERE annualSalary <> 0
ORDER BY grossPayRatio DESC
LIMIT 10;

-- Identify the employees who have had the highest increase in salary from one fiscal year to the next:
SELECT currentYear.firstName, currentYear.lastName, currentYear.fiscalYear AS currentFiscalYear,
       previousYear.fiscalYear AS previousFiscalYear,
       currentYear.annualSalary AS currentSalary, previousYear.annualSalary AS previousSalary,
       (currentYear.annualSalary - previousYear.annualSalary) AS salaryIncrease
FROM public."EmployeeSalaries" AS currentYear
JOIN public."EmployeeSalaries" AS previousYear
    ON currentYear.firstName = previousYear.firstName
    AND currentYear.lastName = previousYear.lastName
    AND currentYear.fiscalYear = CONCAT('FY', CAST(CAST(SUBSTRING(previousYear.fiscalYear, 3) AS integer) + 1 AS varchar))
WHERE currentYear.annualSalary > previousYear.annualSalary
ORDER BY salaryIncrease DESC
LIMIT 10;

-- Calculate the average annual salary for employees hired in each year:
SELECT EXTRACT(YEAR FROM hireDate) AS hireYear, ROUND(AVG(annualSalary)::numeric, 2) AS averageSalary
FROM public."EmployeeSalaries"
WHERE hireDate <> '1900-01-01'
GROUP BY EXTRACT(YEAR FROM hireDate)
ORDER BY EXTRACT(YEAR FROM hireDate);

-- Determine the total gross pay for each job class:
SELECT jobClass, ROUND(SUM(grossPay)::numeric, 2) AS totalGrossPay
FROM public."EmployeeSalaries"
GROUP BY jobClass;

-- Find the employees who have changed job classes over time:
SELECT DISTINCT e1.firstName, e1.lastName, e1.jobClass AS previousJobClass, e2.jobClass AS currentJobClass,
       e1.fiscalYear AS previousFiscalYear, e2.fiscalYear AS currentFiscalYear
FROM public."EmployeeSalaries" e1
JOIN public."EmployeeSalaries" e2
    ON e1.firstName = e2.firstName
    AND e1.lastName = e2.lastName
    AND e1.fiscalYear = CONCAT('FY', CAST(CAST(SUBSTRING(e2.fiscalYear, 3) AS integer) - 1 AS varchar))
WHERE e1.jobClass <> e2.jobClass
ORDER BY e1.lastName, e1.firstName, e1.fiscalYear;


