# MRI_10_20_EEG_Extraction

## Measures and extracts 10-20 EEG markers from MRI volume using manually identified principal landmarks

This projet is an alternative to MNI warping-based 10-20 extraction algorithms. It uses arc length along the contour of the scalp to compute percentile distances between two points. This was done to mimic the process of 10-20 measurements in clinical settings.


## How to use

* Ensure that /Lib is added to MATLAB path using addpath(Lib)
* Run function with "[Markers, hc, Labels] = FilterAndGet1020(LM, nifti_filepath)"
    * LM is the 4x3 matrix of 3D coordinates for the 4 principal landmarks of the 10-20 system in ALS coordinates
* Use slider to set threshold filter to where there is no artifact occluding the surface of the scalp
* Press "Continue"
* Ensure markers were placed correctly, and re-run with adjusted filter if not


## Installation

Clone the repository using the following:
```
git clone https://github.com/TylerNafziger/MRI_10_20_EEG_Extraction.git
```

## Known issues

* Defacing or other occulsions of the face such as goggles or headphones can cause discontinuities in the scalp and distorting of the arc length measurements
* Over or under filtering can also disrupt the continuity of the scalp
* Depth first search algorithm for sorting the contours only work in RAS volumes, and can sometimes start in the wrong direction, causing measurements to be recorded along an inappropriate perimeter