begin
file_name = systemfunc ("ls 3B43.*.HDF")
  nfile=dimsizes(file_name)
  data_all=new((/400,1440,nfile/),double,-999.)
do i=0,nfile-1,1  
   f      = addfile (file_name(i), "r")
   prc   = f->precipitation                   ; (scan, longitude, latitude)
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
data_annual_ave(:,:,j)=dim_avg_n_Wrap(data_annual,2)
end do
print(data_annual_ave)
data_annual_mean1=dim_avg_n_Wrap(data_annual_ave,0)
data_annual_mean=dim_avg_n_Wrap(data_annual_mean1,0)
 wks = gsn_open_wks("png","prc_annual")             ; send graphics to PNG file

  res                    = True              ; plot mods desired
  res@gsnDraw            = True             ; don't draw yet
  res@gsnFrame           = True            ; don't advance frame yet

  res@vpHeightF 	 = 0.4               ; change aspect ratio of plot
  res@vpWidthF 	         = 0.7

  res@trYMaxF            = 1.0
  res@trXMinF	         = 1998              ; set x-axis minimum

  res@xyMonoLineColor    = True            ; want colored lines
  res@xyLineColors       = (/"Red"/) ; colors chosen
  res@xyLineThicknesses	 = 4      ; line thicknesses
  res@xyDashPatterns	 =0.     ; make all lines solid

  res@tiYAxisString	 = "Precipitation"      ; add an axis title    
  res@txFontHeightF	 = 0.0195            ; change title font heights
  
  top_plot = gsn_csm_xy (wks,y,data_annual_mean,res)       ; create line plot

