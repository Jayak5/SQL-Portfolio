select *
from NashvilleHousing


-- standardizing date format


select saledateconverted, CONVERT(date,saledate)
from NashvilleHousing

update NashvilleHousing
set saledate = CONVERT(date,saledate)
 

alter table NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted = CONVERT(date,saledate)


-- populating property address data


select *
from NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b 
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b 
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-- breaking out address into individual columns (address, city, state)


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
from NashvilleHousing

alter table NashvilleHousing
add propertysplitaddress NVARCHAR(255);

update NashvilleHousing
set propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add propertysplitcity NVARCHAR(255);

update NashvilleHousing
set propertysplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- an alternate way to doing this


select owneraddress
from NashvilleHousing

select 
PARSENAME(REPLACE(owneraddress, ',', '.'), 3) 
,PARSENAME(REPLACE(owneraddress, ',', '.'), 2)
,PARSENAME(REPLACE(owneraddress, ',', '.'), 1) 
from NashvilleHousing

alter table NashvilleHousing
add ownersplitaddress NVARCHAR(255);

update NashvilleHousing
set ownersplitaddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3) 

alter table NashvilleHousing
add ownersplitcity NVARCHAR(255);

update NashvilleHousing
set ownersplitcity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2)

alter table NashvilleHousing
add ownersplitstate NVARCHAR(255);

update NashvilleHousing
set ownersplitstate = PARSENAME(REPLACE(owneraddress, ',', '.'), 1) 


-- changing y and n to yes and no in "sold in vacant" field


select distinct (SoldAsVacant), count (SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
       else SoldAsVacant
       end
from NashvilleHousing

UPDATE NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
       else SoldAsVacant
       end


--- removing duplicates


with rownumCTE as (
select *,
row_number () over (
partition by parcelid,
             propertyaddress,
             saleprice,
             saledate,
             legalreference
order by uniqueid 
) row_num
from NashvilleHousing
)

delete
from rownumCTE
where row_num > 1


-- deleting unused columns


alter table NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress, saledate

