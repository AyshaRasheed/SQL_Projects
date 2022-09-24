Select * from [Housing Analysis]..[housing ] ;


---Standardize Date format

Select convert(Date,saledate) as SaledateConverted from [Housing Analysis]..[housing ];

update [Housing Analysis]..[housing ] set saledate= convert(Date,saledate) ;

Alter table [Housing Analysis]..[housing ]add saledataConverted date;

update [Housing Analysis]..[housing ]set saledataConverted = convert(Date,saledate) ;



---Populate propert address data

select propertyaddress from[Housing Analysis]..[housing ];

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,isnull(a.propertyaddress,b.propertyaddress)
from [Housing Analysis]..[housing ] a
join [Housing Analysis]..[housing ] b 
on  a.parcelid=b.parcelid
and a.uniqueid != b.uniqueid 
where a.propertyaddress is null;

update a
set a.propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
from [Housing Analysis]..[housing ] a
join [Housing Analysis]..[housing ] b 
on a.parcelid=b.parcelid 
and a.uniqueid!=b.uniqueid
where a.propertyaddress is null;



---Breaking out Address into Individual Coloumns (Address, City,State)\

select propertyaddress from [Housing Analysis]..[housing ];

select 
substring(propertyaddress,1,charindex(',',propertyaddress)-1 ) as SplitAddress,
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as SplitCity
from [Housing Analysis]..[housing ];

alter table [Housing Analysis]..[housing ]
add PropertySplitAddress nvarchar(255);

update [Housing Analysis]..[housing ] set PropertySplitAddress = substring(propertyaddress,1,charindex(',',propertyaddress)-1 );

alter table [Housing Analysis]..[housing ] 
add PropertySplitCity nvarchar(255);

update [Housing Analysis]..[housing ]
set PropertySplitCity=substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress));



----Using Parsename 

Select * from [Housing Analysis]..[housing ];

select parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from [Housing Analysis]..[housing ];

alter table [Housing Analysis]..[housing ]
add OwnerSplitAddress nvarchar(255);

update [Housing Analysis]..[housing ] 
set OwnerSplitAddress=parsename(replace(owneraddress,',','.'),3);


alter table [Housing Analysis]..[housing ]
add OwnerSplitCity nvarchar(255);

update [Housing Analysis]..[housing ] 
set OwnerSplitCity=parsename(replace(owneraddress,',','.'),2);


alter table [Housing Analysis]..[housing ]
add OwnerSplitState nvarchar(255);

update [Housing Analysis]..[housing ] 
set OwnerSplitState=parsename(replace(owneraddress,',','.'),1);



---Change Y and N to Yes and No in the 'Sold as Vacant' field

select distinct(soldasvacant),count(soldasvacant)
from [Housing Analysis]..[housing ] group by soldasvacant order by 2 desc;

select soldasvacant,
case when soldasvacant='Y' Then 'Yes'
     when soldasvacant='N' Then 'No'
     else soldasvacant
     end
from [Housing Analysis]..[housing ] ;

update [Housing Analysis]..[housing ] 
set soldasvacant= case when soldasvacant='Y' Then 'Yes'
     when soldasvacant='N' Then 'No'
     else soldasvacant
     end;



---Removing Duplicates

with RownumCTE as (
select *,
    row_number() over (
    partition by parcelid,
              propertyaddress,
			  saledate,
			  saleprice,
			  legalreference
              order by  uniqueid) rownum
from [Housing Analysis]..[housing ] 
)

delete from RownumCTE where rownum>1 ;



---Delete Unused Coloumns

select * from [Housing Analysis]..[housing ];

Alter table  [Housing Analysis]..[housing ]
drop column propertyaddress,owneraddress,taxdistrict,saledate;








