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
y= ispan(2013, 2017, 1)
data_ave=new((/400,1440,5/),double);;
do j=0,4,1
data_ave(:,:,j)=(dim_avg_n_Wrap(data_all(:,:,(j+5)*12+0:(j+5)*12+11),2))*365
end do
yt=new((/400,1440/),double);;
yt=regCoef(y,data_ave)*10
acry=new((/400,1440,1/),double);;
do m=0,399,1
do n=0,1439,1
;w
acry(m,n,:)=esccr(y,data_ave(m,n,:)*10,0)
end do
end do
Nr    = dimsizes(y)
proby=rtest(acry,Nr,0)
prob=proby(:,:,0)
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

   yt!0      = "lat"                   ; 1st ... name the dimensions
   yt!1      = "lon"
   yt&lat    =  lat                    ; create coordinate variable
   yt&lon    =  lon        
   prob!0      = "lat"                   ; 1st ... name the dimensions
   prob!1      = "lon"
   prob&lat    =  lat                    ; create coordinate variable
   prob&lon    =  lon  
   wks=gsn_open_wks("png","trmmtrendy3")
  res                  = True                      ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@cnLinesOn        = False                ; no contour li
  res@pmTickMarkDisplayMode = "Always"; use NCL default lat/lon labels
;  res@vpHeightF= 0.4                    ; change aspect ratio of plot
;  res@vpWidthF = 0.6
  res@pmLabelBarOrthogonalPosF = 0.1           ; move whole thing down

  res@pmLabelBarWidthF     =  0.7
  res@pmLabelBarHeightF    =  0.05
  res@lbLabelFontHeightF   =  0.015
  res@tmXBLabelFontHeightF =  0.018       
  res@tmYLLabelFontHeightF =  0.018    
  res@lbLabelBarOn         =  False  

  res@mpLimitMode         = "LatLon"
  res@mpMinLatF           = 4
  res@mpMaxLatF           = 50
  res@mpMinLonF           = 73
  res@mpMaxLonF           = 150
  res@mpDataBaseVersion="Ncarg4_1";中等分辨率 province outline
  res@mpDataSetName="Earth..4"           ;第4版地图，有中国边界数据
  res@mpOutlineOn            = True
  res@mpOutlineBoundarySets = "National"
  res@mpOutlineSpecifiers=(/"China:states","Taiwan"/)

  gsn_define_colormap(wks,"GMT_polar")
  res@cnFillOn             = True         ; turn on color fill
  res@cnLineLabelsOn       = False
  res@cnLinesOn = False
  res@gsnSpreadColors       =True
  res@cnRasterModeOn        = True
;  res@pmLabelBarOrthogonalPosF = 0.14           ; move whole thing down
  res@cnLevelSelectionMode  = "ExplicitLevels"  
  res@cnLevels              = (/-60.,-40.,-20.,-10.,0.,10.,20.,40.,60./)
  res@cnFillColors          = (/2,4,6,7,9,13,14,15,16,17/)

  plot = gsn_csm_contour_map_ce(wks,yt(:,:),res)


  delete(res)
   res                      = True              
res@gsnDraw              = False             
res@gsnFrame             = False             
res@cnMonoFillPattern    = False
res@cnMonoFillColor      = True
res@cnLinesOn            = False
res@cnLineLabelsOn       = False
res@cnInfoLabelOn        = False
res@lbLabelBarOn         = False
res@gsnAddCyclic         = False
   
res@cnLevelSelectionMode  = "ExplicitLevels"  
res@cnLevels              = (/0.05/)            
res@cnFillOn              = True
res@gsnSpreadColors       = True
res@cnFillColor           = (/"white","black"/) 
res@cnFillPatterns        = (/17,-1/)
res@cnFillDotSizeF        = 0.0035


  plott = gsn_csm_contour(wks, prob(:,:),res)
  overlay(plot,plott)

  
 pres=True
 ;pres@gsnPanelFigureStrings = (/"A","B","C","D"/)
 pres@amJust = "TopLeft"
 pres@gsnPanelMainString = " "
 pres@gsnPanelLabelBar   =  True
 gsn_panel(wks,plot,(/1,1/),pres)

end 
