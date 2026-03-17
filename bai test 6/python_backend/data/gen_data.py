import csv
import random
import os

countries = {
    'VN': (79000000, 1.01),
    'US': (282000000, 1.008),
    'CN': (1260000000, 1.005),
    'IN': (1050000000, 1.012),
    'ID': (211000000, 1.011),
    'PK': (142000000, 1.02),
    'BR': (175000000, 1.009),
    'NG': (122000000, 1.025),
    'BD': (131000000, 1.01),
    'RU': (146000000, 0.998),
    'MX': (97000000, 1.012),
    'JP': (126000000, 0.999),
    'ET': (66000000, 1.026),
    'PH': (77000000, 1.016),
    'EG': (68000000, 1.02),
    'CD': (47000000, 1.03),
    'TR': (63000000, 1.013),
    'IR': (65000000, 1.013),
    'DE': (82000000, 1.001),
    'TH': (62000000, 1.003),
    'GB': (58000000, 1.006),
    'FR': (59000000, 1.005),
    'IT': (56000000, 1.002),
    'TZ': (34000000, 1.03),
    'ZA': (44000000, 1.012)
}

csv_path = os.path.join(os.path.dirname(__file__), 'population_data.csv')

with open(csv_path, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["CountryCode", "Year", "Population"])
    for code, (base_pop, growth_rate) in countries.items():
        pop = base_pop
        for year in range(2000, 2025):
            noise = random.uniform(-0.002, 0.002)
            pop = pop * (growth_rate + noise)
            writer.writerow([code, year, int(pop)])
