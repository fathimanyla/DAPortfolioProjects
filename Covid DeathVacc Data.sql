select * 
from DAPortfolioProjects..CovidDeathData
where continent is not null
order by 3,4


--select * 
--from DAPortfolioProjects..CovidVaccinationData
--order by 3,4

--select required data

select location,date,total_cases,new_cases,total_deaths,population
from DAPortfolioProjects..CovidDeathData
order by 1,2

----total cases vs deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from DAPortfolioProjects..CovidDeathData
where location like 'india'
order by 1,2

--total cases vs population

select location,date,population,total_cases, (total_cases/population)*100 as CasesPerPopulation
from DAPortfolioProjects..CovidDeathData
where location like 'india'
order by 1,2

--Country wise cases

select location,population,Max(total_cases) as HighestCaseCountry, max((total_cases/population))*100 as HighestPerPopulation
from DAPortfolioProjects..CovidDeathData
group by location,population
order by HighestPerPopulation desc

--highest death reported

select location,max(cast(total_deaths as int)) as TotalDeath
from DAPortfolioProjects..CovidDeathData
where continent is not null
group by location
order by TotalDeath desc

--Continent wise Total Deaths

select continent,MAx(cast(total_deaths as int)) as TotalDeath
from DAPortfolioProjects..CovidDeathData
where continent is not null
group by continent
order by TotalDeath desc


-- Daily Death Percentage globally

select date,sum(new_cases) as total_case,sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPerc
from DAPortfolioProjects..CovidDeathData
where continent is not null
group by date
order by 1,2


--Let's combine Covid Death Data and Vaccination Data on date and location

SELECT CDeath.date,CDeath.location,CDeath.population,CVacc.new_vaccinations, 
sum(cast(CVacc.new_vaccinations as int)) over(partition by cdeath.location order by cdeath.location,cdeath.date)
as PeopleVaccinated
from DAPortfolioProjects..CovidDeathData as CDeath
join DAPortfolioProjects..CovidVaccinationData as CVacc
on CDeath.date=CVacc.date
and CDeath.location=CVacc.location
where Cdeath.continent is not null
order by location

--Let's Create a temperory table to calculate percentage of vaccination per population
DROP table if exists #VaccPerPopulationPerc
Create table #VaccPerPopulationPerc
(
date datetime, location nvarchar(255),population numeric,new_vaccinations numeric, PeopleVaccinated numeric

)
Insert into #VaccPerPopulationPerc

SELECT CDeath.date,CDeath.location,CDeath.population,CVacc.new_vaccinations, 
sum(cast(CVacc.new_vaccinations as int)) over(partition by cdeath.location order by cdeath.location,cdeath.date)
as PeopleVaccinated
from DAPortfolioProjects..CovidDeathData as CDeath
join DAPortfolioProjects..CovidVaccinationData as CVacc
on CDeath.date=CVacc.date
and CDeath.location=CVacc.location
where Cdeath.continent is not null 
order by location

Select * , (PeopleVaccinated/population)*100 as VaccPerPopulation
from #VaccPerPopulationPerc


--Create a view to store data

create view VaccPerPopulationPerc1 as

SELECT CDeath.date,CDeath.location,CDeath.population,CVacc.new_vaccinations, 
sum(cast(CVacc.new_vaccinations as int)) over(partition by cdeath.location order by cdeath.location,cdeath.date)
as PeopleVaccinated
from DAPortfolioProjects..CovidDeathData as CDeath
join DAPortfolioProjects..CovidVaccinationData as CVacc
on CDeath.date=CVacc.date
and CDeath.location=CVacc.location
where Cdeath.continent is not null 
--order by location


select * from VaccPerPopulationPerc1