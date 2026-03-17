from pydantic import BaseModel
from typing import Dict, List

class Country(BaseModel):
    code: str
    name: str

class Metrics(BaseModel):
    rmse: float
    mae: float

class PredictionResult(BaseModel):
    country_code: str
    historical_years: List[int]
    historical_populations: List[int]
    future_years: List[int]
    predictions: Dict[str, List[int]]
    metrics: Dict[str, Metrics]
