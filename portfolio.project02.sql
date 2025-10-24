SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;


--THE DATA THAT I AM GOING TO WORK WITH

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;



--the total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal(10,2))/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2;

--looking at total cases vs population
--shows what percentage of population got covid

SELECT location, date, population, total_cases,  (total_cases*10.0/population)*10000000 AS CasesPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2;


--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
								MAX(total_cases*1.0/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--showing country with the highest Death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing continents with the highest Death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is  not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as decimal(8,2))) AS TotalDeaths,
		SUM(cast(new_deaths as decimal(10,2)))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.LOCATION ORDER BY
CD.LOCATION , CD.DATE) AS RollingpeopleVaccination
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
		ON CD.date = CV. date
		AND CD.location = CV.location
WHERE CD.continent IS NOT NULL
ORDER BY 2,3  



--USE CTE

WITH POPVSVAC (continent, location, date, population, new_vaccinations, RollingpeopleVaccination)
AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.LOCATION ORDER BY
CD.LOCATION , CD.DATE) AS RollingpeopleVaccination
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
		ON CD.date = CV. date
		AND CD.location = CV.location
WHERE CD.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingpeopleVaccination*1.0/population)*100
FROM POPVSVAC



--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime, 
population numeric,
new_Vaccination numeric,
RollingpeopleVaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.LOCATION ORDER BY
CD.LOCATION , CD.DATE) AS RollingpeopleVaccination
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
		ON CD.date = CV. date
		AND CD.location = CV.location
--WHERE CD.continent IS NOT NULL
--ORDER BY 2,3


SELECT *, (RollingpeopleVaccination*1.0/population)*100
FROM #PercentPopulationVaccinated





-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated
AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION BY CD.LOCATION ORDER BY
CD.LOCATION, CD.DATE) AS RollingpeopleVaccination
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.date = CV. date
	AND CD.location = CV.location
WHERE CD.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated