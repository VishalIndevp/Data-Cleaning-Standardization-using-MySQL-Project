-- Data Cleaning
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns


SELECT * FROM layoffs;

CREATE TABLE layoff_staging
LIKE layoffs;

SELECT * FROM layoff_staging;

INSERT layoff_staging
SELECT * 
FROM layoffs;

-- 1. Remove Duplicates
SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`) AS Row_Num
FROM layoff_staging;

WITH duplicate_cte AS
(
SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY company, location, industry, 
 total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_Num
FROM layoff_staging
)
SELECT * FROM 
duplicate_cte
WHERE ROW_Num >1;

SELECT *
from layoff_staging
WHERE company = 'Casper';


WITH duplicate_cte AS
(
SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY company, location, industry, 
 total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_Num
FROM layoff_staging
)
DELETE  FROM 
duplicate_cte
WHERE ROW_Num >1;


CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percelayoff_staging2ntage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoff_staging2
;

INSERT INTO layoff_staging2
SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY company, location,
 industry, total_laid_off, percentage_laid_off, `date`, stage, 
 country, funds_raised_millions) AS row_num
FROM layoff_staging
;

SELECT * 
FROM layoff_staging2
WHERE row_num >1;


-- We deleted the Duplicates Values
DELETE 
FROM layoff_staging2
WHERE row_num >1;

SELECT * 
FROM layoff_staging2
WHERE row_num >1;


-- 2. Standardize the Data

SELECT company, TRIM(company)
FROM layoff_staging2;

UPDATE layoff_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoff_staging2
ORDER BY 1;

SELECT DISTINCT industry
FROM layoff_staging2;

SELECT *
FROM layoff_staging2
WHERE industry LIKE 'crypto%';

-- Updating Crypto Currency to crypto
UPDATE layoff_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

-- Lets Now see to location
SELECT DISTINCT location
FROM layoff_staging2
ORDER BY 1;
-- This is fine


SELECT DISTINCT country
FROM layoff_staging2
ORDER BY 1;
-- Yes we have a issue in this which is United States.

SELECT *
FROM layoff_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;

-- Now lets TRIM it United States.
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) ## TRALING means coming at the end 
FROM layoff_staging2
ORDER BY 1;

-- Now lets UPDATE this 
UPDATE layoff_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Let's check it is updated 
SELECT DISTINCT country
FROM layoff_staging2
ORDER BY 1;
-- ** YES it is fixed


-- OUR date column is defination: is text 
-- Let's change this
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoff_staging2;

-- HERE we updating the date
UPDATE layoff_staging2
SET `date`= STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date`;

-- NOW let's see our date column is updated or not
SELECT date
FROM layoff_staging2;
-- *YES it is

-- NOW lets MODIFY date column
ALTER TABLE layoff_staging2
MODIFY `date` DATE;
-- * YES we did that


-- 3. Null Values or blank values
SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT *
FROM layoff_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoff_staging2
WHERE company = 'Airbnb';
-- * SO we have been seen that Airbnb company have a complete value and one is not
-- LET's see how can we fix this now

-- USING JOINS
SELECT *
FROM layoff_staging2 t1
JOIN layoff_staging2 T2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL OR t1.industry = ''
AND t2.industry IS NOT NULL;


-- LET's see as simple 
SELECT t1.industry, t2.industry
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL OR t1.industry = ''
AND t2.industry IS NOT NULL;
-- **LET's Transform this statement into UPDATE

-- BUT first we will update Blank values to set NULL values
UPDATE layoff_staging2
SET industry = null
WHERE industry = '';

UPDATE layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- LET's Check it is updated or not
SELECT t1.industry, t2.industry
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL OR t1.industry = ''
AND t2.industry IS NOT NULL;
-- FINFALY we did it 

-- AS you can see industry is now updated
SELECT *
FROM layoff_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoff_staging2
WHERE industry IS NULL
OR industry = '';

SELECT * FROM layoff_staging2;

-- SO we have last thing to do for null values
SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- * WE have to fix this 
-- We can canot add this values becoz- i dont know the total_laid_off and percentage_laid_off

-- LET's delete this values
DELETE 
FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- HERE we did this lets check

SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- YES

SELECT * FROM layoff_staging2;


-- 4. Remove Any Columns
ALTER TABLE layoff_staging2
DROP COLUMN row_num;
