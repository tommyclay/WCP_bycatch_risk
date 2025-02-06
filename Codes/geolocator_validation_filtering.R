
# K. Rexer-Huber and R. Ramos

# This R code shows the position validation and filtering applied to GLS tracking data during processing. 
# Scripts were customised by R. Ramos and K. Rexer-Huber following Z. Zajková (unpubl. R scripts for GLS 2015). 
# Briefly, an equinox filter removed positions 15 days either side of the equinoxes (20–21 March and 22–23 September) 
# since equinoctial latitude estimation is unreliable (Hill 1994). A latitudinal filter removed extreme latitudinal outliers 
# (positions south of 70°S or north of the equator). Finally, a speed filter removed positions that would require unrealistic
# flight speeds.

####################################################################

##SETUP, LOAD DATA
require(adehabitatHR, argosfilter, graphics, maps, rworldmap, reshape, stringr, adehabitat, plyr, car, maptools) #packages required

Procellaria<-read.table("C:/Users/..path/Table.csv", header=T, sep=",", dec=".") # replace “C:/Users/..path/Table.csv” with the name of tracking data table that contains latitude and longitudes with islands and date
Procellaria$datextime <as.POSIXct(strptime(as.character(Procellaria$timestampGMT),"%Y-%m-%d %H:%M:%S"), tz="GMT") #check format of date in imported data

####################################################################


## QSPEED FILTERS ####

#####SETUP FOR SPEED FILTERS#####
Procellaria$LON<-as.numeric(as.character(Procellaria$longitude))
Procellaria$LONN<-Procellaria$LON-155 # shift calculations so longitudes are Pacific centred
Procellaria$LONNN<-ifelse(Procellaria$LONN<=-180, Procellaria$LONN+360, Procellaria$LONN) #if subtracting 180 gives a negative value add 360 to long

Procellaria$LAT<-as.numeric(as.character(Procellaria$latitude))
Procellaria$pop<-as.character(Procellaria$island)
Procellaria$month<- as.numeric(format(Procellaria$datextime, "%m"))
Procellaria$year<- as.numeric(format(Procellaria$datextime, "%Y"))

##group months into relevant periods for analyses: prelay Oct-Nov, breeding Dec-Apr, nonbreed May-Sep best capture actual breeding cycle
Procellaria$period <- recode (Procellaria$month, "'1'='2.breeding'; '2'='2.breeding'; '3'='2.breeding'; '4'='2.breeding'; '5'='3.nonbreeding'; '6'='3.nonbreeding'; '7'='3.nonbreeding'; '8'='3.nonbreeding'; '9'='3.nonbreeding'; '10'='1.prelay'; '11'='1.prelay'; '12'='2.breeding'")
head(Procellaria)#check defining and recoding worked

#####CALCULATE VELOCITY: Calculates distance, time and velocity between consecutive points ####

## DISTANCE (in km), using function "distanceTrack" {argosfilter} to calculate distance between sequential locations
Procellaria$distCAL<-c(0,distanceTrack(Procellaria$LAT, Procellaria$LON))   # note 0 is inserted for the first position
## TIME (in hours)
Procellaria$timeCAL<-numeric(nrow(Procellaria))
for(i in 2:nrow(Procellaria)) {
  datextime<-Procellaria$datextime
  Procellaria$timeCAL[1]<- 0    # insert 0 for the first position
  Procellaria$timeCAL[i]<- -(as.numeric(difftime(datextime[i-1], datextime[i], units = "hours", tz= "GMT")))
}
## VELOCITY (in km/h)
Procellaria$velocCAL<- ifelse(Procellaria$distCAL==0 | Procellaria$timeCAL==0, 0, Procellaria$distCAL/Procellaria$timeCAL)# insert 0 for the first position
Procellaria$eq <- 0

####################################################################

## LATITUDE FILTER: remove points with latitude >-70ºS or north of equator
Procellaria <- subset (Procellaria, Procellaria$LAT < 0 )
Procellaria <- subset (Procellaria, Procellaria$LAT > -70 )

