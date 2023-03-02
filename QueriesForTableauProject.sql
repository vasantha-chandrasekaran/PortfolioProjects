#Queries for Tableau Project
#TABLE 1
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_Cases)*100 as DeathPercentage
FROM `Covid data exploration`.`coviddeaths`
WHERE continent IS NOT NULL
#GROUP BY date
ORDER BY 1,2;

#TABLE 2
SELECT location, SUM(new_deaths) as TotalDeathCount
FROM `Covid data exploration`.`coviddeaths`
WHERE continent IS NOT NULL AND location NOT IN ('World','International')
GROUP BY location
ORDER BY TotalDeathCount desc;

#TABLE 3
SELECT location, population, MAX(total_cases)as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `Covid data exploration`.`coviddeaths`
GROUP BY location,population
ORDER BY PercentPopulationInfected desc;

#TABLE 4
SELECT location, population, date, MAX(total_cases)as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `Covid data exploration`.`coviddeaths`
GROUP BY location,population,date
ORDER BY PercentPopulationInfected desc;