TODO: 
 - [x] no absolute paths in the CSV
   - fixed by running the imagej function locally 
 - [x] correct the reflection position in ImageJ macro
 - [x] porting script to update old CSVs
 - [x] sample labeling necessary??
   - fixed by using the fileparts() method 
 - [x] where to store images
   - see /data/images directory
 - [x] background subtraction methods
 - [x] save data
 - [x] read data
 - [ ] edge visualization script
 - [ ] to table script
 - [x] save parameter struct into data
 - [x] doc strings for cany_measurement

- parameters
  - method_type: "ImageJ_Canny"
  - args:
    - reflection_image: double
    - transmission_image: double
    - reflection_image_path: string
    - transmission_image_path: string
    - reflection_x1: float
    - reflection_y1: float
    - reflection_x2: float
    - reflection_y2: float
    - transmission_x1: float
    - transmission_y1: float
    - transmission_x2: float
    - transmission_y2: float
    - angle_degree: float
    - conversion: float