from typing import Dict, List
from sklearn.metrics import mean_squared_error, mean_absolute_error
import numpy as np
from domain.interfaces import IDataRepository, IModelRepository
from domain.entities import PredictionResult, Metrics

class PredictPopulationUseCase:
    def __init__(self, data_repo: IDataRepository, models: Dict[str, IModelRepository]):
        self.data_repo = data_repo
        self.models = models

    def execute(self, country_code: str, target_year: int, selected_models: List[str]) -> PredictionResult:
        # Lấy dữ liệu lịch sử
        hist_years, hist_pops = self.data_repo.get_historical_data(country_code)
        
        if not hist_years:
            raise ValueError(f"No historical data found for country code: {country_code}")

        # Sinh các năm cần dự đoán
        last_year = hist_years[-1]
        if target_year <= last_year:
            raise ValueError(f"Target year {target_year} must be greater than the last historical year {last_year}")
            
        future_years = list(range(last_year + 1, target_year + 1))
        
        results = {}
        metrics_dict = {}

        # Chạy các mô hình được chọn
        for model_name in selected_models:
            if model_name in self.models:
                model = self.models[model_name]
                
                # Dự đoán tương lai
                future_preds = model.train_and_predict(hist_years, hist_pops, future_years)
                results[model_name] = future_preds
                
                # Để tính MAE/RMSE, ta bắt model dự đoán lại tập train
                train_preds = model.train_and_predict(hist_years, hist_pops, hist_years)
                
                rmse = float(np.sqrt(mean_squared_error(hist_pops, train_preds)))
                mae = float(mean_absolute_error(hist_pops, train_preds))
                
                metrics_dict[model_name] = Metrics(rmse=rmse, mae=mae)
            else:
                raise ValueError(f"Model {model_name} is not supported.")

        return PredictionResult(
            country_code=country_code,
            historical_years=hist_years,
            historical_populations=hist_pops,
            future_years=future_years,
            predictions=results,
            metrics=metrics_dict
        )
