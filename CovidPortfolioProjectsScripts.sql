-- Selecting all data
SELECT *
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 3,4


-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%portugal%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%portugal%'
ORDER BY 1,2

-- Looking at Countries with highest infection rate compared to populataion
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%portugal%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%portugal%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- Let's break things down by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%portugal%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC

-- Showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%portugal%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC

-- Global numbers
--Per day
SELECT date, sum(total_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total
SELECT sum(total_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


-- Looking at total Population vs Vaccinations
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating Views to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

