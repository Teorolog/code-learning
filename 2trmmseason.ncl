begin
file_name = systemfunc ("ls 3B43.*.HDF")
  nfile=dimsizes(file_name)
  data_all=new((/400,1440,nfile/),double,-999.)
do i=0,nfile-1,1  
   f      = addfile (file_name(i), "r")
   prc   = f->precipitation                   ; (scan, longitude, latitude)
   prc=prc*24

   prc@_FillValue  = -9999.
   prc@units       = "mm/hr"
   prc@long_name   = "TRMM_3B43 precip"

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

   prc!1      = "lat"                   ; 1st ... name the dimensions
   prc!0      = "lon"
   prc&lat    =  lat                    ; create coordinate variable
   prc&lon    =  lon                                     
data_all(:,:,i)= prc(lat|:,lon|:)
y = ispan(1998, 2019, 1)

  
delete(prc)
end do  
plot=new(4,graphic)
data_season_ave=new((/400,1440,4/),double,-999.)
w=new((/400,1440,22/),double,-999.)
s=new((/400,1440,22/),double,-999.)
x=new((/400,1440,22/),double,-999.)
a=new((/400,1440,22/),double,-999.)
djf=new((/400,1440,22/),double,-999.)
mam=new((/400,1440,22/),double,-999.)
jja=new((/400,1440,22/),double,-999.)
son=new((/400,1440,22/),double,-999.)
do j=0,21,1
if (j.le.20) then
do xw=0,2,1
djf(:,:,xw)=data_all(:,:,j*12+xw)
end do
w(:,:,j)=dim_avg_n_Wrap(djf,2)
do xs=3,5,1
mam(:,:,xs-3)=data_all(:,:,j*12+xs)
end do
s(:,:,j)=dim_avg_n_Wrap(mam,2)
do xx=6,8,1
jja(:,:,xx-6)=data_all(:,:,j*12+xx)
end do
x(:,:,j)=dim_avg_n_Wrap(jja,2)
do xa=9,11,1
son(:,:,xa-9)=data_all(:,:,j*12+xa)
end do
a(:,:,j)=dim_avg_n_Wrap(son,2)
else
w(:,:,j)=dim_avg_n_Wrap(data_all(:,:,251:253),2)
end if
end do
w_all=dim_avg_n_Wrap(w,2)
s_all=dim_avg_n_Wrap(s,2)
x_all=dim_avg_n_Wrap(x,2)
a_all=dim_avg_n_Wrap(a,2)
data_season_ave(:,:,0)=w_all
data_season_ave(:,:,1)=s_all
data_season_ave(:,:,2)=x_all
data_season_ave(:,:,3)=a_all
system("rm -rf prc_season.nc")
   fout2 = addfile("prc_season.nc", "c")
       fout2->aodseason = data_season_ave
tit= (/"DJF","MAM","JJA","SON"/)
do k=0,3,1
wks_type          = "png"
   ;wks_type@wkWidth  =  2048
        ;wks_type@wkHeight =  2048
		      wks = gsn_open_wks(wks_type,"prc_season")
;plot=new(22,graphic)
  res0                      =  True
  res0@gsnDraw              =  False
  res0@gsnFrame             =  False
  res0@gsnLeftString        = " "
  res0@gsnRightString       = " "
  res0@gsnCenterString      = tit(k)
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
plot(k) = gsn_csm_contour_map(wks, data_season_ave(:,:,k), res0)


draw(plot(k))
frame(wks)
system("mv prc_season.png prc_season"+k+".png")
system("rm -f prc_season.png")
end do


 

end
