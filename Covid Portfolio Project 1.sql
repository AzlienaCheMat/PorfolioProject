

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be uisng

Select Location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Malaysia%'
and continent is not null
order by 1,2


-- looking at the Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases,(total_cases/Population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
Where continent is not null
order by 1,2


--looking at Countries with Highest Infection Rate compared to population

Select Location, population, MAX (total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


-- Showing COuntries with Highest Death COunt per Population

Select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with the Highest death count per population

Select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast( new_deaths as bigint)) as total_death, SUM(new_cases)/ SUM(cast( new_deaths as bigint))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Malaysia%'
WHere continent is not null
--Group By date
order by 1,2



-- Looking at Total Population vs Vaccinations
-- nak tambah setiap new_ vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUm(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHere dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (Continent, location, Date, population,New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, 
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
FRom PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, 
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Createing View to store data for later Visualization


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated




