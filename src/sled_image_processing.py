import numpy as np
import pandas as pd
import cv2
import typing
import pathlib
from dataclasses import dataclass
import logging

logging.basicConfig(level=logging.DEBUG)

@dataclass
class CannyParameters:
    reflection_image_path: str
    transmission_image_path: str
    reflection_x1: float
    reflection_y1: float
    reflection_x2: float
    reflection_y2: float
    transmission_x1: float
    transmission_y1: float
    transmission_x2: float
    transmission_y2: float
    angle_degree: float
    conversion: float

    def angle_deg2rad(self) -> float:
        self.angle_rad = self.angle_degree * np.pi / 180.0
        return self.angle_rad

    def get_rotation_correct_reflection_postion(self) -> np.ndarray:
        R = np.array([[np.cos(self.angle_rad), -np.sin(self.angle_rad)], [np.sin(self.angle_rad), np.cos(self.angle_rad)]])
        self.reflection_pos = np.array([self.reflection_x1, self.reflection_y1])
        self.reflection_pos = (R @ self.reflection_pos.reshape((-1, 1))).flatten()
        return self.reflection_pos

    def get_transmission_position(self) -> np.ndarray:
        self.transmission_pos = np.array([self.transmission_x1, self.transmission_y1])
        return self.transmission_pos
    
    def load_reflection_image(self) -> np.ndarray:
        try:
            self.reflection_image = cv2.imread(self.reflection_image_path)
            self.reflection_image = cv2.cvtColor(self.reflection_image, cv2.COLOR_BGR2RGB)
            logging.debug("Loaded reflection image")
            return self.reflection_image
        except Exception:
            logging.error("Could not load reflection image")

    def load_transmission_image(self) -> np.ndarray:
        try:
            self.transmission_image = cv2.imread(self.transmission_image_path)
            self.transmission_image = cv2.cvtColor(self.transmission_image, cv2.COLOR_BGR2RGB)
            # self.
            logging.debug("Loaded transmission image")
            return self.transmission_image
        except Exception:
            logging.error("Could not load transmission image")

    def check_image_dimensions(self) -> bool:
        self.is_dimensions_valid = self.reflection_image.shape == self.transmission_image.shape
        if self.is_dimensions_valid:
            logging.debug("image dimensions valid")
        else:
            logging.debug("image dimension mismatch")
        return self.is_dimensions_valid

    def images_to_grayscale(self) -> typing.Tuple[np.ndarray, np.ndarray]:
        self.reflection_gray = cv2.cvtColor(self.reflection_image, cv2.COLOR_RGB2GRAY)
        self.transmission_gray = cv2.cvtColor(self.transmission_image, cv2.COLOR_RGB2GRAY)
        logging.debug("images converted to grayscale")
        return self.reflection_gray, self.transmission_gray

    def background_subtract(self) -> np.ndarray:
        self.diff_image = self.reflection_image - self.transmission_image
        logging.debug("background substracted transmission from reflection")
        return self.diff_image
    
    def instantiate_meta_parameters(self, search_width: int, canny_threshold: np.ndarray, canny_std: float) -> None:
        self.search_width = search_width
        self.radius = round(self.search_width / 2.0)
        self.crop_region_start = round(self.reflection_pos[0] - self.radius)
        self.crop_region_stop  = round(self.transmission_pos[0] + self.radius)
        self.canny_threshold = canny_threshold
        self.canny_std = canny_std
        logging.debug("instantiate canny parameters")

    def crop_grayscale_image(self, img: np.ndarray) -> np.ndarray:
        self.cropped_image = img[:, self.crop_region_start:self.crop_region_stop]
        logging.debug("cropped image")
        return self.cropped_image

    def find_grayscale_edge_thickness(self, img: np.ndarray) -> np.ndarray:
        self.edge_image = cv2.Canny(img, self.canny_threshold[0], self.canny_threshold[1], self.canny_std)
        self.thickness = self.thickness_array(self.edge_image)
        self.thickness = self.thickness / self.conversion
        self.mean = np.mean(self.thickness)
        self.std = np.std(self.thickness)
        self.min = np.minimum(self.thickness)
        self.max = np.maximum(self.thickness)
        self.n = self.thickness.shape[0]
        logging.debug("found thickness")



    def thickness_array(self, bool_img: np.ndarray) -> typing.Union[np.ndarray, None]:
        rows, cols = bool_img.shape
        idx = 1
        edgePt = []
        thickness = []
        for i in range(rows):
            for j in range(cols):
                if bool_img[i, j] == 1:
                    edgePt[idx] = j
                    idx += 1
            idx = 1
            if np.shape(edgePt)[0] != 0:
                thickness.append(max(edgePt) - min(edgePt))
        try:
            thickness = np.ndarray()
            thickness = thickness[thickness != 0]
            return thickness
        except Exception:
            logging.error("Thickness array was never filled; check that there are edges in the image")            


class SLEDImageProcessing:
    def read_imagej_csv_to_canny_parameters(self, csv_file_path: typing.Union[str, pathlib.Path]) -> CannyParameters:
        csv_data = pd.read_csv(csv_file_path)
        reflection_image_path = csv_data['Reflection'].values[0]
        transmission_image_path = csv_data['Transmission'].values[0]
        reflection_x1 = csv_data['x1_r'].values[0]
        reflection_y1 = csv_data['y1_r'].values[0]
        reflection_x2 = csv_data['x2_r'].values[0]
        reflection_y2 = csv_data['y2_r'].values[0]
        transmission_x1 = csv_data['x1_t'].values[0]
        transmission_y1 = csv_data['y1_t'].values[0]
        transmission_x2 = csv_data['x2_t'].values[0]
        transmission_y2 = csv_data['y2_t'].values[0]
        angle_degree = csv_data['Angle'].values[0]
        conversion = csv_data['Conversion'].values[0]

        self.canny_data_parameters = CannyParameters(
            reflection_image_path=reflection_image_path,
            transmission_image_path=transmission_image_path,
            reflection_x1=reflection_x1,
            reflection_y1=reflection_y1,
            reflection_x2=reflection_x2,
            reflection_y2=reflection_y2,
            transmission_x1=transmission_x1,
            transmission_y1=transmission_y1,
            transmission_x2=transmission_x2,
            transmission_y2=transmission_y2,
            angle_degree=angle_degree,
            conversion=conversion
        )
        return self.canny_data_parameters

    def canny_method(self, data: CannyParameters) -> CannyParameters:
        # rotation matrix needed for reflection position
        data.angle_deg2rad()
        data.get_rotation_correct_reflection_postion()        
        data.get_transmission_position()
        data.load_reflection_image()
        data.load_transmission_image()
        data.check_image_dimensions()
        data.images_to_grayscale()
        data.background_subtract()
        data.instantiate_meta_parameters(search_width=40,
                                        canny_threshold=np.array([0.01*255, 0.2*255]),
                                        canny_std=10.0)
        data.crop_grayscale_image(data.diff_image)
        # data.find_grayscale_edge_thickness(data.cropped_image)
        return data


