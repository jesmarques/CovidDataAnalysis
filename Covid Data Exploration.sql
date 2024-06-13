/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
From PortfolioProject..CovidDeaths
order by 3, 4

select *
From PortfolioProject..CovidVaccinations
order by 3, 4

--Select data that we are going to be using

SELECT 
continent,
location,
date,
total_cases,
new_cases,
total_deaths,
population
FROM PortfolioProject..CovidDeaths
WHERE NULLIF(continent, '') IS NOT NULL
ORDER BY 2,3

-- Looking at Total Cases vs Total deaths

SELECT
location,
date,
total_cases,
total_deaths,
(total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE NULLIF(continent, '') IS NOT NULL
--WHERE location like 'Brazil' and NULLIF(continent, '') IS NOT NULL
ORDER BY 1, 2

-- Loking at Total Cases vs Population
--Show what percentage of population got covid

SELECT
location,
date,
population,
total_cases,
(total_cases/population)*100 as PopulationAffectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE NULLIF(continent, '') IS NOT NULL
--WHERE location like 'Brazil' and NULLIF(continent, '') IS NOT NULL

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT
location,
population,
MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population)*100) as PopulationAffectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE NULLIF(continent, '') IS NOT NULL
--WHERE location like'%swit%' and NULLIF(continent, '') IS NOT NULL
GROUP BY location, population
ORDER BY PopulationAffectedPercentage desc

--Showing Countries with Highest Death Count

SELECT
location,
MAX(total_deaths) as TotalDeathcount
FROM PortfolioProject..CovidDeaths
WHERE NULLIF(continent, '') IS NOT NULL
GROUP BY location
ORDER BY TotalDeathcount desc

--Showing continents with the highest death count

SELECT
location,
MAX(total_deaths) as TotalDeathcount
FROM PortfolioProject..CovidDeaths
WHERE location in ('North America', 'South America', 'Asia','Europe', 'Africa', 'Oceania')
GROUP BY location
ORDER BY TotalDeathcount desc

-- Global Numbers

SELECT
SUM(new_cases) as WorldTotalCases,
SUM(new_deaths) as WorldTotalDeaths,
(SUM(new_deaths)/SUM(NULLIF(new_cases,0)))*100 as CovidDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE NULLIF(continent, '') IS NOT NULL

--Looking at Total Number of Vaccines in the world

SELECT 
Deaths.continent,
Deaths.location,
Deaths.date,
Deaths.population,
Vac.new_vaccinations,
SUM(Vac.new_vaccinations) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) as TotalNumberVaccines
FROM PortfolioProject..CovidDeaths as Deaths
JOIN PortfolioProject..CovidVaccinations as Vac on Deaths.location = Vac.location
AND Deaths.date = Vac.date
WHERE NULLIF(Deaths.continent, '') IS NOT NULL
ORDER BY 2, 3

--CTE

WITH PopulationVsVac (continent, location, date, population, new_vaccinations, TotalNumberVaccines) as 
(
SELECT 
Deaths.continent,
Deaths.location,
Deaths.date,
Deaths.population,
Vac.new_vaccinations,
SUM(Vac.new_vaccinations) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) as TotalNumberVaccines
FROM PortfolioProject..CovidDeaths as Deaths
JOIN PortfolioProject..CovidVaccinations as Vac on Deaths.location = Vac.location
AND Deaths.date = Vac.date
WHERE NULLIF(Deaths.continent, '') IS NOT NULL
)

SELECT *, (TotalNumberVaccines/population)*100 as PercentageVaccinesPerTotalPopulation --(Lembrando que uma pessoa pode ter tomado mais que uma dose)
FROM PopulationVsVac

DROP TABLE IF EXISTS #PercentageVaccinesPerTotalPopulation
CREATE TABLE #PercentageVaccinesPerTotalPopulation
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalNumberVaccines numeric
)

INSERT INTO #PercentageVaccinesPerTotalPopulation
SELECT 
Deaths.continent,
Deaths.location,
Deaths.date,
Deaths.population,
Vac.new_vaccinations,
SUM(Vac.new_vaccinations) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) as TotalNumberVaccines
FROM PortfolioProject..CovidDeaths as Deaths
JOIN PortfolioProject..CovidVaccinations as Vac on Deaths.location = Vac.location
AND Deaths.date = Vac.date

SELECT *, (TotalNumberVaccines/population)*100
FROM #PercentageVaccinesPerTotalPopulation


--Creating View to store date for later visualizations

CREATE VIEW PercentageVaccinesPerTotalPopulation as
SELECT 
Deaths.continent,
Deaths.location,
Deaths.date,
Deaths.population,
Vac.new_vaccinations,
SUM(Vac.new_vaccinations) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) as TotalNumberVaccines
FROM PortfolioProject..CovidDeaths as Deaths
JOIN PortfolioProject..CovidVaccinations as Vac on Deaths.location = Vac.location
AND Deaths.date = Vac.date
WHERE NULLIF(Deaths.continent, '') IS NOT NULL

SELECT *
FROM #PercentageVaccinesPerTotalPopulation
