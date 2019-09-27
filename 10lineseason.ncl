
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
y = ispan(1998, 2018, 1)

  
delete(prc)
end do  
;print(data_all)

x=new((/400,1440,21/),double,-999.)

jja=new((/400,1440,3/),double,-999.)

do j=0,20,1
do xx=6,8,1
jja(:,:,xx-6)=data_all(:,:,j*12+xx)
end do
x(:,:,j)=dim_avg_n_Wrap(jja,2)
end do
data_annual_mean=new((/2,21/),double,-999.)
data_annual_meann1=x(327,1195,:)
data_annual_meanb1=x(359,1185,:)
data_annual_mean(0,:)=data_annual_meann1
data_annual_mean(1,:)=data_annual_meanb1
;print(data_annual_mean)

wks   = gsn_open_wks ("png","xy3")               ; send graphics to PNG file

res                    = True              ; plot mods desired
;  res@gsnDraw            = True             ; don't draw yet
    res@gsnFrame           = False             ; don't advance frame yet

	  res@vpHeightF 	 = 0.3               ; change aspect ratio of plot
	    res@vpWidthF 	         = 0.7

;		  res@trYMaxF            = 1.0
;		    res@trXMinF         = 1998              ; set x-axis minimum

			  res@xyMonoLineColor    = False             ; want colored lines
			    res@xyLineColors       = (/"Red","Blue"/) ; colors chosen
				  res@xyLineThicknesses = (/4.,4./)      ; line thicknesses
				    res@xyDashPatterns = (/0.,0./)      ; make all lines solid

					  res@tiYAxisString = "Precipitation(mm/d)"      ; add an axis title    
					    res@txFontHeightF = 0.0195            ; change title font heights
						  
						  
   plot  = gsn_csm_xy (wks,y,data_annual_mean,res) ; create plot
   res_text                    = True                  ; text mods desired
     res_text@txFontHeightF      = 0.015                 ; change text size
	   res_text@txJust             = "CenterLeft"          ; text justification

	     res_lines                   = True                  ; polyline mods desired
		   res_lines@gsLineDashPattern = 0.                    ; solid line
		     res_lines@gsLineThicknessF  = 5.                    ; line thicker
			   res_lines@gsLineColor       = "red"                 ; line color
			     n = (/1999,2002/)
				   l = (/8.6,8.6/)
				  
				    gsn_polyline(wks,plot,n,l,res_lines)
			;	dum1=gsn_add_text(wks,plot,"Nanjing",2004,5.6,res_text); add text
					     
						   l = (/8.2,8.2/)
						 
						     res_lines@gsLineColor       = "blue"  ; change to blue
							 gsn_polyline(wks,plot,n,l,res_lines)
			;		 dum2=gsn_add_text(wks,plot,"Beijing",2004,5.2,res_text)       ; add text
								 frame(wks)
end
