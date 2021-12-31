-- Covid19 Data Exploration in SQL

-- Source : https://ourworldindata.org
-- Last update : 11/27/2021

-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


-- Quick inspection of the entire Dataset

SELECT*
FROM PortfolioProject..CovidDeaths AS dt
JOIN PortfolioProject..CovidVaccinations AS vac
ON dt.iso_code = vac.iso_code
WHERE dt.continent IS NOT NULL
ORDER BY dt.date, dt.continent, dt.location


-- Covid19 Total Cases Percentage in Haiti

SELECT 
location, Max(cast(total_cases AS BIGINT)) AS TotalCases
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Haiti'
Group BY location



-- Computation of the Total Death Count in Haiti

SELECT 
Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCounts
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Haiti%'
GROUP BY location



-- Covid19 Death Percentage in Haiti

SELECT 
location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Haiti%'
ORDER BY location, date 



-- Covid19 Lastest Infection rate in Haiti
SELECT 
location, date, population,  total_cases, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Haiti'
ORDER BY location, date DESC



-- The highest Infection rate in Haiti
SELECT 
location, population,  Max(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS Highest_Infection_Rate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Haiti'
GROUP BY location , population
ORDER BY Highest_Infection_Rate DESC


-- Rolling count of Total vaccinated people in Haiti
SELECT 
deat.location, deat.date, vacc.new_vaccinations, deat.population, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) AS TotalVaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS vacc
JOIN PortfolioProject.dbo.CovidDeaths AS deat
ON vacc.location = deat.location
AND vacc.date = deat.date
WHERE deat.location = 'Haiti'
ORDER BY TotalVaccinated ASC


-- Use CTE to determine the percentage of vaccinated people in Haiti

WITH HAIVACC (location, date, new_vaccinations, Population, TotalVaccinated )
AS 
( SELECT 
deat.location, deat.date, vacc.new_vaccinations, deat.population, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) AS TotalVaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS vacc
JOIN PortfolioProject.dbo.CovidDeaths AS deat
ON vacc.location = deat.location
AND vacc.date = deat.date
WHERE deat.location = 'Haiti'
)

SELECT *,(Totalvaccinated / Population) * 100 AS PercentVaccinatedPeople
FROM HAIVACC


--  Rolling count of Total Vaccinations per Total Cases

WITH HAICASES(location, continent, date, new_cases, Population, new_vaccinations, TotalCases, TotalVaccinations)
AS(
SELECT
deat.location, deat.continent, deat.date, deat.new_cases, deat.population, vacc.new_vaccinations, SUM(CAST(deat.new_cases AS INT)) OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) AS TotalCases,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) AS TotalVaccinations
FROM PortfolioProject.dbo.CovidVaccinations AS vacc
JOIN PortfolioProject.dbo.CovidDeaths AS deat
ON vacc.location = deat.location
AND vacc.date = deat.date
WHERE deat.location = 'Haiti')

SELECT*, (TotalVaccinations/TotalCases) AS VaccinationPerCases
From HAICASES



-- Create Temp Table to store the rolling percentage of vaccinated people in Haiti

DROP TABLE if exists #HaitiPercentVaccinated;
CREATE TABLE #HaitiPercentVaccinated
(
Continent nvarchar(100),
Location nvarchar(100),
Population numeric,
Date datetime,
New_vaccinations numeric,
TotalVaccinated numeric);


INSERT INTO #HaitiPercentVaccinated
SELECT 
	deat.continent,
	deat.location,
	deat.population,
	deat.date,
	vacc.new_vaccinations,
	SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) AS TotalVaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS vacc
JOIN PortfolioProject.dbo.CovidDeaths AS deat
ON vacc.location = deat.location
AND vacc.date = deat.date
WHERE deat.location  LIKE '%Haiti%'

SELECT *, (TotalVaccinated/Population)*100 as RollingVacPercentage
FROM #HaitiPercentVaccinated



-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated AS
SELECT 
	deat.continent,
	deat.location,
	deat.population,
	deat.date,
	vacc.new_vaccinations,
	SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) AS TotalVaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS vacc
JOIN PortfolioProject.dbo.CovidDeaths AS deat
ON vacc.location = deat.location
AND vacc.date = deat.date
WHERE deat.location  LIKE '%Haiti%'


SELECT *
FROM PercentPopulationVaccinated


