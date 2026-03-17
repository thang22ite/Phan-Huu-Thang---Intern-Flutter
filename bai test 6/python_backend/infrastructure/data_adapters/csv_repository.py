import csv
from typing import List, Tuple
from domain.interfaces import IDataRepository

class CSVRepository(IDataRepository):
    def __init__(self, file_path: str):
        self.file_path = file_path

    def get_historical_data(self, country_code: str) -> Tuple[List[int], List[int]]:
        years = []
        populations = []
        with open(self.file_path, mode='r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                if row['CountryCode'] == country_code:
                    years.append(int(row['Year']))
                    populations.append(int(row['Population']))
        
        # Sort by year just in case
        sorted_pairs = sorted(zip(years, populations))
        if not sorted_pairs:
            return [], []
            
        sorted_years, sorted_pops = zip(*sorted_pairs)
        return list(sorted_years), list(sorted_pops)
