from multiprocessing.connection import answer_challenge
import numpy as np
import pandas as pd
import cv2
import typing
import pathlib
from dataclasses import dataclass
import logging

logging.basicConfig(level=logging.DEBUG)

@dataclass
class CannyImportParameters:
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

@dataclass
class CannyParameters:
    reflection_image: np.ndarray
    transmission_image: np.ndarray
    difference_image: np.ndarray


class SLEDImageProcessing:
    def read_imagej_csv_to_canny_parameters(self, csv_file_path: typing.Union[str, pathlib.Path]) -> None:
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

        self.canny_import_parameters = CannyImportParameters(
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
        return self.canny_import_parameters

    def load_canny_parameters(self, data: CannyImportParameters):
        try:
            reflection_image = cv2.imread(data.reflection_image_path)
            logging.debug("Loaded reflection image")
        except Exception:
            logging.error("Could not load reflection image")

        try:
            transmission_image = cv2.imread(data.transmission_image_path)
            logging.debug("Loaded transmission image")
        except Exception:
            logging.error("Could not load transmission image")
        
        # rotation matrix needed for reflection position
        angle_rad = data.angle_degree * np.pi / 180.0
        R = np.array([[np.cos(angle_rad), -np.sin(angle_rad)], [np.sin(angle_rad), np.cos(angle_rad)]])

        reflection_pos = np.array([data.reflection_x1, data.reflection_y1])
        reflection_pos = (R @ reflection_pos.reshape((-1, 1))).flatten()
        transmission_pos = np.array([data.transmission_x1, data.transmission_y1])

