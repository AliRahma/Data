-------------------------- Change saledate format from DateTime to Date
update Nashville_Housing set saledate= cast(saledate as date);

select saledate
from Nashville_Housing;

----------update NULL values in propertyaddress column--------------------------
update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from 
Nashville_Housing a
join Nashville_Housing b
on a.parcelid=b.parcelid
and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null
------The next Query should return no rows
select a.parcelid,a.propertyaddress ,b.parcelid,b.propertyaddress
from Nashville_Housing a
join Nashville_Housing b
on a.parcelid=b.parcelid
and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

---------------Split PropertyAddress and OwnerAddress-------------------------
---------------First PropertyAddress Using Substring and CharIndex------------
alter table nashville_housing
add SplitPropertyAddress nvarchar(255);

update Nashville_Housing
set SplitPropertyAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1);

alter table nashville_housing
add SplitPropertyCity nvarchar(255);

update Nashville_Housing
set SplitPropertyCity= SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(propertyaddress));

select PropertyAddress,SplitPropertyAddress,SplitPropertyCity
from Nashville_Housing;

---------------Second OwnerAddress Using Parsename------------
alter table Nashville_Housing
add SplitOwnerAddress nvarchar(255);

update Nashville_Housing 
set SplitOwnerAddress =PARSENAME(Replace(owneraddress,',','.'),3);

alter table Nashville_Housing
add SplitOwnerCity nvarchar(255);

update Nashville_Housing 
set SplitOwnerCity =PARSENAME(Replace(owneraddress,',','.'),2);

alter table Nashville_Housing
add SplitOwnerState nvarchar(255);

update Nashville_Housing 
set SplitOwnerState =PARSENAME(Replace(owneraddress,',','.'),1);

select owneraddress,SplitOwnerAddress,SplitOwnerCity,SplitOwnerState
from Nashville_Housing

----------------Update N and Y in column SoldAsVacant-----------------------------
update Nashville_Housing 
set SoldAsVacant='Yes' where SoldAsVacant='Y';
update Nashville_Housing 
set SoldAsVacant='No' where SoldAsVacant='N';
--Next Statement should only return Yes and No in different rows----
select distinct(SoldAsVacant)
from Nashville_Housing

-------------Remove Duplicates-----------------------------------------------
with RowNumCTE as(
select *,
ROW_NUMBER() over (partition by
			ParcelID,
			PropertyAddress,
			SaleDate,
			SalePrice,
			LegalReference
			order by uniqueID
		   ) row_num
from Nashville_Housing)
--------The next Query show return no rows
select * from RowNumCTE where row_num>1

-------------Delete Unused Columns-------------------------
alter table nashville_housing
drop column PropertyAddress,OwnerAddress,TaxDistrict

Select * from Nashville_Housing