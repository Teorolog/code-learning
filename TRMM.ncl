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
system("rm -rf prc_all.nc")
   fout1 = addfile("prc_all.nc", "c")
       fout1->prc_all = data_all

data_ave=dim_avg_n_Wrap(data_all,2)
system("rm -rf prc_monthly.nc")
   fout2 = addfile("prc_monthly.nc", "c")
       fout2->aodave = data_ave

 wks_type          = "png"
   ;wks_type@wkWidth  =  2048
     ;wks_type@wkHeight =  2048
	   wks = gsn_open_wks(wks_type,"prc")
	      res0                      =  True
		    res0@gsnDraw              =  False
			  res0@gsnFrame             =  False
			    res0@gsnLeftString        = " "
				  res0@gsnRightString       = " "
				    res0@gsnAddCyclic         =  True
					  res0@cnFillOn             =  True
					    res0@cnFillPalette        = "ncl_default"
						  res0@cnLineLabelsOn       = False
						    res0@cnLinesOn = False
							  res0@cnLevelSelectionMode = "ManualLevels" ;-- manual contour levels
							    res0@cnMinLevelValF       =  0.          ;-- minimum level
								  res0@cnMaxLevelValF       =  10          ;-- maximum level
								    res0@cnLevelSpacingF      =  1.          ;-- contour spacing

									  res0@cnLabelBarEndStyle = "ExcludeOuterBoxes"
									    res0@mpDataBaseVersion   = "MediumRes" 
										  res0@mpDataSetName = "Earth..4"
										    res0@mpAreaMaskingOn        = True                 ; draw only parts of map 
											  res0@mpMaskAreaSpecifiers = (/"China"/)
											    res0@mpOutlineSpecifiers = (/"China","China:Provinces"/)
												  res0@mpGridAndLimbOn        = False                ; no lat/lon lines
												    res0@mpOutlineOn = True
													  ;res0@mpOutlineBoundarySets = "Geophysical"
													    res0@mpGeophysicalLineThicknessF = 1.5
														  res0@mpProvincialLineThicknessF = 1.
														    res0@mpNationalLineThicknessF=2.

															  res0@lbLabelBarOn         =  True                   ;-- no single label bar
															    res0@mpMinLatF            =  4
																  res0@mpMaxLatF            =  50
																    res0@mpMinLonF            =  73
																	  res0@mpMaxLonF            =  150

																	    plot00 = gsn_csm_contour_map(wks, data_ave , res0)
																		 pres = True
																		   ;pres@gsnPanelMainString = " "     ;-- panel title string (resource added in 6.4.0)
																		     ;pres@gsnPanelLabelBar   =  True            ;-- turn on a common labelbar for the entire panel plot
																			  ; pres@gsnPanelTop = 0.99 ; Panel 最顶位置
																			   ; pres@gsnPanelBottom = 0.01 ; Panel 最底位置
																			    ; pres@gsnPanelLeft = 0.01 ; Panel 最左位置
																				 ; pres@gsnPanelRight = 0.99 ; Panel 最右位置
																				   pres@gsnPanelCenter = False ; Panel 居中
																				     gsn_panel(wks,(/plot00/),(/1,1/),pres)
end
