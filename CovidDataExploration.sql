#To select and view the entire table
SELECT `coviddeaths`.`iso_code`,
    `coviddeaths`.`continent`,
    `coviddeaths`.`location`,
    `coviddeaths`.`date`,
    `coviddeaths`.`total_cases`,
    `coviddeaths`.`new_cases`,
    `coviddeaths`.`new_cases_smoothed`,
    `coviddeaths`.`total_deaths`,
    `coviddeaths`.`new_deaths`,
    `coviddeaths`.`new_deaths_smoothed`,
    `coviddeaths`.`total_cases_per_million`,
    `coviddeaths`.`new_cases_per_million`,
    `coviddeaths`.`new_cases_smoothed_per_million`,
    `coviddeaths`.`total_deaths_per_million`,
    `coviddeaths`.`new_deaths_per_million`,
    `coviddeaths`.`new_deaths_smoothed_per_million`,
    `coviddeaths`.`reproduction_rate`,
    `coviddeaths`.`icu_patients`,
    `coviddeaths`.`icu_patients_per_million`,
    `coviddeaths`.`hosp_patients`,
    `coviddeaths`.`hosp_patients_per_million`,
    `coviddeaths`.`weekly_icu_admissions`,
    `coviddeaths`.`weekly_icu_admissions_per_million`,
    `coviddeaths`.`weekly_hosp_admissions`,
    `coviddeaths`.`weekly_hosp_admissions_per_million`,
    `coviddeaths`.`new_tests`,
    `coviddeaths`.`total_tests`,
    `coviddeaths`.`total_tests_per_thousand`,
    `coviddeaths`.`new_tests_per_thousand`,
    `coviddeaths`.`new_tests_smoothed`,
    `coviddeaths`.`new_tests_smoothed_per_thousand`,
    `coviddeaths`.`positive_rate`,
    `coviddeaths`.`tests_per_case`,
    `coviddeaths`.`tests_units`,
    `coviddeaths`.`total_vaccinations`,
    `coviddeaths`.`people_vaccinated`,
    `coviddeaths`.`people_fully_vaccinated`,
    `coviddeaths`.`new_vaccinations`,
    `coviddeaths`.`new_vaccinations_smoothed`,
    `coviddeaths`.`total_vaccinations_per_hundred`,
    `coviddeaths`.`people_vaccinated_per_hundred`,
    `coviddeaths`.`people_fully_vaccinated_per_hundred`,
    `coviddeaths`.`new_vaccinations_smoothed_per_million`,
    `coviddeaths`.`stringency_index`,
    `coviddeaths`.`population`,
    `coviddeaths`.`population_density`,
    `coviddeaths`.`median_age`,
    `coviddeaths`.`aged_65_older`,
    `coviddeaths`.`aged_70_older`,
    `coviddeaths`.`gdp_per_capita`,
    `coviddeaths`.`extreme_poverty`,
    `coviddeaths`.`cardiovasc_death_rate`,
    `coviddeaths`.`diabetes_prevalence`,
    `coviddeaths`.`female_smokers`,
    `coviddeaths`.`male_smokers`,
    `coviddeaths`.`handwashing_facilities`,
    `coviddeaths`.`hospital_beds_per_thousand`,
    `coviddeaths`.`life_expectancy`,
    `coviddeaths`.`human_development_index`
FROM `Covid data exploration`.`coviddeaths`
WHERE continent IS NOT NULL
ORDER BY 3,4;


#To select initial data
SELECT location, date, total_cases,new_cases,total_deaths,population
FROM `Covid data exploration`.`coviddeaths`
WHERE continent IS NOT NULL
ORDER BY 1,2;

#Total cases vs Total Deaths
## To show the likelihood of dying if a person is contracted with COVID in the United States
SELECT location, date, total_cases,total_deaths, (total_deaths / total_cases) *100 as DeathPercentage
FROM `Covid data exploration`.`coviddeaths`
WHERE continent IS NOT NULL
ORDER BY 1,2;

#Total cases vs Population
##To show the percentage of population that was infected with COVID
SELECT location, date, total_cases,population, (total_cases / population) *100 as PercentPopulationInfected
FROM `Covid data exploration`.`coviddeaths`
WHERE continent IS NOT NULL
ORDER BY 1,2;

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

#Countries with Highest Infection Rate compared to Population
SELECT location, date, MAX(total_cases) AS HighestInfectionCount,population, MAX((total_cases / population)) *100 as PercentPopulationInfected
FROM `Covid data exploration`.`coviddeaths`
WHERE continent IS NOT NULL
GROUP by location, population
ORDER BY PercentPopulationInfected desc;

#Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `Covid data exploration`.`coviddeaths`
WHERE Continent IS NOT NULL
GROUP by location
ORDER BY TotalDeathCount desc;

#BREAK DOWN BY CONTINENT
#Continents with highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM `Covid data exploration`.`coviddeaths`
WHERE Continent IS NOT NULL
GROUP by continent
ORDER BY TotalDeathCount desc;

#GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `Covid data exploration`.`coviddeaths`
WHERE continent IS NOT NULL
#GROUP BY date
ORDER BY 1,2;

#Covid vaccination dataset
SELECT *
FROM `Covid data exploration`.`covidvaccinations`;

#Join tables
SELECT * 
FROM `Covid data exploration`.`coviddeaths` AS dea 
JOIN `Covid data exploration`.`covidvaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date;

#Total population vs Population
##1- To show the percentage of population that has received atleast one dose of covid vaccine
SELECT dea.continent, dea.location, dea.date,dea.population,
vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM `Covid data exploration`.`coviddeaths` AS dea 
JOIN `Covid data exploration`.`covidvaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

##2- Using CTE to show the percentage of population that has received atleast one dose of covid vaccine
With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population,
vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM `Covid data exploration`.`coviddeaths` AS dea 
JOIN `Covid data exploration`.`covidvaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
From PopvsVac;

SET SESSION sql_mode = '';
###- Using Temp table to show the percentage of population that has received atleast one dose of covid vaccine
DROP TABLE IF EXISTS `Covid data exploration`.`PercentPopulationVaccinated`;
CREATE TABLE `Covid data exploration`.`PercentPopulationVaccinated`
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);
INSERT INTO `Covid data exploration`.`PercentPopulationVaccinated`
SELECT dea.continent, dea.location, dea.date,dea.population,
vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM `Covid data exploration`.`coviddeaths` AS dea 
JOIN `Covid data exploration`.`covidvaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT *,(RollingPeopleVaccinated/Population)*100
From `Covid data exploration`.`PercentPopulationVaccinated`;


#Creating View for later visualizations
DROP TABLE IF EXISTS `Covid data exploration`.`PercentPopulationVaccinated`;
CREATE VIEW `Covid data exploration`.`PercentPopulationVaccinated` AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM `Covid data exploration`.`coviddeaths` AS dea 
JOIN `Covid data exploration`.`covidvaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
From `Covid data exploration`.`PercentPopulationVaccinated`;

