begin
file_name = systemfunc ("ls 3B43.*.HDF")
  nfile=dimsizes(file_name)
  data_all=new((/400,1440,nfile/),double,-999.)
  date=(/365,365,366,365,365,365,366,365,365,365,366,365,365,365,366,365/)
do i=0,nfile-1,1  
   f      = addfile (file_name(i), "r")
   prc   = f->precipitation                   ; (scan, longitude, latitude)
   prc=prc*24

   prc@_FillValue  = -9999.
   prc@units       = "mm/d"
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
y = ispan(2003, 2012, 1)

  
delete(prc)
end do  
plot=new(4,graphic)
w=new((/400,1440,10/),double,-999.)
s=new((/400,1440,10/),double,-999.)
x=new((/400,1440,10/),double,-999.)
a=new((/400,1440,10/),double,-999.)
djf=new((/400,1440,10/),double,-999.)
mam=new((/400,1440,10/),double,-999.)
jja=new((/400,1440,10/),double,-999.)
son=new((/400,1440,10/),double,-999.)
do j=5,14,1
do xw=0,2,1
djf(:,:,xw)=data_all(:,:,j*12+xw)
end do
w(:,:,j-5)=dim_avg_n_Wrap(djf,2)*90/3
do xs=3,5,1
mam(:,:,xs-3)=data_all(:,:,j*12+xs)
end do
s(:,:,j-5)=dim_avg_n_Wrap(mam,2)*92/3
do xx=6,8,1
jja(:,:,xx-6)=data_all(:,:,j*12+xx)
end do
x(:,:,j-5)=dim_avg_n_Wrap(jja,2)*92/3
do xa=9,11,1
son(:,:,xa-9)=data_all(:,:,j*12+xa)
end do
a(:,:,j-5)=dim_avg_n_Wrap(son,2)*91/3
end do
printVarSummary(w)   
printVarSummary(s)   
printVarSummary(x)   
printVarSummary(a)   
wt=new((/400,1440/),double);;
st=new((/400,1440/),double);;
xt=new((/400,1440/),double);;
at=new((/400,1440/),double);;
wt=regCoef(y,w)*10
st=regCoef(y,s)*10
xt=regCoef(y,x)*10
at=regCoef(y,a)*10
acrw=new((/400,1440,1/),double);;
acrs=new((/400,1440,1/),double);;
acrx=new((/400,1440,1/),double);;
acra=new((/400,1440,1/),double);;
do m=0,399,1
do n=0,1439,1
;w
acrw(m,n,:)=esccr(y,w(m,n,:)*10,0)
;s
acrs(m,n,:)=esccr(y,s(m,n,:)*10,0)
;x
acrx(m,n,:)=esccr(y,x(m,n,:)*10,0)
;a
acra(m,n,:)=esccr(y,a(m,n,:)*10,0)
end do 
end do
Nr    = dimsizes(y)
probw=rtest(acrw,Nr,0)
probs=rtest(acrs,Nr,0)
probx=rtest(acrx,Nr,0)
proba=rtest(acra,Nr,0)
;siglvl= 0.1
;wprob=(1-probw)*100
;sprob=(1-probs)*100
;xprob=(1-probx)*100
;aprob=(1-proba)*100
probw=where(probw.gt.1,1,probw)
probs=where(probs.gt.1,1,probs)
probx=where(probx.gt.1,1,probx)
proba=where(proba.gt.1,1,proba)
kt=(/st,xt,at,wt/)
prob=(/probs(:,:,0),probx(:,:,0),proba(:,:,0),probw(:,:,0)/)
;print(prob)
printVarSummary(prob) 
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

   kt!1      = "lat"                   ; 1st ... name the dimensions
   kt!2      = "lon"
   kt&lat    =  lat                    ; create coordinate variable
   kt&lon    =  lon        
   prob!1      = "lat"                   ; 1st ... name the dimensions
   prob!2      = "lon"
   prob&lat    =  lat                    ; create coordinate variable
   prob&lon    =  lon   
;printVarSummary(w)   
   ;print(xt)
  ; printMinMax(probs,False)
wks=gsn_open_wks("png","trmmtrend2")
plot=new(4,graphic)
plott=new(4,graphic)
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

do i=0,3  
  plot(i) = gsn_csm_contour_map_ce(wks,kt(i,:,:),res)
end do

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

do i=0,3 
  plott(i) = gsn_csm_contour(wks, prob(i,:,:),res)
  overlay(plot(i),plott(i))
end do
  
 pres=True
 pres@gsnPanelFigureStrings = (/"A","B","C","D"/)
 pres@amJust = "TopLeft"
 pres@gsnPanelMainString = " "
 pres@gsnPanelLabelBar   =  True
 gsn_panel(wks,plot,(/2,2/),pres)

end 
