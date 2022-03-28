SELECT * FROM PortfolioProject..coviddeath
WHERE continent IS NOT null
ORDER BY 3,4

SELECT * FROM PortfolioProject..covidvaccine
ORDER BY 3,4

-- Select data that will be used

-- Looking at total cases vs total deaths
 --Percentage of dying from covid in
SELECT location, date, total_cases, new_cases, total_deaths, population, 
(total_deaths/total_cases)*100 as DeathPercantage
FROM PortfolioProject..coviddeath
WHERE location LIKE '%states%'
ORDER BY 1,2



SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulation
FROM PortfolioProject..coviddeath
--WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate copared to population
SELECT location, population, MAX(total_cases) as Highest_infection_count, 
(MAX(total_cases)/population)*100 as InfectedPopulationatPeak
FROM PortfolioProject..coviddeath
Group By location, population
ORDER BY InfectedPopulationatPeak DESC

-- Countries with Highest Death Count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeath
WHERE continent IS NOT null
Group By location
ORDER BY totaldeathcount DESC

-- Showing continents with highest death count per population 
-- BROKEN DOWN BY CONTINENT 
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeath
WHERE continent IS  null AND location NOT LIKE '%income%'
Group By location
ORDER BY totaldeathcount DESC


-- GLOBAL NUMBERS 

SELECT date, SUM(new_cases) as total_cases, SUM(CAST (new_deaths as INT)), SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercantage
FROM PortfolioProject..coviddeath
WHERE continent is not null
Group by date
ORDER BY 1,2

SELECT  SUM(new_cases) as total_cases, SUM(CAST (new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercantage
FROM PortfolioProject..coviddeath
WHERE continent is not null
--Group by date
ORDER BY 1,2



-- Looking at total pop vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) as Rollingpplvacc
FROM PortfolioProject..coviddeath  dea
JOIN PortfolioProject..covidvaccine  vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--  CTE 
With PopvsVac (Continent, location, date, population,new_vaccinations,
Rollingpplvacc)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) as Rollingpplvacc
	FROM PortfolioProject..coviddeath  dea
	JOIN PortfolioProject..covidvaccine  vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(Rollingpplvacc/Population)*100 
FROM PopvsVac

-- TEMP TABLE 
--DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Loccation nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpplvacc numeric) 

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) as Rollingpplvacc
	FROM PortfolioProject..coviddeath  dea
	JOIN PortfolioProject..covidvaccine  vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *,(Rollingpplvacc/Population)*100 
FROM #PercentPopulationVaccinated

-- Data Storage for later use 

Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) as Rollingpplvacc
	FROM PortfolioProject..coviddeath  dea
	JOIN PortfolioProject..covidvaccine  vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


Select * FROM PercentPopulationVaccinated