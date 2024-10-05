-- Exploratory Data Analysis 

SELECT * FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Identify companies with 100% layoffs
SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Identify total layoffs by company
SELECT company, SUM(total_laid_off) as people_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Identify starting and ending dates of layoffs
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Calculate total layoffs by industry
SELECT industry, SUM(total_laid_off) as people_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT * FROM layoffs_staging2;

-- Calculate total layoffs by country
SELECT country, SUM(total_laid_off) as people_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Calculate total layoffs by year
SELECT YEAR(`date`), SUM(total_laid_off) as people_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Calculate layoffs by industry
SELECT stage, SUM(total_laid_off) as people_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY 1 DESC;

-- Calculate avg laid_off percentage by company
SELECT company, AVG(percentage_laid_off) as avg_percentage
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Use substring to get the layoffs by month
SELECT SUBSTRING(`date`, 1, 7) AS 'MONTH', SUM(total_laid_off) AS people_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;

-- Create rolling_total cte
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS 'MONTH', SUM(total_laid_off) AS people_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `MONTH`, people_laid_off, SUM(people_laid_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


-- Identify companies with most layoffs in DESC order
SELECT company, SUM(total_laid_off) as people_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Identify most company layoffs per year
SELECT company, YEAR(`date`), SUM(total_laid_off) as people_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Create CTE to identify total company layoffs per year
WITH company_year (company, years, people_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
), 
-- Create cte from company_year cte to partiton by year
company_year_rank AS
(
SELECT *,
DENSE_RANK() 
OVER(PARTITION BY years ORDER BY people_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)

-- identify top 5 company with most layoffs per year
SELECT * 
FROM company_year_rank
WHERE ranking <= 5;
