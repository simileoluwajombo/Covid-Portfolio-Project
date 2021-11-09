SELECt LOCATION, date, total_cases, new_cases, total_deaths, population
from `Covid deaths`
order by 1,2 ;

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECt LOCATION, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from `Covid deaths`
WHERE LOCATION like '%Nigeria%'
order by 1,2 ;

-- Looking at the total cases vs the population
-- shows what percentage of population got covid
SELECt LOCATION, date, population, total_cases, (total_cases/population)*100 as infection_Percentage
from `Covid deaths`
WHERE LOCATION like '%Nigeria%'
order by 1,2 ;


-- Looking at countries with highest infection rates compared to population
SELECt LOCATION, population, max(total_cases) as Highest_Infection_Count, max(total_cases/population)*100 as infection_Percentage
from `Covid deaths`
GROUP by LOCATION, population
order by infection_Percentage desc ;

-- Looking at countries with highest death count compared to population
SELECt LOCATION, max(total_deaths) as Total_death_count
-- , max(total_deaths/population)*100 as death_Percentage
from `Covid deaths`
WHERE continent != ''
GROUP by LOCATION
order by Total_death_count desc ;

-- let's break things down by continent
-- Showing continent with the highest death count
SELECt continent, max(total_deaths) as Total_death_count, max(total_deaths/population)*100 as death_Percentage
from `Covid deaths`
WHERE continent != ''
GROUP by continent
order by Total_death_count desc ;


-- Global numbers
-- Death percentage by date
SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases)*100) as GlobalDeathPercentage
from `Covid deaths`
WHERE continent != ''
GROUP by date 
order by 1,2 ;


-- Global death percentage
SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases)*100) as GlobalDeathPercentage
from `Covid deaths`
WHERE continent != ''
order by 1,2 ;



-- Working with covd vaccination
SELECT * 
from `Covid vaccinations` cv
join `Covid deaths` cd 
on cv.`location` = cd.`location`
and cv.`date` = cd.`date`;

-- Looking at total population vs vaccination
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cv.new_vaccinations) over (partition by cd.`location` order by cd.`location`, cd.`date`) as RollingPeopleVaccinated,
from `Covid deaths` cd
join `Covid vaccinations` cv 
on cv.`location` = cd.`location`
and cv.`date` = cd.`date`
WHERE cd.continent != ''
and cd.`date` >= '2021-09-01';


-- Using a CTE
With PopulationVsVaccination (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cv.new_vaccinations) over (partition by cd.`location` order by cd.`location`, cd.`date`) as RollingPeopleVaccinated
from `Covid deaths` cd
join `Covid vaccinations` cv 
on cv.`location` = cd.`location`
and cv.`date` = cd.`date`
WHERE cd.continent != ''
and cd.`date` >= '2021-09-01'
)
SELECT *, (RollingPeopleVaccinated/population)*100 
From PopulationVsVaccination
;


-- temp table
Drop Table if exists PercentPopulationVaccinated ;


Create TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date datetime,
Population VARCHAR(255),
new_vaccinations VARCHAR(255),
RollingPeopleVaccinated VARCHAR(255) 
);

insert into PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, (cv.new_vaccinations), 
sum((cv.new_vaccinations)) over (partition by cd.`location` order by cd.`location`, cd.`date`) as RollingPeopleVaccinated
from `Covid deaths` cd
join `Covid vaccinations` cv 
on cv.`location` = cd.`location`
and cv.`date` = cd.`date`
WHERE cd.continent != '';


SELECT *, (RollingPeopleVaccinated/population)*100 
From PercentPopulationVaccinated;

-- Create view
Create view Percent_PeopleVaccinated as 
select cd.continent, cd.location, cd.date, cd.population, (cv.new_vaccinations), 
sum((cv.new_vaccinations)) over (partition by cd.`location` order by cd.`location`, cd.`date`) as RollingPeopleVaccinated
from `Covid deaths` cd
join `Covid vaccinations` cv 
on cv.`location` = cd.`location`
and cv.`date` = cd.`date`
WHERE cd.continent != '';

-----------------------------------------------



