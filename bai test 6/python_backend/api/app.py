from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os

from domain.entities import PredictionResult
from api.schemas import PredictRequest
from use_cases.predict_population import PredictPopulationUseCase
from infrastructure.data_adapters.csv_repository import CSVRepository
from infrastructure.ml_models.adapters import LinearRegressionAdapter, RandomForestAdapter, GradientBoostingAdapter

app = FastAPI(title="Population Prediction API")

# Setup CORS to allow requests from Flutter (avoiding issues when testing on web/emulator)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency setup (in a real app, use a DI container)
DATA_FILE_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "population_data.csv")
data_repo = CSVRepository(DATA_FILE_PATH)
models_dict = {
    "Linear Regression": LinearRegressionAdapter(),
    "Random Forest": RandomForestAdapter(),
    "Gradient Boosting": GradientBoostingAdapter(),
}
predict_use_case = PredictPopulationUseCase(data_repo, models_dict)

@app.post("/predict", response_model=PredictionResult)
def predict_population(request: PredictRequest):
    try:
        result = predict_use_case.execute(
            country_code=request.country_code,
            target_year=request.target_year,
            selected_models=request.selected_models
        )
        return result
    except ValueError as val_err:
        raise HTTPException(status_code=400, detail=str(val_err))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
def health_check():
    return {"status": "healthy"}
