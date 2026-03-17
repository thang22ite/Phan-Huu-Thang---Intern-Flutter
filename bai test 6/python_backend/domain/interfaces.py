from abc import ABC, abstractmethod
from typing import List, Tuple

class IDataRepository(ABC):
    @abstractmethod
    def get_historical_data(self, country_code: str) -> Tuple[List[int], List[int]]:
        """Returns tuple of (years, populations)"""
        pass

class IModelRepository(ABC):
    @abstractmethod
    def train_and_predict(self, X_train: List[int], y_train: List[int], X_test: List[int]) -> List[int]:
        """Trains the model and predicts for test inputs"""
        pass
