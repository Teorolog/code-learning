begin
file_name = systemfunc ("ls 3B43.*.HDF")
  nfile=dimsizes(file_name)
  data_all=new((/400,1440,nfile/),double,-999.)
do i=0,nfile-1,1  
   f      = addfile (file_name(i), "r")
  ; prc   = f->precipitation                   ; (scan, longitude, latitude)
   prc   = f->relativeError                   ; (scan, longitude, latitude)
   prc=prc*24
;***************************************************************
; Add meta data: See above README 
;***************************************************************
   prc@_FillValue  = -9999.
   prc@units       = "mm/hr"
   prc@long_name   = "TRMM_3B43 precip"


;*****************************************************
; Create TRMM coordinate variables. See README
;*****************************************************
   nlat       = 400
   mlon       = 1440
   lat        = ispan(0,nlat-1,1)*0.25 -  49.875
   lon        = ispan(0,mlon-1,1)*0.25 - 179.875

   lat@long_name = "latitude"
   lat@units  = "degrees_north"
   lat!0      = "lat"
   lat&lat    =  lat

   lon@long_name = "longitude"
   lon@units  = "degrees_east"
   lon!0      = "lon"
   lon&lon    =  lon

;***************************************************************
; Associate the spatial coordinates with variables
; Rename the dimension to match the model. 
; Convenience only, not required.
;***************************************************************
   prc!1      = "lat"                   ; 1st ... name the dimensions
   prc!0      = "lon"
   prc&lat    =  lat                    ; create coordinate variable
   prc&lon    =  lon                                     

;***************************************************************
; Simple data exploration: 
;    Are there missing data?
;    Count the number of missing values in each variable
;
;    Calculate weighted areal averages: ignore missing grid points
;    Print results
;***************************************************************
  data_all(:,:,i)= prc(lat|:,lon|:)
delete(prc)
end do  
plot=new(22,graphic)
data_annual=new((/400,1440,12/),double,-999.)
data_annual_ave=new((/400,1440,22/),double,-999.)
y = ispan(1998, 2019, 1)
do j=0,21,1
do k=0,11,1
if (j.le.20) then
data_annual(:,:,k)=data_all(:,:,j*12+k)
else
data_annual(:,:,0)=data_all(:,:,252)
data_annual(:,:,1)=data_all(:,:,253)
end if
end do
wks_type          = "png"
   ;wks_type@wkWidth  =  2048
        ;wks_type@wkHeight =  2048
		      wks = gsn_open_wks(wks_type,"prc_annual_error")
			  
;plot=new(22,graphic)
  res0                      =  True
  res0@gsnDraw              =  False
  res0@gsnFrame             =  False
  res0@gsnLeftString        = " "
  res0@gsnRightString       = " "
  res0@gsnCenterString      = y(j)
  res0@gsnAddCyclic         =  True
  res0@cnFillOn             =  True
  res0@cnFillPalette        = "ncl_default"
  res0@cnLineLabelsOn       = False
  res0@cnLinesOn = False
  res0@cnLevelSelectionMode = "ManualLevels" ;-- manual contour levels
  res0@cnMinLevelValF       =  0.          ;-- minimum level
  res0@cnMaxLevelValF       =  10          ;-- maximum level
  res0@cnLevelSpacingF      =  1.          ;-- contour 
  res0@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  res0@mpDataBaseVersion   = "MediumRes"
  res0@mpDataSetName = "Earth..4"
  res0@mpAreaMaskingOn        = True                 ; draw only parts of map
  res0@mpMaskAreaSpecifiers = (/"China"/)
  res0@mpOutlineSpecifiers = (/"China","China:Provinces"/)
  res0@mpGridAndLimbOn        = False                ; no lat/lon l
  res0@mpOutlineOn = True
  res0@mpGeophysicalLineThicknessF = 1.5
  res0@mpProvincialLineThicknessF = 1.
  res0@mpNationalLineThicknessF= 2.
  res0@lbLabelBarOn         =  True                   ;-- no single label bar
  res0@mpMinLatF            =  4
  res0@mpMaxLatF            =  50
  res0@mpMinLonF            =  73
  res0@mpMaxLonF            =  150
data_annual_ave(:,:,j)=dim_avg_n_Wrap(data_annual,2)
plot(j) = gsn_csm_contour_map(wks, data_annual_ave(:,:,j) , res0)
draw(plot(j))
frame(wks)
system("mv prc_annual_error.png prc_error"+j+".png")
system("rm -f prc_annual.png")
end do
system("rm -rf prc_annual.nc")
   fout1 = addfile("prc_annual.nc", "c")
       fout1->prc_annual = data_annual

 

end
