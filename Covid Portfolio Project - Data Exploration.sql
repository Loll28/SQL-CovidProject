/*
Covid 19 Data Exploration

Skills used: Aggregate Functions, Converting Data Types, Joins, Window Functions, CTE's, Temp Tables, Creating Views
*/


SELECT *
FROM PortfolioProject..['Covid Deaths']
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..['Covid Vaccinations']
--ORDER BY 3,4


-- Select data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['Covid Deaths']
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..['Covid Deaths']
WHERE location = 'United Kingdom'
AND continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..['Covid Deaths']
--WHERE location = 'United Kingdom'
ORDER BY 1,2


-- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectedPercent
FROM PortfolioProject..['Covid Deaths']
--WHERE location = 'United Kingdom'
GROUP BY location, population
ORDER BY PopulationInfectedPercent DESC


-- Countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..['Covid Deaths']
--WHERE Location = 'United Kingdom'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING DOWN BY CONTINENT

-- Showing Continents with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..['Covid Deaths']
--WHERE location = 'United Kingdom'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

/* --TEST--
SELECT Continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..['Covid Deaths']
--WHERE location = 'United Kingdom'
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC
*/



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..['Covid Deaths']
--WHERE location = 'United Kingdom'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows percentage of population that has received at least one Covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['Covid Deaths'] dea
JOIN PortfolioProject..['Covid Vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform calculation on PARTITION BY in previous query (Total Population vs Vaccinations)

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['Covid Deaths'] dea
JOIN PortfolioProject..['Covid Vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


-- Using TEMP TABLE to perform calculation on PARTITION BY in previous query (Total Population vs Vaccinations)

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['Covid Deaths'] dea
JOIN PortfolioProject..['Covid Vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated




-- Creating view to store data for later visualisations

USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['Covid Deaths'] dea
JOIN PortfolioProject..['Covid Vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL




/*
Notes: Could possibly create a new 'Covid Deaths' table with 'WHERE continent IS NOT NULL' to avoid having WHERE clause in each query.
*/
