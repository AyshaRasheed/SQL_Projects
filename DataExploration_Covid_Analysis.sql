select * from [Covid Analysis]..[CovidDeaths$];

---selecting data that we need to use

select location,date,population,total_cases,new_cases,total_deaths from [Covid Analysis]..CovidDeaths$ where continent is not null order by 1,2 ;

---looking at total cases vs total deaths( likelyhood of dying if we got covid in India)

select location, date, population, round((total_deaths/total_cases)*100,2,2) as percentage_of_death from 
[Covid Analysis]..[CovidDeaths$] where continent is not null order by 1,2;

---looking at total cases vs population (showing what percentage of population got covid)

select location, date, population, round((total_deaths/total_cases)*100,2,2) as percentage_of_death,
round((total_cases/population)*100,2,2) as percentage_ofPeople_infected from 
[Covid Analysis]..[CovidDeaths$] where continent is not null order by 1,2;

---Looking at countries with highest infection rate compared to poulation

select location, population , max(total_cases) as Highest_infected ,round(max(total_cases/population)*100,2,2) as PercentageOfPeple_Infected
from  [Covid Analysis]..[CovidDeaths$]where continent is not null group by location, population order by 4 desc;

---Looking at countries with highest death count per population

select location, max(cast(total_deaths as int) )as Highest_death 
from  [Covid Analysis]..[CovidDeaths$]where continent is not null group by location order by 2 desc;

                                      --- Exploring data by continent

---looking at continent with highest death count

select continent, max(cast(total_deaths as int) )as Highest_death 
from  [Covid Analysis]..[CovidDeaths$]where continent is not null group by continent order by 2 desc;

---Looking at continents with highest infection rate compared to poulation

select continent, max(total_cases) as Highest_infected ,round(max(total_cases/population)*100,2,2) as PercentageOfPeple_Infected
from  [Covid Analysis]..[CovidDeaths$]where continent is not null group by continent order by 3 desc;

---looking at total cases vs population in contient(showing what percentage of population got covid)

select continent, round(max(total_deaths/total_cases)*100,2,2) as percentage_of_death,
round(max(total_cases/population)*100,2,2) as percentage_ofPeople_infected from 
[Covid Analysis]..[CovidDeaths$] where continent is not null group by continent order by 3 desc ;

                                   ---Global Numbers

---Looking at total new cases and new deaths of whole world  for each day 

Select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
round(sum(cast(new_deaths as int))/sum(new_cases)*100,2,2) as death_perc from [Covid Analysis]..[CovidDeaths$] 
where continent is not null group by date order by 4 desc ;

---Looking at total population vs vaccination (by Joining 2 tables)

select * from[Covid Analysis]..[CovidVaccinations$];

select de.continent,de.location,de.date,de.population,va.new_vaccinations
from [Covid Analysis]..[CovidDeaths$] de
join [Covid Analysis]..[CovidVaccinations$] va
on de.location=va.location
and de.date=va.date
where de.continent is not null
order by 2,3 desc;

---Looking at total vaccinatiotions of each locationon on each day

select de.continent,de.location,de.date,de.population,va.new_vaccinations, 
sum(cast(va.new_vaccinations as int)) over( partition by de.location order by de.location,de.date)
from [Covid Analysis]..[CovidDeaths$] de
join[Covid Analysis]..[CovidVaccinations$] va
on de.location=va.location 
and de.date=va.date
where de.continent is not null;

---Using Cte 

with PopvsVacc (continent,location,date,population,RollingPeopleVaccinated)
as
(select de.continent,de.location,de.date,de.population,
sum(cast(new_vaccinations as int)) over ( partition by de.location order by de.location,de.date) as RollingPeopleVaccinated
from [Covid Analysis]..[CovidDeaths$] de
join[Covid Analysis]..[CovidVaccinations$] va
on de.location=va.location 
and de.date=va.date
where de.continent is not null)
select *, round((RollingPeopleVaccinated/population)*100,2,2) as VaccinePercentage from PopvsVacc ;

---Using Temp Table

Drop table if exists #PercentageVaccinated
Create table #PercentageVaccinated
( continent nvarchar(266),
location nvarchar(244),
date datetime,
population numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentageVaccinated
select de.continent,de.location,de.date,de.population,
sum(convert(int,new_vaccinations)) over ( partition by de.location order by de.location,de.date) as RollingPeopleVaccinated
from [Covid Analysis]..[CovidDeaths$] de
join[Covid Analysis]..[CovidVaccinations$] va
on de.location=va.location 
and de.date=va.date
where de.continent is not null

select *, round((RollingPeopleVaccinated/population)*100,2,2)as VaccinePercentage from #PercentageVaccinated;

---Creating View to store data for later visualiation

Create view PercentageVaccinated as
select de.continent,de.location,de.date,de.population,
sum(convert(int,new_vaccinations))over (partition by de.location order by de.location,de.date) as RollingPeopleVaccinated 
from [Covid Analysis]..[CovidDeaths$] de
join[Covid Analysis]..[CovidVaccinations$] va
on de.location=va.location 
and de.date=va.date
where de.continent is not null;

select * from PercentageVaccinated;


