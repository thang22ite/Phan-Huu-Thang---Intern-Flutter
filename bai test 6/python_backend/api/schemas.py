from pydantic import BaseModel
from typing import List

class PredictRequest(BaseModel):
    country_code: str
    target_year: int
    selected_models: List[str]
