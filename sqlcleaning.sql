--Data Cleaning Using SQL

SELECT *
FROM dbo.nashville_housing
---------------------

--Standardize date format -- 

SELECT SaleDate, CONVERT (Date, SaleDate)
FROM dbo.nashville_housing

UPDATE nashville_housing
SET SaleDate = CONVERT (Date, SaleDate)

--if it doesnt update properly

ALTER TABLE nashville_housing
Add SaleDateConverted Date; 

UPDATE nashville_housing
SET SaleDateConverted = CONVERT (Date, SaleDate)

SELECT SaleDateConverted
FROM dbo.nashville_housing

---------------------------------------
--Populate property address data

SELECT *
FROM dbo.nashville_housing
--WHERE PropertyAddress is null
ORDER BY [UniqueID ]


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

update a
set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

---------------------------------------

select *
from nashville_housing
--where PropertyAddress is null

--break out address into single ind column (address, city, state)

select
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) AS Address
, SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress)) as city
from nashville_housing

ALTER TABLE nashville_housing
Add address_split Nvarchar(255); 

UPDATE nashville_housing
SET address_split = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) 

ALTER TABLE nashville_housing
Add city_split Nvarchar(255); 

UPDATE nashville_housing
SET city_split = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress)) 

select 
parsename (replace (OwnerAddress, ',','.'),3)
,parsename (replace (OwnerAddress, ',','.'),2)
, parsename (replace (OwnerAddress, ',','.'),1)
from nashville_housing

ALTER TABLE nashville_housing
Add owner_address_split Nvarchar(255); 

UPDATE nashville_housing
SET owner_address_split = parsename (replace (OwnerAddress, ',','.'),3)

ALTER TABLE nashville_housing
Add owner_city_split Nvarchar(255); 

UPDATE nashville_housing
SET owner_city_split = parsename (replace (OwnerAddress, ',','.'),2)

ALTER TABLE nashville_housing
Add owner_state_split Nvarchar(255); 

UPDATE nashville_housing
SET owner_state_split = parsename (replace (OwnerAddress, ',','.'),1)

select *
from nashville_housing

-------------------------------------------------------
--Change Y and N to Yes and No in SoldAsVacant

select Distinct (SoldAsVacant), count (SoldAsVacant)
from nashville_housing
group by SoldAsVacant
order by 1

select SoldAsVacant
, case when SoldAsVacant = 'N' then 'No'
 when SoldAsVacant = 'Y' then 'Yes'
 else SoldAsVacant
 end
from nashville_housing


update nashville_housing
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
 when SoldAsVacant = 'Y' then 'Yes'
 else SoldAsVacant
 end
----------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From nashville_housing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From nashville_housing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From nashville_housing


ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

