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
																		data_annual_ave(:,:,j)=dim_avg_n_Wrap(data_annual,2)
																		end do
																		data_annual_mean=new((/2,22/),double,-999.)
																		;data_annual_mean1=dim_avg_n_Wrap(data_annual_ave(216:399,1012:1323,:),0)
																		data_annual_meann1=data_annual_ave(327,1195,:)
																		 data_annual_meanb1=data_annual_ave(359,1185,:)
																		data_annual_mean(0,:)=data_annual_meann1
																		data_annual_mean(1,:)=data_annual_meanb1
																	print(data_annual_mean)
;																	print(lat)
wks   = gsn_open_wks ("png","xy2")               ; send graphics to PNG file

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
				   l = (/5.6,5.6/)
				  
				    gsn_polyline(wks,plot,n,l,res_lines)
			;	dum1=gsn_add_text(wks,plot,"Nanjing",2004,5.6,res_text); add text
					     
						   l = (/5.2,5.2/)
						 
						     res_lines@gsLineColor       = "blue"  ; change to blue
							 gsn_polyline(wks,plot,n,l,res_lines)
			;		 dum2=gsn_add_text(wks,plot,"Beijing",2004,5.2,res_text)       ; add text
								 frame(wks)
end
