import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from domain.interfaces import IModelRepository

class BaseSklearnModelAdapter(IModelRepository):
    def __init__(self, model):
        self.model = model

    def train_and_predict(self, X_train: list[int], y_train: list[int], X_test: list[int]) -> list[int]:
        X_train_np = np.array(X_train).reshape(-1, 1)
        y_train_np = np.array(y_train)
        X_test_np = np.array(X_test).reshape(-1, 1)
        
        self.model.fit(X_train_np, y_train_np)
        
        predictions = self.model.predict(X_test_np)
        return [int(p) for p in predictions.tolist()]

class LinearRegressionAdapter(BaseSklearnModelAdapter):
    def __init__(self):
        super().__init__(LinearRegression())

class RandomForestAdapter(BaseSklearnModelAdapter):
    def __init__(self):
        super().__init__(RandomForestRegressor(n_estimators=100, random_state=42))

class GradientBoostingAdapter(BaseSklearnModelAdapter):
    def __init__(self):
        super().__init__(GradientBoostingRegressor(n_estimators=100, random_state=42))
