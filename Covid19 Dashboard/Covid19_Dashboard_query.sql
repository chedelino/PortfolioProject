-- Covid19 Tableau Dashboard Querries
-- Data Source : https://ourworldindata.org
-- Last update : 11/27/2021

-- 1) Covid19 Total Cases, Total Deaths, Infection rate, Total vaccinated, PercentVaccinated  people in Haiti


SELECT 
      dt.Location,
      dt.population,
      Max(cast(dt.total_cases AS BIGINT)) AS TotalCases, 
      MAX(cast(dt.total_deaths AS INT)) AS TotalDeathCounts,
      Max(cast(dt.total_cases AS BIGINT)) / dt.population AS InfectionRate,
      Max(CONVERT(int, vacc.new_vaccinations)) AS TotalVaccinated,
      Max(CONVERT(int, vacc.new_vaccinations)) / dt.population AS PercentVaccinated


FROM PortfolioProject.dbo.CovidVaccinations AS vacc
JOIN PortfolioProject.dbo.CovidDeaths AS dt
ON vacc.location = dt.location
WHERE dt.location like '%Haiti%'
GROUP BY dt.location , dt.population


-- 2) Covid19 daily trends of new_cases in haiti

SELECT 
     date,
     location,
     sum(cast(new_cases as int)) AS TotalCases

FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Haiti%'
Group by location, date



-- 3) Covid19 Total deaths count by country in North America

SELECT
      location, sum(cast(new_deaths as int)) AS TotalDeathCounts
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not NULL
AND continent Like '%North America%'
Group by location



--4) Covid19 Total_Cases and Infection_Rate by country in North America

SELECT
      dt.location,
      dt.population,  
      MAX(dt.total_cases) AS TotalCases, 
      Max((dt.total_cases)/dt.population) * 100 AS PercentPopulationInfected,
      MAX(cast(dt.total_deaths AS INT)) AS TotalDeathCounts,
      Max(cast(dt.total_cases AS BIGINT)) / dt.population AS InfectionRate,
      Max(CONVERT(int, vacc.new_vaccinations)) AS TotalVaccinated,
      Max(CONVERT(int, vacc.new_vaccinations)) / dt.population AS PercentVaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS vacc
JOIN PortfolioProject.dbo.CovidDeaths AS dt
ON vacc.location = dt.location
AND vacc.date = dt.date
WHERE dt.continent = 'North America'
Group by dt.location, dt.population



SELECT
      date, location,population,  MAX(total_cases) AS TotalCases, Max((total_cases)/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not NULL
AND continent Like '%North America%'
Group by location, population, date


--5) Use CTE to determine the percentage of vaccinated people 

WITH HAIVACC (location, date, new_vaccinations, Population, TotalVaccinated )
AS 
( SELECT 
deat.location, deat.date, vacc.new_vaccinations, deat.population, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) AS TotalVaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS vacc
JOIN PortfolioProject.dbo.CovidDeaths AS deat
ON vacc.location = deat.location
AND vacc.date = deat.date
WHERE deat.continent = 'North America'
)

SELECT *, (Totalvaccinated / Population) AS PercentVaccinatedPeople
FROM HAIVACC