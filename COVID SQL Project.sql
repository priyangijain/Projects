select * from Portfolioproject..CovidDeaths
where continent is not null
order by 3,4 

--select * from Portfolioproject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location,date,total_cases,new_cases,total_deaths,population
From Portfolioproject..CovidDeaths
where continent is not null
order by 1,2

--Look at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
where location ='India' and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths
where location='India'and continent is not null
order by 1,2


--Looking at countries with highest Infection Rate compared to Population
Select Location,population,max(total_cases)as HighestInfectionCount,max((total_cases/population)*100) as PercentPopulationInfected
From Portfolioproject..CovidDeaths
where continent is not null
Group by location,population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population
Select location,max(cast(total_deaths as int))as TotalDeathCount
From Portfolioproject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continets with the highest death count per population
Select location,max(cast(total_deaths as int))as TotalDeathCount
From Portfolioproject..CovidDeaths
Where continent is null 
Group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS
Select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
where continent is not null
Group by date
order by 1,2

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
where continent is not null
--Group by date
order by 1,2



--Looking at Total Population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated,
from  Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopsvsVac(Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from  Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopsvsVac


--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from  Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from  Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated







