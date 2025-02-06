# Metapopulation distribution shapes year-round fisheries bycatch risk for a circumpolar seabird

Kalinka Rexer-Huber, Thomas A. Clay, Paulo Catry, Igor Debski, Graham Parker, Raül Ramos, Bruce C. Robertson, Peter G. Ryan, Paul M. Sagar, Andrew Stanworth, David R. Thompson, Geoffrey N. Tuck, Henri Weimerskirch, Richard A. Phillips

## Overview and data

The following repository contains codes to derive spatial locations based on light-based geolocation for White-chinned petrels _Procellaria aequinoctialis_, and processed geolocator datasets, published in Ecological Applications (Rexer-Huber, Clay, _et al._ 2025). Scripts were customised by R. Ramos and K. Rexer-Huber following Z. Zajkova (unpubl. R scripts for GLS 2015). 

## General statement (please read before using data)

The attached archived file(s) contain data derived from long-term tracking projects on albatrosses and petrels at Bird Island (South Georgia), Iles Crozet, Iles Kerguelen, Falkland Islands, Marion Island (Prince Edward) Islands), Auckland Islands and Antipodes Islands.  

This is a request to please let us know if you use them.  Several people have made extensive efforts overseeing the data collection for the last 25+ years.

If you plan to analyse the data, there are a number of reasons why it would be very helpful if you could contact the appropriate data holder before doing so: 

South Georgia: Richard Phillips (raphil@bas.ac.uk)
Crozet and Kerguelen: Henri Weimerskirch (henri.weimerskirch@cebc.cnrs.fr)
Falkland Islands: Paulo Catry (paulo.catry@gmail.com) and Andrew Stanworth (CO@conservation.org.fk)
Prince Edward Islands: Peter Ryan (prpryan31@gmail.com)
Antipodes: David Thompson (David.Thompson@niwa.co.nz)
Auckland: Kalinka Rexer-Huber (k.rexer-huber@parkerconservation.co.nz)

1. Occasionally we discover and correct errors in the data.
2. The data are complex and workers who do not know the study system are likely to benefit from advice on interpretation.
3. At any one time, several people within the existing project collaboration are analysing data from this project. Someone else may already be conducting the analysis you have in mind and it is desirable both to prevent duplication of effort and the risk of compromising the work of a PhD student, for example, whose future career may depend on publications arising from analyses of these data.
4. In order to maintain funding for the project and for further analyses, every few years we submit proposals to funding agencies. It is therefore very helpful for those running the project to know which data analyses are in progress elsewhere.

If you are interested in analysing the detailed project data in any depth, you may find it helpful to have access to the full database rather than the files available here.  If so, we are always open to further collaboration.

## Codes

Here are the main codes in R to filter geolocator data:
**1_geolocator_validation_filtering.r**: This comprises code to run an equinox filter that removes positions 15 days either side of the equinoxes, a latitudinal filter to remove extreme latitudinal outliers (positions south of 70°S or north of the equator), and a speed filter that removes positions that would require unrealistic flight speeds.
