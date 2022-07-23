select * 
from PortfolioProject..['covid deaths$']
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..['covid vaccination]
--order by 3,4

--select data that we are going to use

select Location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject..['covid deaths$']
where continent is not null
order by 1,2

--looking at total cases vs total death

select Location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percent
from PortfolioProject..['covid deaths$']
where Location like '%states%'
and continent is not null
order by 1,2

--looking at total cases vs population

select Location, date,population,total_cases,(total_cases/population)*100 as infected_percent
from PortfolioProject..['covid deaths$']
--where Location like '%states%'
where continent is not null
order by 1,2

-- looking at countries with highet infection rate compared to population

select Location,population, Max(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 as infected_percent
from PortfolioProject..['covid deaths$']
--where Location like '%states%'
where continent is not null
group by Location, population
order by infected_percent desc

--showing countries with highest death count per population

select Location, Max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..['covid deaths$']
--where Location like '%states%'
where continent is not null
group by Location
order by HighestDeathCount desc

-- let's break things down by continent

select continent, Max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..['covid deaths$']
--where Location like '%states%'
where continent is not null
group by continent
order by HighestDeathCount desc

-- showing continents with highest death count per population

select continent, Max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..['covid deaths$']
--where Location like '%states%'
where continent is not null
group by continent
order by HighestDeathCount desc

--Global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_percent
from PortfolioProject..['covid deaths$']
--where Location like '%states%'
where continent is not null
order by 1,2

-- looking at total population vs totalvaccinations

select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dth.location order by dth.location,dth.date) as RollingPeoplevaccinated
from PortfolioProject..['covid deaths$']  dth
join PortfolioProject..['covid vaccination]  vac
    on dth.location=vac.location
	and dth.date=vac.date
where dth.continent is not null
order by 2,3

--Etl

with popvsvac (continent,location,date,population,new_vaccinations,RollingPeoplevaccinated)
as(
select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dth.location order by dth.location,dth.date) as RollingPeoplevaccinated
from PortfolioProject..['covid deaths$']  dth
join PortfolioProject..['covid vaccination]  vac
    on dth.location=vac.location
	and dth.date=vac.date
where dth.continent is not null
--order by 2,3
)
select * ,(RollingPeoplevaccinated/population)*100
from popvsvac






--temp table
drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
Continent char(255) ,
Location char(255) ,
Date datetime ,
Population numeric ,
New_Vaccinations numeric ,
RollingPeopleVaccinated numeric
)


insert into #PercentPeopleVaccinated
select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dth.location order by dth.location,dth.date) as RollingPeoplevaccinated
from PortfolioProject..['covid deaths$']  dth
join PortfolioProject..['covid vaccination]  vac
    on dth.location=vac.location
	and dth.date=vac.date
where dth.continent is not null
--order by 2,3

select * ,(RollingPeoplevaccinated/population)*100
from #PercentPeopleVaccinated


-- creating view to store data for later visualization

create view PercentofPeopleVaccinated as
select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dth.location order by dth.location,dth.date) as RollingPeoplevaccinated
from PortfolioProject..['covid deaths$']  dth
join PortfolioProject..['covid vaccination]  vac
    on dth.location=vac.location
	and dth.date=vac.date
where dth.continent is not null
--order by 2,3