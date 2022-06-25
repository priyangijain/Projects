/*
Cleaning Data in SQL Queries
*/

Use Portfolioproject
Select * from Portfolioproject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted ,CONVERT(Date,SaleDate)
from Portfolioproject..NashvilleHousing


Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
from Portfolioproject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNull(a.PropertyAddress,b.PropertyAddress)
From Portfolioproject..NashvilleHousing a
JOIN Portfolioproject..NashvilleHousing b
 ON a.ParcelID=b.ParcelID
 AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress=ISNull(a.PropertyAddress,b.PropertyAddress)
From Portfolioproject..NashvilleHousing a
JOIN Portfolioproject..NashvilleHousing b
 ON a.ParcelID=b.ParcelID
 AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from Portfolioproject..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from Portfolioproject..NashvilleHousing


Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter table NashvilleHousing
Add PropertySplitState Nvarchar(255)

Update NashvilleHousing
Set PropertySplitState = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


Select * from Portfolioproject ..NashvilleHousing



Select OwnerAddress
from Portfolioproject ..NashvilleHousing



Select PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,
       PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
From Portfolioproject..NashvilleHousing
order by state desc


Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant),Count(SoldAsVacant)
From Portfolioproject..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant,
Case when SoldAsVacant='Y' Then 'Yes'
When SoldAsVacant='N' Then 'No'
Else SoldAsVacant
END
From Portfolioproject..NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant=Case when SoldAsVacant='Y' Then 'Yes'
When SoldAsVacant='N' Then 'No'
Else SoldAsVacant
END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

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
From PortfolioProject.dbo.NashvilleHousing)
--order by ParcelID



DELETE 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER table NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate












