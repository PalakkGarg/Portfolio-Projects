-- Cleaning Data in SQL Queries

SELECT * FROM sqlportfolioproject.`nashville housing data`;
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

UPDATE `sqlportfolioproject`.`nashville housing data`
SET `SaleDate` = STR_TO_DATE(`SaleDate`, '%M %e, %Y');

ALTER TABLE `sqlportfolioproject`.`nashville housing data`
MODIFY COLUMN `SaleDate` DATETIME NULL DEFAULT NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM `nashville housing data` a
JOIN `nashville housing data` b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE `nashville housing data` a
JOIN `nashville housing data` b ON a.ParcelID = b.ParcelID AND a.`UniqueID` <> b.`UniqueID`
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS Address
FROM `nashville housing data`;

alter table `nashville housing data`
Add PropertySplitAddress text;

update `nashville housing data`
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

alter table `nashville housing data`
add PropertySplitCity text;

update `nashville housing data`
set PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress));

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from `nashville housing data`
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when  SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from `nashville housing data`;

update `nashville housing data`
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
					when  SoldAsVacant = 'N' then 'No'
					else SoldAsVacant
					end;
                    
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

drop table if exists RemoveDuplicates;
create temporary table RemoveDuplicates
(
UniqueID int, ParcelID text, LandUse text, PropertyAddress text, SaleDate datetime,
SalePrice int, LegalReference text, SoldAsVacant text, OwnerName text, OwnerAddress text,
Acreage double, TaxDistrict text, LandValue int, BuildingValue int, TotalValue int,
YearBuilt int, Bedrooms int, FullBath int, HalfBath int, PropertySplitAddress text,
PropertySplitCity text, row_num int
);
insert into RemoveDuplicates
select *, row_number() over(
partition by ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                order by 
					UniqueID
                    ) as row_num 
from `nashville housing data`;

select * from RemoveDuplicates where row_num > 1;

delete from RemoveDuplicates where row_num > 1;

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

 Select * From `nashville housing data`;

ALTER TABLE `nashville housing data`
DROP COLUMN PropertyAddress;