####################################################################

## EQUINOX FILTER: Identify and remove positions that fall during the equinox

##### Setup#####

## M (March, spring equinox), S (September, autumnal equinox)
Procellaria$date2 <- as.Date (Procellaria$datextime)
Procellaria$eq2014M<- as.Date("2014-03-20") 
Procellaria$eq2014S<- as.Date("2014-09-22") 
Procellaria$eq2015M<- as.Date("2015-03-20") 
Procellaria$eq2015S<- as.Date("2015-09-22") #repeat for all relevant tracking years

Procellaria$eq <- ifelse ((Procellaria$date2 > Procellaria$eq2014M-20 & Procellaria$date2 < Procellaria$eq2014M+20), 1, Procellaria$eq)
Procellaria$eq <- ifelse ((Procellaria$date2 > Procellaria$eq2015M-20 & Procellaria$date2 < Procellaria$eq2015M+20), 1, Procellaria$eq)

Procellaria$eq <- ifelse ((Procellaria$date2 > Procellaria$eq2014S-20 & Procellaria$date2 < Procellaria$eq2014S+20), 1, Procellaria$eq)
Procellaria$eq <- ifelse ((Procellaria$date2 > Procellaria$eq2015S-20 & Procellaria$date2 < Procellaria$eq2015S+20), 1, Procellaria$eq)
Procellaria <- subset (Procellaria, Procellaria$eq == 0)

#####APPLY FILTER#####

Procellaria$eq2014M <- Procellaria$eq2014S <- Procellaria$eq2015M <- Procellaria$eq2015S <-NULL 
head(Procellaria)
aa <- unique(Procellaria$IDbird) 
unique(Procellaria$IDbird) #Get a list of tracking+year events.

####################################################################

## APPLY Q SPEED FILTERS TO DATASET

GLS_data <- list() #create an empty list for later storage of all generated dataframes.


