-- Selects All the Data from 9 Selected Countries and the World

SELECT *
FROM dbo.CovidDeaths
ORDER BY 3, 4;

SELECT *
FROM dbo.CovidVaccinations
WHERE location = 'Philippines'
ORDER BY 3, 4;


-- Select data that we are going to be using

SELECT Location, date, total_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1, 2;


-- Total Cases in 9 Selected Countries and the World

SELECT location, MAX(total_cases) AS TotalCases
FROM dbo.CovidDeaths
GROUP BY location
ORDER BY TotalCases DESC;

-- Total Deaths in 9 Selected Countries and the World

SELECT
	location
  , MAX(CONVERT(float, total_deaths)) AS TotalDeaths
FROM dbo.CovidDeaths
GROUP BY location
ORDER BY TotalDeaths DESC;


-- Looking at Total Cases vs Total Deaths Over Time
-- Shows the percentage of dying to COVID by countries

SELECT
	location
  , date
  , total_cases
  , total_deaths
  , (CONVERT(float, total_deaths)/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
--WHERE location = 'Philippines'
ORDER BY 1, 2;


-- Looking at Total Cases vs Population Over Time
-- Shows the percentage of population that got COVID

SELECT
	location
  , date, population
  , total_cases, (total_cases/population)*100 AS ContactPercentage
FROM dbo.CovidDeaths
--WHERE location = 'Philippines'
ORDER BY 1, 2;


-- Looking at Highest Infection Rate of each Selected Countries Compared to Population

SELECT
	location
  , population
  , MAX(total_cases) AS HighestInfectionCount
  , MAX((total_cases/population))*100 AS ContactPercentage
FROM dbo.CovidDeaths
--WHERE location = 'Philippines'
GROUP BY
	location
  , population
ORDER BY ContactPercentage DESC;


-- Total Cases vs Total Population per year
-- Shows the Percentage of People Infected per Year

SELECT
	location
  , YEAR(date) AS year
  , MAX(total_cases) AS total_cases
  , MAX(population) AS population
  , (MAX(total_cases)/MAX(population))*100 AS ContactPercentage
FROM dbo.CovidDeaths
--WHERE location = 'Philippines'
GROUP BY
	location
  , YEAR(date)
ORDER BY ContactPercentage DESC;


-- Showing Countries with Highest Death Count per Population

SELECT
	location
  , population
  , MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY
	location
  , population
ORDER BY TotalDeathCount DESC;


-- Showing the Total Percentage of Deaths

SELECT
	location
  , MAX(CONVERT(float, total_deaths)) AS TotalDeathCount
  , MAX(population) AS TotalPopulation
  , (MAX(CONVERT(float, total_deaths))/MAX(population))*100 AS TotalDeathPercentage
FROM dbo.CovidDeaths
GROUP BY location
ORDER BY TotalDeathPercentage DESC;


-- Total Number of Cases and Death for the 9 Selected Countries Over Time

SELECT
	date
  , MAX(total_cases) AS TotalCases
  , MAX(CONVERT(float, total_deaths)) AS TotalDeaths
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


-- Total Number of Cases,Death, and Death Rate for the 9 Selected Countries per Day

SELECT
	date
  , SUM(CONVERT(float, new_deaths)) AS DeathsPerDay
  , SUM(new_cases) AS CasesPerDay
  , (SUM(CONVERT(float, new_deaths))/SUM(new_cases))*100 AS DeathRatePerDay
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


-- Looking at Vaccinations Over Time

SELECT
	d.location
  , d.date
  , d.population
  , v.new_vaccinations
FROM dbo.CovidDeaths d
JOIN dbo.CovidVaccinations v
	ON d.location = v.location
   AND d.date = v.date
--WHERE d.location = 'Philippines'
ORDER BY 1, 2;


-- Looking at Total Percentage of Vaccinated Per Country

WITH vacci AS
(
SELECT
	d.location
  , MAX(d.population) AS population
  , MAX(CONVERT(float, v.people_vaccinated)) AS people_vaccinated
FROM dbo.CovidDeaths d
JOIN dbo.CovidVaccinations v
	ON d.location = v.location
   AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY d.location
)
SELECT
	  location
	, population
	, people_vaccinated
	, (people_vaccinated/population) * 100 AS VaccinationRate
FROM vacci
ORDER BY location;

-- Running Total Percentage of People Vaccinated

WITH PopVSVac
AS 
(
SELECT
	  d.continent
	, d.location
	, d.date
	, d.population
	, v.new_vaccinations
	, SUM(CONVERT(float, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.date) AS RunningTotalVaccinated
FROM dbo.CovidDeaths d
JOIN dbo.CovidVaccinations v
	ON d.location = v.location
   AND d.date = v.date
WHERE 
		1=1	
	AND d.continent IS NOT NULL
	AND d.location = 'Philippines'
)
SELECT 
	*
	, (RunningTotalVaccinated/population) * 100 AS RunningTotalPercentage
FROM PopVSVac
ORDER BY 2, 3;


-- Running Total Percentage of People Who Have Died

WITH PercentPopulationDeath
AS 
(
SELECT
	  d.continent
	, d.location
	, d.date
	, d.population
	, d.new_deaths
	, SUM(CONVERT(float, d.new_deaths)) OVER (PARTITION BY d.location ORDER BY d.date) AS RunningTotalDeath
FROM dbo.CovidDeaths d
JOIN dbo.CovidVaccinations v
	ON d.location = v.location
   AND d.date = v.date
WHERE 
		1=1	
	AND d.continent IS NOT NULL
	AND d.location = 'Philippines'
)
SELECT 
	*
	, (RunningTotalDeath/population) * 100 AS RunningTotalPercentage
FROM CTE
ORDER BY 2, 3;


-- Views to be Used Later

CREATE VIEW PercentPopulationDeath AS
SELECT
	  d.continent
	, d.location
	, d.date
	, d.population
	, d.new_deaths
	, SUM(CONVERT(float, d.new_deaths)) OVER (PARTITION BY d.location ORDER BY d.date) AS RunningTotalDeath
FROM dbo.CovidDeaths d
JOIN dbo.CovidVaccinations v
	ON d.location = v.location
   AND d.date = v.date
WHERE 
		1=1	
	AND d.continent IS NOT NULL
	AND d.location = 'Philippines'

CREATE VIEW DeathPercentage AS
SELECT
	location
  , MAX(CONVERT(float, total_deaths)) AS TotalDeathCount
  , MAX(population) AS TotalPopulation
  , (MAX(CONVERT(float, total_deaths))/MAX(population))*100 AS TotalDeathPercentage
FROM dbo.CovidDeaths
GROUP BY location

CREATE VIEW CasesVSDeath AS
SELECT
	date
  , MAX(total_cases) AS TotalCases
  , MAX(CONVERT(float, total_deaths)) AS TotalDeaths
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date

CREATE VIEW DeathPercentWorld AS
SELECT
    date,
    SUM(CONVERT(float, new_deaths)) AS DeathsPerDay,
    SUM(new_cases) AS CasesPerDay,
    NULLIF(SUM(CONVERT(float, new_deaths)) / NULLIF(SUM(new_cases), 0), 0) * 100 AS DeathRatePerDay
FROM 
    dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY 
    date