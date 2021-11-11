SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `Covid deaths`
ORDER BY 1,2 ;

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM `Covid deaths`
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2 ;

-- Looking at the total cases vs the population
-- shows what percentage of population got covid
SELECT LOCATION, date, population, total_cases, (total_cases/population)*100 as infection_Percentage
FROM `Covid deaths`
WHERE LOCATION LIKE '%Nigeria%'
ORDER BY 1,2 ;


-- Looking at countries with highest infection rates compared to population
SELECT LOCATION, population, max(total_cases) as Highest_Infection_Count, max(total_cases/population)*100 as infection_Percentage
FROM `Covid deaths`
GROUP BY LOCATION, population
ORDER BY infection_Percentage DESC ;

-- Looking at countries with highest death count compared to population
SELECT LOCATION, max(total_deaths) AS Total_death_count
-- , max(total_deaths/population)*100 as death_Percentage
FROM `Covid deaths`
WHERE continent != ''
GROUP BY LOCATION
ORDER BYTotal_death_count DESC ;

-- let's break things down by continent
-- Showing continent with the highest death count
SELECT Continent, MAX(total_deaths) as Total_death_count, MAX(total_deaths/population)*100 as Death_Percentage
FROM`Covid deaths`
WHERE continent != ''
GROUP BY continent
ORDER BY Total_death_count DESC ;


-- Global numbers
-- Death percentage by date
SELECT Date, SUM(new_cases) as Total_Cases, SUM(new_deaths) AS Total_Deaths, (SUM(new_deaths)/SUM(new_cases)*100) AS GlobalDeathPercentage
FROM`Covid deaths`
WHERE continent != ''
GROUP BY date 
ORDER BY 1,2 ;


-- Global death percentage
SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) as Total_Deaths, (SUM(new_deaths)/SUM(new_cases)*100) as GlobalDeathPercentage
FROM `Covid deaths`
WHERE continent != ''
ORDER BY 1,2 ;



-- Working with covd vaccination
SELECT * 
FROM `Covid vaccinations` cv
JOIN `Covid deaths` cd 
ON cv.`location` = cd.`location`
AND cv.`date` = cd.`date`;

-- Looking at total population vs vaccination
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (partition BY cd.`location` ORDER BY cd.`location`, cd.`date`) AS RollingPeopleVaccinated,
FROM `Covid deaths` cd
JOIN `Covid vaccinations` cv 
ON cv.`location` = cd.`location`
AND cv.`date` = cd.`date`
WHERE cd.continent != ''
AND cd.`date` >= '2021-09-01';


-- Using a CTE
With PopulationVsVaccination (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) over (partition by cd.`location` order by cd.`location`, cd.`date`) as RollingPeopleVaccinated
FROM `Covid deaths` cd
JOIN `Covid vaccinations` cv 
ON cv.`location` = cd.`location`
AND cv.`date` = cd.`date`
WHERE cd.continent != ''
AND cd.`date` >= '2021-09-01'
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopulationVsVaccination
;


-- temp table
DROP TABLE IF EXISTS PercentPopulationVaccinated 
CREATE TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date datetime,
Population VARCHAR(255),
new_vaccinations VARCHAR(255),
RollingPeopleVaccinated VARCHAR(255) 
);

INSERT INTO PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, (cv.new_vaccinations), 
SUM((cv.new_vaccinations)) OVER (partition BY cd.`location` ORDER BY cd.`location`, cd.`date`) AS RollingPeopleVaccinated
FROM `Covid deaths` cd
JOIN `Covid vaccinations` cv 
ON cv.`location` = cd.`location`
AND cv.`date` = cd.`date`
WHERE cd.continent != '';


SELECT *, (RollingPeopleVaccinated/population) * 100 
FROM PercentPopulationVaccinated;

-- Create view
CREATE view Percent_PeopleVaccinated AS 
SELECT cd.continent, cd.location, cd.date, cd.population, (cv.new_vaccinations), 
SUM((cv.new_vaccinations)) OVER (partition BY cd.`location` ORDER BY cd.`location`, cd.`date`) AS RollingPeopleVaccinated
FROM `Covid deaths` cd
JOIN `Covid vaccinations` cv 
ON cv.`location` = cd.`location`
AND cv.`date` = cd.`date`
WHERE cd.continent != '';

-----------------------------------------------