#####START THE LOOP HERE#####
trip.chtc<-NULL
for (i in 1:length(aa)){
  sub01<-Procellaria[Procellaria$IDbird==aa[i],] 
  #####VELOCITIES: calculate distance time and speed from latitude/longitude (for data already filtered by equinox) (between i, i±1 and i±2 position) #####
  # creates empty columns for later function 
  sub01$Dist2b<-numeric(nrow(sub01))     # b - positions before
  sub01$Time2b<-numeric(nrow(sub01))
  sub01$Speed2b<-numeric(nrow(sub01))
  sub01$Dist1b<-numeric(nrow(sub01))     
  sub01$Time1b<-numeric(nrow(sub01))
  sub01$Speed1b<-numeric(nrow(sub01))
  sub01$Dist1a<-numeric(nrow(sub01))     # a - positions after
  sub01$Time1a<-numeric(nrow(sub01))
  sub01$Speed1a<-numeric(nrow(sub01))
  sub01$Dist2a<-numeric(nrow(sub01))
  sub01$Time2a<-numeric(nrow(sub01))
  sub01$Speed2a<-numeric(nrow(sub01))
  sub01$QSpeed<-numeric(nrow(sub01)) 
  for(z in 3:(nrow(sub01)-2)) { 
    # exclude first two and last two positions
    Dist1b<-numeric(nrow(sub01))            # creates empty values for later function
    Dist2b<-numeric(nrow(sub01))
    Time1b<-numeric(nrow(sub01))
    Time2b<-numeric(nrow(sub01))
    Speed1b<-numeric(nrow(sub01))
    Speed2b<-numeric(nrow(sub01))
    Dist1a<-numeric(nrow(sub01))        
    Dist2a<-numeric(nrow(sub01))
    Time1a<-numeric(nrow(sub01))
    Time2a<-numeric(nrow(sub01))
    Speed1a<-numeric(nrow(sub01))
    Speed2a<-numeric(nrow(sub01))
    QSpeed<-numeric(nrow(sub01)) 
    lat<-sub01$LAT
    long<-sub01$LON
    dtime<-sub01$datextime
    # positions before
    Dist1b[z] <- distance(lat[z-1], lat[z], long[z-1], long[z])  # distance between the point and previous point
    sub01$Dist1b[z]<- Dist1b[z]
    Dist2b[z] <- distance(lat[z-2], lat[z], long[z-2], long[z])  # distance between the point and second previous point
    sub01$Dist2b[z]<- Dist2b[z]
    Time1b[z] <- -(as.numeric(difftime(dtime[z-1], dtime[z], units = "hours", tz= "GMT")))
    sub01$Time1b[z]<-Time1b[z]
    Time2b[z] <- -(as.numeric(difftime(dtime[z-2], dtime[z], units = "hours", tz= "GMT")))
    sub01$Time2b[z]<-Time2b[z]
    Speed1b[z] <- Dist1b[z]/Time1b[z]
    sub01$Speed1b[z]<-Speed1b[z]
    Speed2b[z] <- Dist2b[z]/Time2b[z]
    sub01$Speed2b[z]<-Speed2b[z]
    # positions after
    Dist1a[z] <- distance(lat[z], lat[z+1], long[z], long[z+1])  # distance between the point and next point
    sub01$Dist1a[z]<- Dist1a[z]
    Dist2a[z] <- distance(lat[z], lat[z+2], long[z], long[z+2])  # distance between the point and second next point
    sub01$Dist2a[z]<- Dist2a[z]
    Time1a[z] <- -(as.numeric(difftime(dtime[z], dtime[z+1], units = "hours", tz= "GMT")))
    sub01$Time1a[z]<-Time1a[z]
    Time2a[z] <- -(as.numeric(difftime(dtime[z], dtime[z+2], units = "hours", tz= "GMT")))
    sub01$Time2a[z]<-Time2a[z]
    Speed1a[z] <- Dist1a[z]/Time1a[z]
    sub01$Speed1a[z]<-Speed1a[z]
    Speed2a[z] <- Dist2a[z]/Time2a[z]
    sub01$Speed2a[z]<-Speed2a[z]
    v2b <- Speed2b[z]
    v1b <- Speed1b[z]
    v1a <- Speed1a[z]
    v2a <- Speed2a[z]
    v<-numeric(nrow(sub01))
    v[z]<- sqrt(sum(v2b^2, v1b^2, v1a^2, v2a^2)/4)
    sub01$QSpeed[z] <- v[z]
  }
  GLS_data[i] <- list(sub01)
  print(c(i,z))
}
GLS_all <- NULL
for(i in seq(along = aa)){
  GLS_all <- rbind(GLS_all, as.data.frame((GLS_data[i])))
}
head(GLS_all)

#### DEFINE SPEED LIMIT FROM DATA: analyse speed summary statistics in each population to fix the value of speed limit #####
## First check if there are outliers in calculated speed, time, and distance values.
## Remove rows where time between consecutive points is unbelievable (the average time is 12 hours), so we use 6 hours as minimum time between consecutive positions to remain in the dataset.
## Hence remove rows where Time1b or Time1a are less than 6 as well as less than 0.
## Then define an upper limit as the 95% quantile

GLS_all$temp <-  NULL
GLS_all$temp <- ifelse ((GLS_all$Time1a < 0) | ((GLS_all$Time1a > 0) & (GLS_all$Time1a < 6)), 1, 0)
GLS_all <- subset (GLS_all, GLS_all$temp == 0)  
GLS_all$temp <- NULL    

GLS_all$limit <- quantile(GLS_all$QSpeed, prob=0.95, na.rm=TRUE)
head(GLS_all)
nrow(GLS_all)

## remove positions over the speed limit
GLS_all <- subset (GLS_all, (GLS_all$QSpeed <= GLS_all$limit))
GLS_all <- subset (GLS_all, (GLS_all$QSpeed != 0)) # removes "end locations" (first two and last two postions)

nrow(GLS_all) # use before and after the above to check that the rows removed
max(GLS_all$QSpeed) # use to check that the speed filter applied
