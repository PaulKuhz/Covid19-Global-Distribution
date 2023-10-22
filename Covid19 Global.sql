/*

Queries used for Tableau Project

*/


-- 1. Total Cases vs. Total Deaths vs. Death Percentage
SELECT 
    SUM(new_cases) AS total_infections,
    SUM(new_cases) / 8066842874 * 100 AS Infection_Percentage_of_World_Population,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
    (SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100 AS DeathPercentage,
    SUM(CAST(new_deaths AS SIGNED)) / 8066842874 * 100 AS Death_Percentage_of_World_Population
FROM 
    PortfolioProject.replica_covid_deaths
WHERE 
    continent IS NOT NULL AND continent <> ''
-- AND location LIKE '%states%'
-- GROUP BY date -- This line is commented out in your query; you can uncomment it if needed
ORDER BY 
    total_cases, 
    total_deaths;


-- 2. TotalDeathCount per continent
SELECT 
    location, 
    SUM(CAST(new_deaths AS SIGNED)) AS TotalDeathCount,
    SUM(CAST(new_cases AS SIGNED)) AS TotalInfectionCount
FROM
    PortfolioProject.replica_covid_deaths
WHERE 
    continent IS NULL OR continent = '' 
    AND location NOT IN ('High Income','Low Income','World', 'European Union', 'International')
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;


SELECT 
    SUM(TotalDeathCount) AS TotalDeathsInAsia
FROM (
    SELECT 
        SUM(CAST(new_deaths AS SIGNED)) AS TotalDeathCount
    FROM
        PortfolioProject.replica_covid_deaths
    WHERE 
        continent = 'Asia'
        AND location NOT IN ('High Income','Low Income','World', 'European Union', 'International')
    GROUP BY 
        location
) AS Subquery;


-- 3. HighestInfectionCount and PercentPopulationInfected WITHOUT date
-- Calculate maximum infection count () within each location
-- Calculate population percentage of infected population (PercentPopulationInfected)
-- HighestInfectionCount/ population * 100
SELECT
    Location,
    Population,
    Sum(new_cases) AS TotalInfectionCount,
    (SUM(new_cases) / Population) * 100 AS PercentPopulationInfected,
    Sum(new_deaths) AS TotaldeatchCount,
    (SUM(new_deaths) / Population) * 100 AS PercentPopulationDeath
FROM
    PortfolioProject.replica_covid_deaths
-- WHERE location LIKE '%states%'
GROUP BY
    Location, Population
ORDER BY
    PercentPopulationInfected DESC;


-- 4. HighestInfectionCount and PercentPopulationInfected WITH date
-- (HighestInfectionCount): Calculates the maximum infection count for each combination
-- (PercentPopulationInfected): Calculates the percentage of the population infected
SELECT
    Location,
    Population,
    date,
    MAX(total_cases) AS HighestInfectionCount,
    (MAX(total_cases) / Population) * 100 AS PercentPopulationInfected
FROM
    PortfolioProject.replica_covid_deaths
-- WHERE location LIKE '%states%'
GROUP BY
    Location, Population, date
ORDER BY
    PercentPopulationInfected DESC;


-- 44. HighestInfectionCount and PercentPopulationInfected WITH date
-- (HighestInfectionCount): Calculates the maximum infection count for each combination
-- (PercentPopulationInfected): Calculates the percentage of the population infected
SELECT
    Location,
    Population,
    date,
    new_cases
FROM
    PortfolioProject.replica_covid_deaths
-- WHERE location LIKE '%states%'
GROUP BY
    Location, Population, date
ORDER BY
    new_cases_per_million DESC;



-- 5. maximum number of people vaccinated for each location and date
-- percentage of the population that has been vaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    MAX(vac.total_vaccinations) as RollingPeopleVaccinated,
    (MAX(vac.total_vaccinations) / dea.population) * 100 as VaccinationPercentage
FROM PortfolioProject.replica_covid_deaths dea
JOIN PortfolioProject.replica_covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY dea.continent, dea.location, dea.date;


-- 55. maximum number of people vaccinated for each location and date
-- percentage of the population that has been vaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    MAX(vac.total_vaccinations) as RollingPeopleVaccinated,
    (MAX(vac.total_vaccinations) / dea.population) * 100 as VaccinationPercentage
FROM PortfolioProject.replica_covid_deaths dea
JOIN PortfolioProject.replica_covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY dea.continent, dea.location, dea.date;


-- 6. 
SELECT 
    SUM(new_cases) as total_cases, 
    SUM(CAST(new_deaths AS SIGNED)) as total_deaths, 
    (SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100 as DeathPercentage
FROM PortfolioProject.replica_covid_deaths
WHERE continent IS NOT NULL AND continent <> ''
-- You can group by date if needed
-- GROUP BY date
ORDER BY total_cases, total_deaths;


-- 7. total death count for each location 
SELECT location, SUM(CAST(new_deaths AS SIGNED)) as TotalDeathCount
FROM PortfolioProject.replica_covid_deaths
WHERE continent IS NULL AND continent <> ''
    AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC; 


-- 8.
SELECT
    Location,
    Population,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases / Population)) * 100 as PercentPopulationInfected
FROM PortfolioProject.replica_covid_deaths
-- You can uncomment the WHERE clause if needed
-- WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC; 


-- 9. Total Deaths and Total Cases
-- This query will retrieve data for each location, including the date, population, total_cases, and total_deaths

Select 
    Location, 
    date, 
    population, 
    total_cases, 
    total_deaths
From 
    PortfolioProject.replica_covid_deaths
-- Where location like '%states%'
where continent is not null AND continent <> ''
order by Location, date;


-- 10. Rolling Sum of New Vaccinations (RollingPeopleVaccinated)
-- PopvsVac common table expression (CTE) calculates RollingPeopleVaccinated for each location over time
-- Percentage of people vaccinated: RollingPeopleVaccinated/ Population * 100

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject.replica_covid_deaths dea
    JOIN 
        PortfolioProject.replica_covid_vaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL AND dea.continent <> ''
)
SELECT 
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentPeopleVaccinated
FROM 
    PopvsVac;


-- 11. HighestInfectionCount as PercentPopulationInfected
-- MAX(total_cases) calculates the highest infection count.
-- MAX(total_cases / Population) * 100 calculates the percentage of the population infected.

SELECT
    Location,
    Population,
    date,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases / Population) * 100 AS PercentPopulationInfected
FROM
    PortfolioProject.replica_covid_deaths
-- WHERE location LIKE '%states%'
GROUP BY
    Location, Population, date
ORDER BY
    PercentPopulationInfected DESC;


-- 12. maximum number of people vaccinated for each location and date
-- percentage of the population that has been vaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.population,
	SUM(vac.new_vaccinations) / dea.population * 100 as VaccinationPercentage
FROM PortfolioProject.replica_covid_deaths dea
JOIN PortfolioProject.replica_covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
GROUP BY dea.continent, dea.location, dea.population
ORDER BY dea.location;


-- 13. -- 4. HighestInfectionCount and PercentPopulationInfected WITH date
-- (HighestInfectionCount): Calculates the maximum infection count for each combination
-- (PercentPopulationInfected): Calculates the percentage of the population infected
SELECT
    Location,
    Population,
    date,
    new_cases
    (MAX(total_cases) / Population) * 100 AS PercentPopulationInfected
FROM
    PortfolioProject.replica_covid_deaths
-- WHERE location LIKE '%states%'
GROUP BY
    Location, Population, date
ORDER BY
    PercentPopulationInfected DESC;