SELECT *
FROM dbo.[CovidDeaths]
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM dbo.[CovidVaccinations]
--ORDER BY 3,4

-- Select Data that we are using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows the percentage likelihood of dying if contracting COVID in the United States from 1/22/2020 - 3/3/2023
SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathRatePercentage
FROM dbo.[CovidDeaths]
WHERE location LIKE '%states%' 
and continent is not null
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of the United States population has been infected by COVID from 1/22/2020 - 3/3/2023
SELECT Location, date, Population, total_cases,(Total_cases/population)*100 AS PercentPopulationInfected
FROM dbo.[CovidDeaths]
WHERE location LIKE '%states%' 
ORDER BY 1,2


-- Shows countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestContractionCount, MAX((Total_cases/population))*100 AS PercentPopulationInfected
FROM dbo.[CovidDeaths]
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Shows Countries with highest death count per Population
SELECT Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM dbo.[CovidDeaths]
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Shows continents with the highest death count per population
SELECT continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM dbo.[CovidDeaths]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers by date
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.[CovidDeaths]
WHERE continent is not null
GROUP BY date
order by 1,2

-- Global Numbers 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.[CovidDeaths]
WHERE continent is not null
order by 1,2

-- Use CTE then -- Showing Total Population vs Vaccinations
WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPopulationVaccinated)
as 
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(cast(vacs.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPopulationVaccinated
--,(RollingPopulationVaccinated/population)*100
FROM dbo.[CovidDeaths] AS Deaths
JOIN dbo.[CovidVaccinations] AS Vacs
ON deaths.location = vacs.location
AND deaths.date = vacs.date
WHERE deaths.continent is not null
)
SELECT *, (RollingPopulationVaccinated/Population)*100
FROM PopVsVac

-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPopulationVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(cast(vacs.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPopulationVaccinated
--,(RollingPopulationVaccinated/population)*100
FROM dbo.[CovidDeaths] AS Deaths
JOIN dbo.[CovidVaccinations] AS Vacs
ON deaths.location = vacs.location
AND deaths.date = vacs.date
WHERE deaths.continent is not null
)

SELECT *, (RollingPopulationVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for future visualizations

CREATE View PercentPopulationVaccinated as 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(cast(vacs.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPopulationVaccinated
FROM dbo.[CovidDeaths] AS Deaths
JOIN dbo.[CovidVaccinations] AS Vacs
ON deaths.location = vacs.location
AND deaths.date = vacs.date
WHERE deaths.continent is not null

SELECT * 
FROM PercentPopulationVaccinated
