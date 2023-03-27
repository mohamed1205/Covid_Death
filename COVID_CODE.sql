SELECT * FROM coviddeaths ;

SELECT * FROM covidvaccinations;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2;

-- Lookind at the total_cases vs total_deaths
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
where continent is not null
ORDER BY 1,2;

-- Looking at total cases vs population 
-- show what percentage of population got COVID
SELECT location, date, population,total_cases,(total_cases/population)*100 as total_cases_per_population
FROM coviddeaths
where continent is not null
ORDER BY 1,2;

-- looking at countries with highest infection rate compared to population
SELECT location, population,MAX(total_cases) AS Hightestinfection,MAX(total_cases/population)*100 as PercentHightestinfection
FROM coviddeaths
where continent is not null
GROUP BY location, population
ORDER BY PercentHightestinfection DESC;

-- SHOWING COUNTRIES WITH HGHEST DEATH COUNT PER POPULATION
SELECT location,MAX(total_deaths ) as max_total_deaths
FROM coviddeaths
where continent is not null
GROUP BY location
ORDER BY max_total_deaths DESC;

-- let's break down by continent
SELECT continent,MAX(total_deaths ) as max_total_deaths
FROM coviddeaths
where continent is not null
GROUP BY continent
ORDER BY max_total_deaths DESC;

-- global number

SELECT  SUM(new_cases),SUM(new_deaths),sum(new_deaths)/sum(new_cases)*100 AS deathpercentage
FROM coviddeaths
where continent is not null
ORDER BY deathpercentage;

-- looking at total ppulation vs vaccinations 
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location,cd.date ) AS ROLLINGPEOPLE
FROM coviddeaths AS cd
JOIN covidvaccinations as cv ON cd.location=cv.location
AND cd.date=cv.date
WHERE cd.continent is not null
order by cd.location,cd.date;

-- USE CTE

WITH popvsvac  (continent,location,date,population,new_vaccinations,ROLLINGPEOPLE)
AS
(
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location,cd.date ) AS ROLLINGPEOPLE
FROM coviddeaths AS cd
JOIN covidvaccinations as cv ON cd.location=cv.location
AND cd.date=cv.date
WHERE cd.continent is not null
)

SELECT *,(ROLLINGPEOPLE/population)*100
FROM popvsvac;

-- TEMP TABLE
DROP TABLE IF EXISTS percentpopulationvaccinated;
CREATE TABLE percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
ROLLINGPEOPLE numeric
);

INSERT INTO percentpopulationvaccinated
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location,cd.date ) AS ROLLINGPEOPLE
FROM coviddeaths AS cd
JOIN covidvaccinations as cv ON cd.location=cv.location
AND cd.date=cv.date
WHERE cd.continent is not null;

SELECT *,(ROLLINGPEOPLE/population)*100
FROM percentpopulationvaccinated;

-- CREATE view to store data for later vizulization

CREATE VIEW percentpopulationvaccinated AS
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location,cd.date ) AS ROLLINGPEOPLE
FROM coviddeaths AS cd
JOIN covidvaccinations as cv ON cd.location=cv.location
AND cd.date=cv.date
WHERE cd.continent is not null